import 'package:flutter/material.dart';

import '../features/i18n.dart';

import '../routes.dart';
import '../ui/tokens.dart';
import '../ui/widgets.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  static const _entries = <(String, int, bool)>[
    ('John Fernando', 2450, true),
    ('Nimal Perera', 2200, false),
    ('Sarah Silva', 1980, false),
    ('Amal Fernando', 1800, false),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      children: [
        AppHeader(
          title: t('lead.title'),
          subtitle: t('lead.subtitle'),
          back: true,
        ),
        for (var i = 0; i < _entries.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.md),
            child: AppListRow(
              title: _entries[i].$1,
              meta: '${_entries[i].$2} ${t('lead.points')}',
              icon: i == 0 ? Icons.emoji_events : Icons.workspace_premium,
              iconBackground:
                  i == 0 ? AppColor.warningTint : AppColor.brandTint,
              iconColor: i == 0 ? AppColor.warningText : AppColor.brandText,
              highlight: _entries[i].$3,
              showChevron: false,
              trailing: _entries[i].$3
                  ? AppBadge(t('lead.you'), tone: BadgeTone.brand)
                  : null,
            ),
          ),
        SectionHeader(t('lead.motivation')),
        AppCard(
          accent: AppColor.brand,
          child: Text(
            t('lead.motivationBody'),
            style: AppText.body,
          ),
        ),
      ],
    );
  }
}

/// Every number here is invented — nothing computes trends or predictions yet.
/// The "recovery prediction" is framed as an illustration rather than a forecast:
/// telling a stroke patient they will be 85% recovered in six weeks is a clinical
/// claim, and being wrong in either direction causes real harm.
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  static List<(IconData, String, String)> get _cards => [
    (Icons.trending_up, t('ins.weekly'), t('ins.weeklyBody')),
    (Icons.fitness_center, t('ins.recommended'), t('ins.recommendedBody')),
    (Icons.visibility, t('ins.observation'), t('ins.observationBody')),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      children: [
        AppHeader(
          title: t('ins.title'),
          subtitle: t('ins.subtitle'),
          back: true,
        ),
        AppCard(
          accent: AppColor.warning,
          child: AppBadge(t('ins.illustrative'),
              tone: BadgeTone.warning, icon: Icons.info_outline),
        ),
        const SizedBox(height: Space.md),
        for (final card in _cards)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.md),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColor.brandTint,
                          borderRadius: BorderRadius.circular(Radii.sm),
                        ),
                        child: Icon(card.$1,
                            size: 22, color: AppColor.brandText),
                      ),
                      const SizedBox(width: Space.md),
                      Expanded(
                        child: Text(card.$2, style: AppText.subheading),
                      ),
                    ],
                  ),
                  const SizedBox(height: Space.sm),
                  Text(card.$3,
                      style:
                          AppText.body.copyWith(color: AppColor.inkMuted)),
                ],
              ),
            ),
          ),
        SectionHeader(t('ins.outlook')),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('85%',
                  style:
                      AppText.display.copyWith(color: AppColor.brandText)),
              const SizedBox(height: Space.sm),
              Text(
                t('ins.outlookBody'),
                style: AppText.body.copyWith(color: AppColor.inkMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// None of these games are implemented. The rows say so when tapped, rather than
/// each showing a START button that does nothing — a dead button is worse than an
/// honest one for a user who will assume they pressed it wrong.
class BrainTrainingScreen extends StatelessWidget {
  const BrainTrainingScreen({super.key});

  static List<(String, String, IconData)> get _activities => [
    (t('brain.memory'), t('brain.memorySub'), Icons.grid_view),
    (t('brain.reaction'), t('brain.reactionSub'), Icons.bolt),
    (t('brain.focus'), t('brain.focusSub'), Icons.visibility),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      children: [
        AppHeader(
          title: t('brain.title'),
          subtitle: t('brain.subtitle'),
          back: true,
        ),
        AppCard(
          accent: AppColor.warning,
          child: AppBadge(t('common.comingSoon'),
              tone: BadgeTone.warning, icon: Icons.construction),
        ),
        const SizedBox(height: Space.md),
        for (final activity in _activities)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.md),
            child: AppListRow(
              title: activity.$1,
              subtitle: activity.$2,
              icon: activity.$3,
              onTap: () => showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(activity.$1),
                  content:
                      Text(t('brain.notAvailable')),
                  actions: [
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(t('common.ok')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        SectionHeader(t('brain.why')),
        AppCard(
          child: Text(
            t('brain.whyBody'),
            style: AppText.body,
          ),
        ),
      ],
    );
  }
}

/// Speech recognition is not wired up — the microphone state is local only. The
/// button reflects that rather than implying the app is listening.
class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  bool _listening = false;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      footer: FilledButton.icon(
        onPressed: () => setState(() => _listening = !_listening),
        icon: Icon(_listening ? Icons.stop : Icons.mic),
        label: Text(_listening ? t('voice.stop') : t('voice.start')),
        style: _listening
            ? FilledButton.styleFrom(backgroundColor: AppColor.danger)
            : null,
      ),
      children: [
        AppHeader(
          title: t('voice.title'),
          subtitle: t('voice.subtitle'),
          back: true,
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Space.xl),
            child: Column(
              children: [
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: _listening
                        ? AppColor.brandStrong
                        : AppColor.brandTint,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColor.brandTintStrong, width: 8),
                  ),
                  child: Icon(Icons.mic,
                      size: 62,
                      color: _listening
                          ? Colors.white
                          : AppColor.brandText),
                ),
                const SizedBox(height: Space.base),
                Text(
                  _listening
                      ? t('voice.listening')
                      : t('voice.tapToStart'),
                  style: AppText.subheading.copyWith(
                    color: _listening
                        ? AppColor.brandText
                        : AppColor.inkMuted,
                  ),
                ),
                const SizedBox(height: Space.sm),
                AppBadge(t('voice.notWired'),
                    tone: BadgeTone.warning, icon: Icons.info_outline),
              ],
            ),
          ),
        ),
        SectionHeader(t('voice.trySaying')),
        AppCard(
          child: Bullets(
            [
              t('voice.cmdStart'),
              t('voice.cmdCall'),
              t('voice.cmdProgress'),
              t('voice.cmdHelp'),
            ],
            icon: Icons.chat_bubble_outline,
          ),
        ),
      ],
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _messages = <(bool, String)>[
    (false, t('chat.m1')),
    (true, t('chat.m2')),
    (false, t('chat.m3')),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add((true, text));
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Space.lg),
              child: AppHeader(
                title: 'Dr. Sarah Jenkins',
                subtitle: t('chat.online'),
                back: true,
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(Space.lg),
                children: [
                  for (final message in _messages)
                    Align(
                      alignment: message.$1
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth:
                              MediaQuery.of(context).size.width * 0.78,
                        ),
                        margin: const EdgeInsets.only(bottom: Space.md),
                        padding: const EdgeInsets.all(Space.base),
                        decoration: BoxDecoration(
                          color: message.$1
                              ? AppColor.brandStrong
                              : AppColor.surface,
                          borderRadius: BorderRadius.circular(Radii.lg),
                        ),
                        child: Text(
                          message.$2,
                          style: AppText.body.copyWith(
                            color: message.$1
                                ? Colors.white
                                : AppColor.ink,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(Space.md),
              decoration: const BoxDecoration(
                color: AppColor.surface,
                border: Border(top: BorderSide(color: AppColor.border)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: 4,
                      minLines: 1,
                      style: AppText.body,
                      decoration: InputDecoration(
                        hintText: t('chat.type'),
                        filled: true,
                        fillColor: AppColor.surfaceSunken,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Radii.md),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: Space.md),
                  SizedBox(
                    width: Sizes.target,
                    height: Sizes.target,
                    child: IconButton(
                      onPressed: _send,
                      icon: const Icon(Icons.send),
                      tooltip: t('chat.send'),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColor.brandStrong,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Radii.md),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Static detail and demo screens for an exercise. The tracked session with real
/// rep counting is the session screen, and these route there rather than
/// pretending to track anything themselves.
class ExerciseDetailsScreen extends StatelessWidget {
  const ExerciseDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      footer: Column(
        children: [
          FilledButton.icon(
            onPressed: () =>
                Navigator.of(context).pushNamed(Routes.exerciseLibrary),
            icon: const Icon(Icons.play_arrow),
            label: Text(t('det.startTracked')),
          ),
          const SizedBox(height: Space.sm),
          OutlinedButton.icon(
            onPressed: () =>
                Navigator.of(context).pushNamed(Routes.exerciseVideo),
            icon: const Icon(Icons.videocam),
            label: Text(t('det.watchDemo')),
          ),
        ],
      ),
      children: [
        AppHeader(title: t('det.shoulderMobility'), back: true),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBadge(t('det.beginner'),
                  tone: BadgeTone.brand, icon: Icons.military_tech),
              SizedBox(height: Space.sm),
              Text(
                t('about.overviewBody'),
                style: AppText.body,
              ),
              SizedBox(height: Space.sm),
              Text('${t('det.duration')}: 15', style: AppText.caption),
            ],
          ),
        ),
        SectionHeader(t('det.instructions')),
        AppCard(
          child: Bullets(
            [
              t('step.sit'),
              t('step.backStraight'),
              t('step.raiseArm'),
              t('step.hold3'),
              t('step.lower'),
              t('step.repeat10'),
            ],
            icon: Icons.check_circle,
            tone: BadgeTone.success,
          ),
        ),
        SectionHeader(t('det.safety')),
        AppCard(
          child: Text(
            t('det.safetyBody'),
            style: AppText.body,
          ),
        ),
      ],
    );
  }
}

class ExerciseVideoScreen extends StatelessWidget {
  const ExerciseVideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      footer: FilledButton.icon(
        onPressed: () =>
            Navigator.of(context).pushNamed(Routes.exerciseLibrary),
        icon: const Icon(Icons.play_arrow),
        label: Text(t('det.startTracked')),
      ),
      children: [
        AppHeader(
          title: t('det.shoulderMobility'),
          subtitle: t('det.sessionSubtitle'),
          back: true,
        ),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppColor.surfaceSunken,
            borderRadius: BorderRadius.circular(Radii.lg),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videocam, size: 46, color: AppColor.inkDisabled),
              SizedBox(height: Space.xs),
              Text(t('det.demoVideo'), style: AppText.bodyStrong),
              Text(t('det.playerNotConnected'), style: AppText.caption),
            ],
          ),
        ),
        SectionHeader(t('det.instructions')),
        AppCard(
          child: Bullets(
            [
              t('step.sit'),
              t('step.backStraight'),
              t('step.raiseArm'),
              t('step.hold3'),
              t('step.lower'),
              t('step.stopIfPain'),
            ],
            icon: Icons.check_circle,
            tone: BadgeTone.success,
          ),
        ),
        SectionHeader(t('det.benefits')),
        AppCard(
          child: Bullets([
            t('benefit.mobility'),
            t('benefit.strength'),
            t('benefit.coordination'),
            t('benefit.recovery'),
          ]),
        ),
      ],
    );
  }
}
