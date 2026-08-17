import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide language, persisted across launches.
///
/// The React Native app originally held this in local component state, so the
/// choice was lost on navigation and the app always asked the ML service for
/// English — wasting the Sinhala and Tamil names and cues it already returns.
enum Language {
  en('English', 'English'),
  si('සිංහල', 'Sinhala'),
  ta('தமிழ்', 'Tamil');

  const Language(this.native, this.english);

  final String native;
  final String english;
}

class LanguageStore extends ChangeNotifier {
  static const _key = 'neuropulse.language';

  Language _language = Language.en;
  bool _ready = false;

  Language get language => _language;
  String get code => _language.name;

  /// False until the stored value has been read, so screens can avoid fetching
  /// with the wrong language and then refetching.
  bool get ready => _ready;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_key);
      final match =
          Language.values.where((l) => l.name == stored).firstOrNull;
      if (match != null) {
        _language = match;
      }
    } catch (error) {
      // A failed read just means we stay on the default — but say so, because
      // swallowing this silently is exactly how it went unnoticed that the
      // stored language was never being restored at all.
      debugPrint('languageStore.load failed: $error');
    }
    _ready = true;
    notifyListeners();
  }

  Future<void> set(Language next) async {
    // Update immediately so the UI never lags the tap; persist after.
    _language = next;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, next.name);
    } catch (error) {
      debugPrint('languageStore.set failed: $error');
    }
  }
}

/// Single instance, created in main() and read directly by screens. A full
/// state-management package would be overkill for one value.
final languageStore = LanguageStore();
