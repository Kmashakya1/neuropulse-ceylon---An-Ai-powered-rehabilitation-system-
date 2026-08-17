/// Per-frame feedback from the Python service. Mirrors FrameOut in
/// ml-service/app/schemas.py.
class Cue {
  const Cue({required this.id, required this.text});

  final String id;
  final String text;

  factory Cue.fromJson(Map<String, dynamic> json) => Cue(
        id: json['id'] as String? ?? '',
        text: json['text'] as String? ?? '',
      );
}

enum RepPhase { down, up, unknown }

RepPhase _phaseFrom(String? value) => switch (value) {
      'down' => RepPhase.down,
      'up' => RepPhase.up,
      _ => RepPhase.unknown,
    };

/// Rep-counted exercises versus timed holds. Balance work has no up/down cycle,
/// so a rep counter would sit at zero forever — see ml-service/app/session.py.
enum ExerciseMode { reps, hold }

ExerciseMode _modeFrom(String? value) =>
    value == 'hold' ? ExerciseMode.hold : ExerciseMode.reps;

class PoseFeedback {
  const PoseFeedback({
    required this.reps,
    required this.phase,
    required this.trackedAngle,
    required this.formScore,
    required this.cues,
    required this.fall,
    required this.visible,
    required this.mode,
    required this.holding,
    required this.holdSeconds,
    required this.bestHoldSeconds,
  });

  final int reps;
  final RepPhase phase;
  final double? trackedAngle;
  final double? formScore;
  final List<Cue> cues;
  final bool fall;

  final ExerciseMode mode;

  /// Hold-mode only: whether every condition is currently satisfied.
  final bool? holding;
  final double? holdSeconds;
  final double? bestHoldSeconds;

  /// False when no pose was found in the frame — usually the patient is out of
  /// shot. Distinct from "no movement", so the UI can prompt them to reposition
  /// rather than leaving a frozen rep count unexplained.
  final bool visible;

  factory PoseFeedback.fromJson(Map<String, dynamic> json) => PoseFeedback(
        reps: (json['reps'] as num?)?.toInt() ?? 0,
        phase: _phaseFrom(json['phase'] as String?),
        trackedAngle: (json['tracked_angle'] as num?)?.toDouble(),
        formScore: (json['form_score'] as num?)?.toDouble(),
        cues: ((json['cues'] as List?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(Cue.fromJson)
            .toList(growable: false),
        fall: json['fall'] as bool? ?? false,
        visible: json['visible'] as bool? ?? true,
        mode: _modeFrom(json['mode'] as String?),
        holding: json['holding'] as bool?,
        holdSeconds: (json['hold_seconds'] as num?)?.toDouble(),
        bestHoldSeconds: (json['best_hold_seconds'] as num?)?.toDouble(),
      );
}

/// An exercise as listed by GET /exercises.
class ExerciseSummary {
  const ExerciseSummary({
    required this.id,
    required this.name,
    required this.mode,
    required this.targetReps,
    required this.targetSeconds,
    required this.calibrated,
    required this.cues,
  });

  final String id;
  final String name;
  final ExerciseMode mode;
  final int targetReps;

  /// Hold-mode target, in seconds.
  final int targetSeconds;

  /// False when the exercise's angle thresholds are geometric guesses rather
  /// than measured from footage: rep counts are usable, form scores are not.
  final bool calibrated;
  final List<String> cues;

  factory ExerciseSummary.fromJson(Map<String, dynamic> json) =>
      ExerciseSummary(
        id: json['id'] as String,
        name: json['name'] as String,
        mode: _modeFrom(json['mode'] as String?),
        targetReps: (json['targetReps'] as num?)?.toInt() ?? 10,
        targetSeconds: (json['targetSeconds'] as num?)?.toInt() ?? 20,
        calibrated: json['calibrated'] as bool? ?? false,
        cues: ((json['cues'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(growable: false),
      );
}
