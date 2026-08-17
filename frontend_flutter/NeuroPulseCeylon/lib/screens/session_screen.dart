import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../features/auth.dart';
import '../features/i18n.dart';

import '../features/language.dart';
import '../pose/demo_video.dart';
import '../pose/feedback.dart';
import '../pose/pose_session.dart';
import '../ui/tokens.dart';

/// Live exercise session: camera preview with rep count and coaching cues.
///
/// The rep count is the largest thing on screen and nothing competes with it.
/// Cues appear beneath with an icon as well as colour, since colour alone is
/// unreliable for users with reduced contrast sensitivity.
class SessionScreen extends StatefulWidget {
  const SessionScreen({
    super.key,
    required this.exercise,
    required this.title,
    required this.targetReps,
    this.mode = ExerciseMode.reps,
    this.targetSeconds = 20,
  });

  final String exercise;
  final String title;
  final int targetReps;
  final ExerciseMode mode;
  final int targetSeconds;

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  late final PoseSession _session;

  @override
  void initState() {
    super.initState();
    _session = PoseSession(
      exercise: widget.exercise,
      lang: languageStore.code,
      // Tags the session and any fall alert with the signed-in patient, so a
      // caregiver is told who fell rather than a placeholder name.
      patient: authStore.user?.patientKey ?? 'unknown',
      onFall: _onFall,
    )..addListener(_onUpdate);
    _session.start();
  }

  void _onUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onFall() {
    if (!mounted) {
      return;
    }
    // Placeholder for the SOS screen. Deliberately a blocking dialog rather than
    // a toast: a confirmed fall must be acknowledged, not scroll past.
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded,
            color: AppColor.dangerText, size: 40),
        title: Text(t('session.fallTitle')),
        content: Text(t('session.fallBody')),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t('session.imOk')),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _session.removeListener(_onUpdate);
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedback = _session.feedback;

    return Scaffold(
      backgroundColor: AppColor.night,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            // Split roughly in half: demonstration above, the patient below.
            // Putting the guide on top matches how the movement is learned —
            // glance up to see it, look down to check yourself.
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    Space.lg, 0, Space.lg, Space.sm),
                child: DemoVideo(exerciseId: widget.exercise),
              ),
            ),
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Space.lg),
                child: _cameraStage(feedback),
              ),
            ),
            _footer(),
          ],
        ),
      ),
    );
  }

  /// Camera feed with the live readout laid over it.
  ///
  /// Overlaid rather than stacked below, because both need to be big: the camera
  /// has to be large enough to check your own position, and the rep count is the
  /// thing being read at a glance from across a room.
  Widget _cameraStage(PoseFeedback? feedback) {
    if (_session.error != null && feedback == null) {
      return _message(
        Icons.cloud_off,
        t('session.cannotReach'),
        _session.error!,
      );
    }
    if (!_session.ready || feedback == null) {
      return _message(
        null,
        t('session.gettingReady'),
        t('session.gettingReadySub'),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(Radii.lg),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _preview(),
          // Dark scrim, strongest at the bottom where the text sits, so the
          // readout stays legible whatever the camera happens to be showing.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
                stops: [0.25, 1.0],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Space.base),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (feedback.mode == ExerciseMode.hold)
                  ..._holdReadout(feedback)
                else
                  ..._repReadout(feedback),
                for (final cue in feedback.cues)
                  _cue(
                    cue.id == 'not_visible'
                        ? Icons.visibility_off
                        : Icons.error_outline,
                    cue.text,
                    cue.id == 'not_visible'
                        ? AppColor.brandLight
                        : AppColor.warning,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Space.lg, vertical: Space.md),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.chevron_left, color: AppColor.onNight),
            iconSize: 30,
            // Full 56dp target rather than the default 40.
            constraints: const BoxConstraints(
                minWidth: Sizes.target, minHeight: Sizes.target),
            style: IconButton.styleFrom(backgroundColor: AppColor.nightSurface),
          ),
          const SizedBox(width: Space.md),
          Expanded(
            child: Text(
              widget.title,
              style: AppText.title.copyWith(color: AppColor.onNight),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _statusPill(),
        ],
      ),
    );
  }

  Widget _statusPill() {
    final connected = _session.connected;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: 6),
      decoration: BoxDecoration(
        color: connected ? AppColor.successTint : AppColor.warningTint,
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Row(
        children: [
          Icon(
            connected ? Icons.check_circle : Icons.sync,
            size: 14,
            color: connected ? AppColor.success : AppColor.warningText,
          ),
          const SizedBox(width: Space.xs),
          Text(
            connected ? t('session.live') : t('session.connecting'),
            style: AppText.caption.copyWith(
              color: connected ? AppColor.success : AppColor.warningText,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _repReadout(PoseFeedback feedback) {
    return [
      Text(
        '${feedback.reps}',
        style: AppText.metric.copyWith(color: AppColor.brandLight, fontSize: 64, height: 1.05),
      ),
      Text(
        '${feedback.reps} / ${widget.targetReps} ${t('common.reps')}'.toUpperCase(),
        style: AppText.label.copyWith(color: AppColor.onNightMuted),
      ),
      const SizedBox(height: Space.md),
      Text(
        switch (feedback.phase) {
          RepPhase.up => '▲ ${t('session.up')}',
          RepPhase.down => '▼ ${t('session.down')}',
          RepPhase.unknown => '—',
        },
        style: AppText.subheading.copyWith(color: AppColor.onNight),
      ),
      if (feedback.formScore != null)
        Text(
          '${t('session.form')} ${(feedback.formScore! * 100).round()}%',
          style: AppText.body.copyWith(color: AppColor.onNightMuted),
        ),
    ];
  }

  /// A hold shows the live timer as the big number, and the best attempt beneath.
  /// The timer changes colour when the position breaks, so a patient can see at a
  /// glance whether the clock is running.
  List<Widget> _holdReadout(PoseFeedback feedback) {
    final holding = feedback.holding ?? false;
    final seconds = feedback.holdSeconds ?? 0;
    final best = feedback.bestHoldSeconds ?? 0;

    return [
      Text(
        seconds.toStringAsFixed(1),
        style: AppText.metric.copyWith(
          color: holding ? AppColor.brandLight : AppColor.onNightMuted,
          fontSize: 64,
          height: 1.05,
        ),
      ),
      Text(
        '${t('session.secondsHeld')} · ${t('session.target')} ${widget.targetSeconds}',
        style: AppText.label.copyWith(color: AppColor.onNightMuted),
      ),
      const SizedBox(height: Space.md),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            holding ? Icons.timer : Icons.pause_circle_outline,
            size: 20,
            color: holding ? AppColor.brandLight : AppColor.warning,
          ),
          const SizedBox(width: Space.sm),
          Text(
            holding ? t('session.holding') : t('session.getIntoPosition'),
            style: AppText.subheading.copyWith(
              color: holding ? AppColor.onNight : AppColor.warning,
            ),
          ),
        ],
      ),
      if (best > 0)
        Text(
          '${t('session.best')} ${best.toStringAsFixed(1)}s',
          style: AppText.body.copyWith(color: AppColor.onNightMuted),
        ),
    ];
  }

  /// Camera feed, filling whatever box it is given.
  ///
  /// previewSize comes back in sensor orientation — width and height swapped
  /// relative to the portrait screen — so they are exchanged here before the
  /// FittedBox crops to fill.
  Widget _preview() {
    final camera = _session.camera;
    if (camera == null || !camera.value.isInitialized) {
      return const ColoredBox(color: AppColor.nightSurface);
    }
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: camera.value.previewSize?.height ?? 240,
        height: camera.value.previewSize?.width ?? 320,
        child: CameraPreview(camera),
      ),
    );
  }

  Widget _cue(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: Space.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: Space.sm),
          Flexible(
            child: Text(
              text,
              style: AppText.body.copyWith(color: color),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _message(IconData? icon, String title, String body) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon == null)
              const CircularProgressIndicator(color: AppColor.brandLight)
            else
              Icon(icon, size: 44, color: AppColor.onNightMuted),
            const SizedBox(height: Space.base),
            Text(
              title,
              style: AppText.heading.copyWith(color: AppColor.onNight),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Space.sm),
            Text(
              body,
              style: AppText.body.copyWith(color: AppColor.onNightMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _footer() {
    final feedback = _session.feedback;
    final isHold = widget.mode == ExerciseMode.hold;
    final best = feedback?.bestHoldSeconds ?? 0;
    final reps = feedback?.reps ?? 0;
    final label = isHold
        ? (best > 0 ? '${t('session.finish')} · ${best.toStringAsFixed(1)}s' : t('session.end'))
        : (reps > 0 ? '${t('session.finish')} · $reps ${t('common.reps')}' : t('session.end'));
    return Padding(
      padding: const EdgeInsets.all(Space.lg),
      child: Column(
        children: [
          Text(
            '${t('session.sent')} ${_session.framesSent} · ${t('session.dropped')} ${_session.framesDropped}',
            style: AppText.caption.copyWith(color: AppColor.onNightMuted),
          ),
          const SizedBox(height: Space.md),
          FilledButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}
