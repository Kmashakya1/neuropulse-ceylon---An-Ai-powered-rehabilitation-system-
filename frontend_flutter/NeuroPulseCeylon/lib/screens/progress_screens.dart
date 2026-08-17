import 'package:flutter/material.dart';

import '../features/i18n.dart';

import '../features/session_log.dart';
import '../routes.dart';
import '../ui/bottom_nav.dart';
import '../ui/tokens.dart';
import '../ui/widgets.dart';

/// Reads today's real session log. Longer-term figures are still placeholders and
/// are labelled as such — showing an invented "78% recovery" to a stroke patient
/// as if it were clinical fact shapes how they feel about their own recovery.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  Map<String, SessionRecord> _today = {};

  @override
  void initState() {
    super.initState();
    SessionLog.today().then((records) {
      if (mounted) setState(() => _today = records);
    });
  }

  @override
  Widget build(BuildContext context) {
    final records = _today.values.toList();
    final completed = records.where((r) => r.complete).length;
    final totalReps = records.fold<int>(0, (sum, r) => sum + r.reps);
    final scored =
        records.where((r) => r.meanFormScore != null).toList();
    final meanForm = scored.isEmpty
        ? null
        : (scored.fold<double>(0, (s, r) => s + r.meanFormScore!) /
                scored.length *
                100)
            .round();

    return AppScaffold(
      bottomNav: const AppBottomNav(active: 'progress'),
      children: [
        AppHeader(
          title: t('prog.title'),
          subtitle: t('prog.subtitle'),
        ),
        SectionHeader(t('prog.today'), meta: t('prog.fromTracked')),
        if (records.isEmpty)
          AppCard(
            child: Row(
              children: [
                Icon(Icons.bar_chart, size: 30, color: AppColor.inkSubtle),
                SizedBox(width: Space.base),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t('prog.noSessions'), style: AppText.subheading),
                      Text(t('prog.noSessionsSub'), style: AppText.caption),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          Row(
            children: [
              StatTile(
                value: '$completed',
                label: t('prog.completed'),
                tone: BadgeTone.success,
                icon: Icons.check_circle,
              ),
              const SizedBox(width: Space.md),
              StatTile(
                value: '$totalReps',
                label: t('prog.totalReps'),
                icon: Icons.repeat,
              ),
              if (meanForm != null) ...[
                const SizedBox(width: Space.md),
                StatTile(
                  value: '$meanForm%',
                  label: t('prog.averageForm'),
                  icon: Icons.auto_awesome,
                ),
              ],
            ],
          ),
        SectionHeader(t('prog.longerTerm')),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBadge(t('prog.sampleFigures'),
                  tone: BadgeTone.warning, icon: Icons.info_outline),
              const SizedBox(height: Space.base),
              Row(
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColor.brandTintStrong, width: 6),
                    ),
                    child: Center(
                      child: Text('78%',
                          style: AppText.heading
                              .copyWith(color: AppColor.brandText)),
                    ),
                  ),
                  const SizedBox(width: Space.base),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t('prog.improvement'), style: AppText.subheading),
                        Text(t('prog.placeholder'), style: AppText.caption),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Space.base),
              Row(
                children: [
                  StatTile(
                      value: '5 / 7',
                      label: t('prog.weekly'),
                      icon: Icons.calendar_month),
                  SizedBox(width: Space.md),
                  StatTile(
                      value: '14',
                      label: t('prog.streak'),
                      tone: BadgeTone.warning,
                      icon: Icons.local_fire_department),
                ],
              ),
            ],
          ),
        ),
        SectionHeader(t('prog.coachFeedback')),
        AppCard(
          accent: AppColor.brand,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t('prog.movementQuality'), style: AppText.subheading),
              SizedBox(height: Space.sm),
              Text(
                t('prog.feedbackBody'),
                style: AppText.body,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Today's rows come from the real log; older ones are the original sample
/// content, labelled, because nothing syncs to the backend yet.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Map<String, SessionRecord> _today = {};

  @override
  void initState() {
    super.initState();
    SessionLog.today().then((r) {
      if (mounted) setState(() => _today = r);
    });
  }

  @override
  Widget build(BuildContext context) {
    final records = _today.values.toList()
      ..sort((a, b) => b.endedAt.compareTo(a.endedAt));

    return AppScaffold(
      children: [
        AppHeader(
          title: t('hist.title'),
          subtitle: t('hist.subtitle'),
          back: true,
        ),
        SectionHeader(t('prog.today'), meta: '${records.length} ${t('common.sessions')}'),
        if (records.isEmpty)
          AppCard(
            child: Text(t('hist.noneToday'), style: AppText.body),
          )
        else
          for (final record in records)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.md),
              child: AppListRow(
                title: record.exerciseId.replaceAll('_', ' '),
                meta: '${record.reps} / ${record.targetReps} ${t('common.reps')}',
                subtitle: TimeOfDay.fromDateTime(record.endedAt)
                    .format(context),
                icon: record.complete ? Icons.check_circle : Icons.schedule,
                iconBackground: record.complete
                    ? AppColor.successTint
                    : AppColor.warningTint,
                iconColor:
                    record.complete ? AppColor.success : AppColor.warningText,
                showChevron: false,
                child: record.meanFormScore == null
                    ? null
                    : AppBadge(
                        '${t('hist.form')} ${(record.meanFormScore! * 100).round()}%',
                        tone: BadgeTone.brand,
                      ),
              ),
            ),
        SectionHeader(t('hist.earlier')),
        AppCard(
          child: AppBadge(t('hist.sampleNote'),
              tone: BadgeTone.warning, icon: Icons.info_outline),
        ),
        const SizedBox(height: Space.md),
        for (final sample in [
          (t('sched.balance'), '${t('day.yesterday')} · 4:00 PM', '88%'),
          (t('hist.armCoord'), '${t('day.monday')} · 9:15 AM', '90%'),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: Space.md),
            child: AppListRow(
              title: sample.$1,
              meta: '${t('hist.accuracy')} ${sample.$3}',
              subtitle: sample.$2,
              icon: Icons.check_circle,
              iconBackground: AppColor.surfaceSunken,
              iconColor: AppColor.inkSubtle,
              showChevron: false,
            ),
          ),
      ],
    );
  }
}

/// Today's plan. Not wired to the session log, so it does not know what has
/// actually been completed — the badge says so rather than leaving it implied.
class MyPlanScreen extends StatelessWidget {
  const MyPlanScreen({super.key});

  static List<(String, String, IconData)> get _plan => [
    (t('plan.shoulder'), '15 ${t('plan.minutes')}', Icons.accessibility_new),
    (t('plan.walking'), '10 ${t('plan.minutes')}', Icons.directions_walk),
    (t('plan.grip'), '5 ${t('plan.minutes')}', Icons.back_hand),
    (t('plan.breathing'), '8 ${t('plan.minutes')}', Icons.air),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      bottomNav: const AppBottomNav(active: 'plan'),
      children: [
        AppHeader(
          title: t('plan.title'),
          subtitle: t('plan.subtitle'),
        ),
        const AppCard(
          child: AppBadge('Not yet linked to your tracked sessions',
              tone: BadgeTone.warning, icon: Icons.info_outline),
        ),
        SectionHeader(t('plan.scheduled'), meta: '${_plan.length} ${t('plan.activities')}'),
        for (final item in _plan)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.md),
            child: AppListRow(
              title: item.$1,
              meta: item.$2,
              icon: item.$3,
              showChevron: false,
            ),
          ),
        SectionHeader(t('plan.tracked')),
        AppListRow(
          title: t('plan.startToday'),
          subtitle: t('plan.startTodaySub'),
          icon: Icons.play_circle,
          onTap: () =>
              Navigator.of(context).pushNamed(Routes.exerciseLibrary),
        ),
      ],
    );
  }
}
