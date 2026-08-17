import 'dart:convert';

import 'package:flutter/material.dart';

import '../features/i18n.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../features/language.dart';
import '../pose/feedback.dart';
import '../ui/tokens.dart';
import '../ui/widgets.dart';
import 'session_screen.dart';

/// The exercises the coach can track, fetched from the Python service so the app
/// can never drift from what the angle rules support.
class ExerciseListScreen extends StatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  List<ExerciseSummary>? _exercises;
  String? _error;

  static const _icons = <String, IconData>{
    'shoulder_flexion_left': Icons.accessibility_new,
    'shoulder_flexion_right': Icons.accessibility_new,
    'elbow_extension_left': Icons.fitness_center,
    'elbow_extension_right': Icons.fitness_center,
    'straight_leg_raise_left': Icons.directions_walk,
    'straight_leg_raise_right': Icons.directions_walk,
    'knee_extension_left': Icons.airline_seat_recline_normal,
    'knee_extension_right': Icons.airline_seat_recline_normal,
    'sit_to_stand': Icons.arrow_circle_up,
    'hamstring_curl_supine': Icons.airline_seat_flat,
    'hamstring_curl_prone': Icons.airline_seat_individual_suite,
    'hamstring_curl_seated': Icons.chair,
    'romanian_deadlift_single_leg': Icons.self_improvement,
    'single_leg_stance': Icons.balance,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _error = null;
      _exercises = null;
    });
    try {
      // The patient's stored language, not a hardcoded 'en' — the service returns
      // localised names and cues, and asking for the wrong language silently
      // throws that away.
      final response = await http
          .get(exercisesUri(languageStore.code))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) {
        throw StateError('service returned ${response.statusCode}');
      }
      final list = (jsonDecode(response.body) as List)
          .whereType<Map<String, dynamic>>()
          .map(ExerciseSummary.fromJson)
          .toList(growable: false);
      if (mounted) {
        setState(() => _exercises = list);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeader(
                title: t('ex.title'),
                subtitle: _exercises == null
                    ? t('ex.loadingFromCoach')
                    : '${_exercises!.length} ${t('ex.trackable')}',
                back: true,
              ),
              Expanded(child: _body()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 44, color: AppColor.inkSubtle),
            const SizedBox(height: Space.base),
            Text(t('ex.unavailable'), style: AppText.heading),
            const SizedBox(height: Space.sm),
            Text(
              'Tried $mlHttpBase\n$_error',
              style: AppText.caption.copyWith(color: AppColor.inkMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Space.base),
            OutlinedButton(onPressed: _load, child: Text(t('common.tryAgain'))),
          ],
        ),
      );
    }
    if (_exercises == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        itemCount: _exercises!.length,
        separatorBuilder: (_, _) => const SizedBox(height: Space.md),
        itemBuilder: (context, index) => _row(_exercises![index]),
      ),
    );
  }

  Widget _row(ExerciseSummary exercise) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.lg),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => Localized(
              SessionScreen(
                exercise: exercise.id,
                title: exercise.name,
                targetReps: exercise.targetReps,
                mode: exercise.mode,
                targetSeconds: exercise.targetSeconds,
              ),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Space.base),
          child: Row(
            children: [
              Container(
                width: Sizes.chip,
                height: Sizes.chip,
                decoration: BoxDecoration(
                  color: AppColor.brandTint,
                  borderRadius: BorderRadius.circular(Radii.md),
                ),
                child: Icon(
                  _icons[exercise.id] ?? Icons.circle_outlined,
                  size: 30,
                  color: AppColor.brandText,
                ),
              ),
              const SizedBox(width: Space.base),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exercise.name, style: AppText.subheading),
                    const SizedBox(height: 2),
                    Text(
                      exercise.mode == ExerciseMode.hold
                          ? '${t('ex.hold')} ${exercise.targetSeconds} ${t('ex.seconds')}'
                          : '${exercise.targetReps} ${t('common.reps')}',
                      style: AppText.bodyStrong
                          .copyWith(color: AppColor.brandText),
                    ),
                    if (exercise.cues.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        exercise.cues.join(' · '),
                        style:
                            AppText.caption.copyWith(color: AppColor.inkMuted),
                      ),
                    ],
                    // No calibration badge here by design. How a threshold was
                    // derived is information for the team, not for a patient
                    // choosing an exercise — it invites doubt they can do nothing
                    // about. `calibrated` still comes over the API and is recorded
                    // in docs/VALIDATION.md.
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColor.inkDisabled),
            ],
          ),
        ),
      ),
    );
  }

}
