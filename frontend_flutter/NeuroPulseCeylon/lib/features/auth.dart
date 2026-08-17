import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';

/// Who is signed in. Mirrors the `user` object the Node service returns, which
/// deliberately never includes a credential hash.
@immutable
class AuthUser {
  const AuthUser({
    required this.id,
    required this.role,
    required this.name,
    this.email,
    this.age,
    this.strokeType,
  });

  final String id;
  final String role;
  final String name;
  final String? email;
  final int? age;
  final String? strokeType;

  bool get isPatient => role == 'patient';

  /// The patient identifier the ML service tags a session with. For staff there
  /// is no own-body session to run, so this is only meaningful for patients.
  String get patientKey => isPatient ? id : 'unknown';

  static AuthUser? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final role = raw['role'];
    final name = raw['name'];
    if (id is! String || role is! String || name is! String) return null;
    return AuthUser(
      id: id,
      role: role,
      name: name,
      email: raw['email'] as String?,
      age: (raw['age'] as num?)?.toInt(),
      strokeType: raw['strokeType'] as String?,
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'role': role,
        'name': name,
        'email': email,
        'age': age,
        'strokeType': strokeType,
      };
}

/// Why a sign-in attempt failed, so the UI can say something specific in the
/// user's own language instead of echoing an HTTP status.
enum AuthFailure {
  wrongCredentials,
  lockedOut,
  unreachable,
  unexpected,

  /// Registration only: the username or email is already an account's login key.
  taken,
}

class AuthResult {
  const AuthResult.ok()
      : failure = null,
        retryAfter = null;
  const AuthResult.failed(this.failure, {this.retryAfter});

  final AuthFailure? failure;
  final Duration? retryAfter;

  bool get ok => failure == null;
}

/// Session state, persisted so a patient is not asked to sign in every time the
/// app is opened. Follows the same shape as [languageStore]: one instance,
/// created in main(), read directly by screens.
class AuthStore extends ChangeNotifier {
  static const _tokenKey = 'neuropulse.auth.token';
  static const _userKey = 'neuropulse.auth.user';

  static const _timeout = Duration(seconds: 8);

  String? _token;
  AuthUser? _user;
  bool _ready = false;

  AuthUser? get user => _user;
  bool get signedIn => _token != null && _user != null;

  /// False until the stored token has been read. main() awaits [load] before the
  /// first frame so the app can open on the right screen rather than flashing
  /// the sign-in flow at someone who is already signed in.
  bool get ready => _ready;

  Map<String, String> get authedHeaders => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(_tokenKey);
      final storedUser = prefs.getString(_userKey);
      if (storedUser != null) {
        _user = AuthUser.fromJson(jsonDecode(storedUser));
      }
    } catch (error) {
      // A failed read just means we ask them to sign in again.
      debugPrint('authStore.load failed: $error');
      _token = null;
      _user = null;
    }
    _ready = true;
    notifyListeners();

    // Confirm the restored token in the background. Deliberately not awaited by
    // the caller: the app opens immediately on the cached identity, and only
    // drops to sign-in if the server says the token is dead. Being offline must
    // not log a patient out.
    if (_token != null) {
      _revalidate();
    }
  }

  Future<void> _revalidate() async {
    try {
      final response = await http
          .get(authMeUri(), headers: authedHeaders)
          .timeout(_timeout);

      if (response.statusCode == 401) {
        await _clear();
        return;
      }
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final fresh = AuthUser.fromJson(body['user']);
        if (fresh != null) {
          _user = fresh;
          await _persist();
          notifyListeners();
        }
      }
    } catch (_) {
      // Unreachable server: keep the cached session. Losing Wi-Fi is not a
      // reason to lock someone out of their rehabilitation exercises.
    }
  }

  Future<AuthResult> loginPatient(String username, String pin) =>
      _authenticate(authLoginPatientUri(), {'username': username, 'pin': pin});

  Future<AuthResult> loginStaff(String email, String password) =>
      _authenticate(authLoginStaffUri(), {'email': email, 'password': password});

  /// Creates the account and signs it in with the token the server returns —
  /// the same response shape as login, so both share [_authenticate].
  Future<AuthResult> registerPatient({
    required String name,
    required String username,
    required String pin,
  }) =>
      _authenticate(authRegisterPatientUri(),
          {'name': name, 'username': username, 'pin': pin});

  Future<AuthResult> registerStaff({
    required String name,
    required String email,
    required String password,
    required String role,
  }) =>
      _authenticate(authRegisterStaffUri(),
          {'name': name, 'email': email, 'password': password, 'role': role});

  Future<AuthResult> _authenticate(Uri uri, Map<String, String> body) async {
    http.Response response;
    try {
      response = await http
          .post(uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body))
          .timeout(_timeout);
    } catch (_) {
      return const AuthResult.failed(AuthFailure.unreachable);
    }

    if (response.statusCode == 429) {
      Duration? retry;
      try {
        final ms = (jsonDecode(response.body) as Map)['retryAfterMs'];
        if (ms is num) retry = Duration(milliseconds: ms.toInt());
      } catch (_) {
        // Fall through without a countdown.
      }
      return AuthResult.failed(AuthFailure.lockedOut, retryAfter: retry);
    }
    if (response.statusCode == 409) {
      return const AuthResult.failed(AuthFailure.taken);
    }
    if (response.statusCode == 401 || response.statusCode == 400) {
      return const AuthResult.failed(AuthFailure.wrongCredentials);
    }
    if (response.statusCode != 200) {
      return const AuthResult.failed(AuthFailure.unexpected);
    }

    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final token = decoded['token'];
      final user = AuthUser.fromJson(decoded['user']);
      if (token is! String || user == null) {
        return const AuthResult.failed(AuthFailure.unexpected);
      }
      _token = token;
      _user = user;
      await _persist();
      notifyListeners();
      return const AuthResult.ok();
    } catch (_) {
      return const AuthResult.failed(AuthFailure.unexpected);
    }
  }

  /// Signs out. The local session is cleared whatever the server says — a user
  /// who presses "log out" must end up logged out even with no network — but the
  /// revoke call is made first so the token dies server-side when it can.
  Future<void> logout() async {
    final had = _token;
    if (had != null) {
      try {
        await http
            .post(authLogoutUri(), headers: authedHeaders)
            .timeout(_timeout);
      } catch (_) {
        // Best effort; the token will be rejected once it is no longer stored.
      }
    }
    await _clear();
  }

  Future<void> _clear() async {
    _token = null;
    _user = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    } catch (_) {
      // Best effort.
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, _token!);
      await prefs.setString(_userKey, jsonEncode(_user!.toJson()));
    } catch (error) {
      debugPrint('authStore persist failed: $error');
    }
  }
}

final authStore = AuthStore();
