import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_pulse_ceylon/pose/feedback.dart';
import 'package:neuro_pulse_ceylon/pose/frame_envelope.dart';

/// Tests the wire format and parsing rather than widgets.
///
/// The envelope layout and the feedback field names are a contract with the
/// Python service (ml-service/app/frames.py and schemas.py). A silent mismatch
/// there produces a session that connects and then does nothing, which is the
/// hardest kind of bug to spot from the UI.
void main() {
  group('frame envelope', () {
    test('writes the header the service expects', () {
      final payload = Uint8List.fromList([9, 8, 7]);
      final out = buildEnvelope(
        timestampMs: 1234,
        pixelFormat: PixelFormat.nv21,
        width: 320,
        height: 240,
        data: payload,
      );

      expect(out.length, 13 + payload.length);

      final view = ByteData.view(out.buffer);
      expect(view.getUint64(0, Endian.big), 1234);
      expect(view.getUint8(8), PixelFormat.nv21);
      expect(view.getUint16(9, Endian.big), 320);
      expect(view.getUint16(11, Endian.big), 240);
      expect(out.sublist(13), payload);
    });

    test('nv21 format tag matches the service constant', () {
      // FORMAT_NV21 = 2 and FORMAT_JPEG = 0 in ml-service/app/frames.py.
      expect(PixelFormat.nv21, 2);
      expect(PixelFormat.jpeg, 0);
    });
  });

  group('feedback parsing', () {
    test('reads a full frame response', () {
      final feedback = PoseFeedback.fromJson({
        'reps': 3,
        'phase': 'up',
        'tracked_angle': 87.4,
        'form_score': 0.75,
        'cues': [
          {'id': 'elbow_straight', 'text': 'Keep your elbow straight'},
        ],
        'fall': false,
        'visible': true,
      });

      expect(feedback.reps, 3);
      expect(feedback.phase, RepPhase.up);
      expect(feedback.trackedAngle, closeTo(87.4, 0.001));
      expect(feedback.formScore, closeTo(0.75, 0.001));
      expect(feedback.cues.single.id, 'elbow_straight');
      expect(feedback.visible, isTrue);
    });

    test('survives a not-visible frame with nulls', () {
      final feedback = PoseFeedback.fromJson({
        'reps': 1,
        'phase': 'unknown',
        'cues': <dynamic>[],
        'fall': false,
        'visible': false,
      });

      expect(feedback.formScore, isNull);
      expect(feedback.trackedAngle, isNull);
      expect(feedback.phase, RepPhase.unknown);
      expect(feedback.visible, isFalse);
    });
  });

  test('exercise summary defaults calibrated to false', () {
    final exercise = ExerciseSummary.fromJson({
      'id': 'sit_to_stand',
      'name': 'Sit to Stand',
      'targetReps': 8,
      'cues': ['Stand up fully'],
    });

    expect(exercise.calibrated, isFalse);
    expect(exercise.targetReps, 8);
  });
}
