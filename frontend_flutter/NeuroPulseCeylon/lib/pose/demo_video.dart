import 'package:flutter/material.dart';

import '../features/i18n.dart';
import 'package:video_player/video_player.dart';

import '../ui/tokens.dart';

/// Which demonstration clip belongs to which exercise.
///
/// Left and right variants share a clip — the reference footage only ever shows
/// one side, and mirroring it would be more confusing than helpful.
///
/// Exercises absent from this map have no clip in the library. They show an
/// honest placeholder rather than someone else's exercise.
const Map<String, String> demoClips = {
  'shoulder_flexion_left': 'assets/videos/shoulder_flexion.mp4',
  'shoulder_flexion_right': 'assets/videos/shoulder_flexion.mp4',
  'elbow_extension_left': 'assets/videos/elbow_extension.mp4',
  'elbow_extension_right': 'assets/videos/elbow_extension.mp4',
  'straight_leg_raise_left': 'assets/videos/straight_leg_raise.mp4',
  'straight_leg_raise_right': 'assets/videos/straight_leg_raise.mp4',
  'hamstring_curl_supine': 'assets/videos/hamstring_curl_supine.mp4',
  'hamstring_curl_prone': 'assets/videos/hamstring_curl_prone.mp4',
  'hamstring_curl_seated': 'assets/videos/hamstring_curl_seated.mp4',
  'romanian_deadlift_single_leg':
      'assets/videos/romanian_deadlift_single_leg.mp4',
  'single_leg_stance': 'assets/videos/single_leg_stance.mp4',
  // knee_extension_left/right and sit_to_stand: no clip exists.
};

/// Looping, muted demonstration video shown above the camera.
///
/// Muted and looping on purpose: the patient needs to glance up and copy the
/// movement repeatedly, and narration competing with the app's own coaching cues
/// would be worse than silence. There are deliberately no playback controls —
/// one less thing to press by accident mid-exercise.
class DemoVideo extends StatefulWidget {
  const DemoVideo({super.key, required this.exerciseId});

  final String exerciseId;

  @override
  State<DemoVideo> createState() => _DemoVideoState();
}

class _DemoVideoState extends State<DemoVideo> {
  VideoPlayerController? _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    final asset = demoClips[widget.exerciseId];
    if (asset == null) {
      return;
    }
    final controller = VideoPlayerController.asset(asset);
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.play();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } catch (_) {
      await controller.dispose();
      // A missing or unplayable clip must not take the session down with it —
      // the tracking is the point, the video is the aid.
      if (mounted) {
        setState(() => _failed = true);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    if (controller != null && controller.value.isInitialized) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(Radii.lg),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // contain, NOT cover. Cropping a demonstration defeats its purpose:
            // cover filled the box by cutting the frame down to the torso, hiding
            // the limb the patient is supposed to be copying. Letterboxing is the
            // right trade here.
            ColoredBox(
              color: AppColor.night,
              child: Center(
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              ),
            ),
            Positioned(
              left: Space.md,
              top: Space.md,
              child: _Chip(
                label: t('session.followAlong'),
                icon: Icons.play_circle,
              ),
            ),
          ],
        ),
      );
    }

    final noClip = demoClips[widget.exerciseId] == null;
    return Container(
      decoration: BoxDecoration(
        color: AppColor.nightSurface,
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      child: Center(
        child: noClip || _failed
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.videocam_off,
                      size: 34, color: AppColor.onNightMuted),
                  const SizedBox(height: Space.sm),
                  Text(
                    noClip
                        ? t('session.noDemo')
                        : t('session.demoUnavailable'),
                    style: AppText.caption
                        .copyWith(color: AppColor.onNightMuted),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : const CircularProgressIndicator(color: AppColor.brandLight),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: 5),
      decoration: BoxDecoration(
        // Scrim so the label stays readable whatever the frame behind it shows.
        color: Colors.black54,
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: Space.xs),
          Text(label, style: AppText.caption.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}
