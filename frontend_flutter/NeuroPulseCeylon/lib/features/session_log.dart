import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Per-exercise completion log, so the exercise list doubles as a daily to-do.
///
/// Keyed by calendar day so "today" resets on its own with no scheduled job.
/// Local only and pruned to a fortnight — this is a progress indicator, not a
/// clinical record. The authoritative history belongs on the backend, which is
/// where a physiotherapist would read it from.
class SessionRecord {
  const SessionRecord({
    required this.exerciseId,
    required this.reps,
    required this.targetReps,
    required this.meanFormScore,
    required this.endedAt,
  });

  final String exerciseId;
  final int reps;
  final int targetReps;
  final double? meanFormScore;
  final DateTime endedAt;

  bool get complete => reps >= targetReps;

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'reps': reps,
        'targetReps': targetReps,
        'meanFormScore': meanFormScore,
        'endedAt': endedAt.toIso8601String(),
      };

  static SessionRecord? fromJson(Map<String, dynamic> json) {
    final ended = DateTime.tryParse(json['endedAt'] as String? ?? '');
    if (ended == null) return null;
    return SessionRecord(
      exerciseId: json['exerciseId'] as String? ?? '',
      reps: (json['reps'] as num?)?.toInt() ?? 0,
      targetReps: (json['targetReps'] as num?)?.toInt() ?? 0,
      meanFormScore: (json['meanFormScore'] as num?)?.toDouble(),
      endedAt: ended,
    );
  }
}

class SessionLog {
  static const _key = 'neuropulse.sessionLog.v1';
  static const _retainDays = 14;

  /// Local date, not UTC: a patient exercising at 9pm should not have it counted
  /// against tomorrow.
  static String dayKey([DateTime? now]) {
    final d = now ?? DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}'
        '-${d.day.toString().padLeft(2, '0')}';
  }

  static Future<Map<String, Map<String, dynamic>>> _read() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return {};
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      return decoded.map(
        (k, v) => MapEntry(k as String, (v as Map).cast<String, dynamic>()),
      );
    } catch (_) {
      // A corrupt log must not break the screen; start fresh.
      return {};
    }
  }

  /// Keeps the BEST attempt for the day rather than the most recent, so a patient
  /// who hits their target then starts another session doesn't appear to lose the
  /// completed one.
  static Future<void> record(SessionRecord record) async {
    if (record.reps <= 0) {
      // Nothing completed; an empty entry would read as an attempted-and-failed
      // session.
      return;
    }

    final log = await _read();
    final day = dayKey();
    final forDay = (log[day] ?? <String, dynamic>{}).cast<String, dynamic>();

    final existingJson = forDay[record.exerciseId];
    final existing = existingJson is Map
        ? SessionRecord.fromJson(existingJson.cast<String, dynamic>())
        : null;

    if (existing == null || record.reps >= existing.reps) {
      forDay[record.exerciseId] = record.toJson();
    }
    log[day] = forDay;

    final keys = log.keys.toList()..sort();
    final kept = keys.reversed.take(_retainDays).toSet();
    log.removeWhere((k, _) => !kept.contains(k));

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(log));
    } catch (_) {
      // Best effort; losing a progress entry isn't worth interrupting the user.
    }
  }

  static Future<Map<String, SessionRecord>> today() async {
    final log = await _read();
    final forDay = log[dayKey()] ?? {};
    final out = <String, SessionRecord>{};
    forDay.forEach((id, json) {
      if (json is Map) {
        final record = SessionRecord.fromJson(json.cast<String, dynamic>());
        if (record != null) out[id] = record;
      }
    });
    return out;
  }
}
