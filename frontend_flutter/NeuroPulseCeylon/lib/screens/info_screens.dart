import 'package:flutter/material.dart';

import '../features/i18n.dart';

import '../routes.dart';
import '../ui/tokens.dart';
import '../ui/widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  /// The React Native original used emoji as the anchor for each row. Emoji render
  /// inconsistently across Android versions and are not reliably announced by
  /// screen readers, so these are icons with tinted chips.
  static List<(String, String, IconData, Color, Color, String?)> get _items => [
    (
      t('cg.medReminder'),
      t('notif.medBody'),
      Icons.medical_information,
      AppColor.warningTint,
      AppColor.warningText,
      null
    ),
    (
      t('notif.sessionDue'),
      t('notif.sessionBody'),
      Icons.accessibility_new,
      AppColor.brandTint,
      AppColor.brandText,
      Routes.exerciseLibrary
    ),
    (
      t('notif.insight'),
      t('notif.insightBody'),
      Icons.auto_awesome,
      const Color(0xFFDBEAFE),
      const Color(0xFF1E40AF),
      Routes.progress
    ),
    (
      t('notif.physioMsg'),
      t('notif.physioMsgBody'),
      Icons.chat_bubble_outline,
      AppColor.successTint,
      AppColor.success,
      Routes.chat
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      children: [
        AppHeader(
          title: t('notif.title'),
          subtitle: t('notif.subtitle'),
          back: true,
        ),
        for (final item in _items)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.md),
            child: AppListRow(
              title: item.$1,
              subtitle: item.$2,
              icon: item.$3,
              iconBackground: item.$4,
              iconColor: item.$5,
              showChevron: item.$6 != null,
              onTap: item.$6 == null
                  ? null
                  : () => Navigator.of(context).pushNamed(item.$6!),
            ),
          ),
      ],
    );
  }
}

/// Every figure here is invented — nothing computes a recovery or improvement
/// rate yet. Stated at the top rather than in small print, because a document
/// titled "Recovery Report" reads as clinical output.
class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      children: [
        AppHeader(
          title: t('report.title'),
          subtitle: t('report.subtitle'),
          back: true,
        ),
        AppCard(
          accent: AppColor.warning,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBadge(t('report.sample'),
                  tone: BadgeTone.warning,
                  icon: Icons.warning_amber_rounded),
              SizedBox(height: Space.sm),
              Text(
                t('report.notClinical'),
                style: AppText.caption,
              ),
            ],
          ),
        ),
        SectionHeader(t('cg.patient')),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FieldRow(t('report.name'), 'John Fernando'),
              FieldRow(t('profile.age'), '62'),
              FieldRow(t('profile.strokeType'), t('profile.ischemic')),
            ],
          ),
        ),
        SectionHeader(t('report.statistics')),
        Row(
          children: [
            StatTile(value: '92%', label: t('report.accuracy')),
            SizedBox(width: Space.md),
            StatTile(
                value: '5 / 7',
                label: t('prog.weekly'),
                tone: BadgeTone.success),
            SizedBox(width: Space.md),
            StatTile(
                value: '78%',
                label: t('report.improvementRate'),
                tone: BadgeTone.warning),
          ],
        ),
        SectionHeader(t('report.summary')),
        AppCard(
          child: Text(
            t('report.summaryBody'),
            style: AppText.body,
          ),
        ),
        SectionHeader(t('report.physioNotes')),
        AppCard(
          child: Text(
            t('report.physioNotesBody'),
            style: AppText.body,
          ),
        ),
      ],
    );
  }
}

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  static List<(String, String, String)> get _sessions => [
    ('${t('day.monday')} · 9:30 AM', t('sched.upperLimb'),
        '${t('sched.physioLabel')}: Dr. Sarah Jenkins'),
    ('${t('day.tuesday')} · 11:00 AM', t('sched.balance'),
        '30 ${t('plan.minutes')}'),
    ('${t('day.wednesday')} · 2:00 PM', t('sched.mobility'),
        t('sched.guided')),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      children: [
        AppHeader(
          title: t('sched.title'),
          subtitle: t('sched.subtitle'),
          back: true,
        ),
        SectionHeader(t('sched.thisWeek'), meta: '${_sessions.length} ${t('common.sessions')}'),
        for (final session in _sessions)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.md),
            child: AppListRow(
              title: session.$2,
              meta: session.$1,
              subtitle: session.$3,
              icon: Icons.calendar_month,
              showChevron: false,
            ),
          ),
        SectionHeader(t('sched.reminder')),
        AppCard(
          accent: AppColor.brand,
          child: Text(
            t('sched.reminderBody'),
            style: AppText.body,
          ),
        ),
      ],
    );
  }
}

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  static List<String> get _slots => [
    '${t('day.tuesday')} · 10:00 AM',
    '${t('day.wednesday')} · 1:30 PM',
    '${t('day.thursday')} · 11:00 AM',
  ];

  String? _selected;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      footer: FilledButton.icon(
        onPressed: _selected == null
            ? null
            : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${t('appt.requested')} $_selected')),
                );
                setState(() => _selected = null);
              },
        icon: const Icon(Icons.calendar_month),
        label: Text(_selected == null
            ? t('appt.selectSlot')
            : '${t('appt.book')} $_selected'),
      ),
      children: [
        AppHeader(
          title: t('appt.title'),
          subtitle: t('appt.subtitle'),
          back: true,
        ),
        SectionHeader(t('appt.upcoming')),
        AppCard(
          accent: AppColor.brand,
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColor.brandTint,
                  borderRadius: BorderRadius.circular(Radii.md),
                ),
                child: const Icon(Icons.person,
                    size: 28, color: AppColor.brandText),
              ),
              const SizedBox(width: Space.base),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dr. Sarah Jenkins', style: AppText.subheading),
                    Text('${t('day.monday')} · 9:30 AM', style: AppText.bodyStrong),
                    Text(t('appt.unit'), style: AppText.caption),
                  ],
                ),
              ),
            ],
          ),
        ),
        SectionHeader(t('appt.availableSlots')),
        for (final slot in _slots)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.md),
            child: AppListRow(
              title: slot,
              icon: _selected == slot ? Icons.check_circle : Icons.schedule,
              iconBackground: _selected == slot
                  ? AppColor.brandStrong
                  : AppColor.surfaceSunken,
              iconColor:
                  _selected == slot ? Colors.white : AppColor.inkSubtle,
              highlight: _selected == slot,
              showChevron: false,
              onTap: () => setState(
                  () => _selected = _selected == slot ? null : slot),
              trailing: _selected == slot
                  ? AppBadge(t('appt.selected'), tone: BadgeTone.brand)
                  : null,
            ),
          ),
      ],
    );
  }
}

/// Was the untouched Flutter counter demo. Now a directory of the features that
/// actually exist, which is what a screen with this name ought to be.
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  static List<(String, List<(String, String, IconData, String)>)> get _groups => [
    (
      t('explore.rehab'),
      [
        (t('ex.title'), t('plan.startTodaySub'), Icons.accessibility_new,
            Routes.exerciseLibrary),
        (t('brain.title'), t('brain.subtitle'), Icons.lightbulb_outline,
            Routes.brainTraining),
        (t('voice.title'), t('voice.subtitle'), Icons.mic,
            Routes.voiceAssistant),
        (t('explore.guide'), t('explore.guideSub'), Icons.menu_book,
            Routes.exerciseDetails),
      ]
    ),
    (
      t('explore.tracking'),
      [
        (t('prog.title'), t('prog.subtitle'), Icons.show_chart,
            Routes.progress),
        (t('hist.title'), t('hist.subtitle'), Icons.schedule, Routes.history),
        (t('ins.title'), t('ins.subtitle'), Icons.auto_awesome,
            Routes.insights),
        (t('lead.title'), t('lead.subtitle'), Icons.emoji_events,
            Routes.leaderboard),
      ]
    ),
    (
      t('explore.support'),
      [
        (t('care.title'), t('care.subtitle'), Icons.medical_services,
            Routes.care),
        (t('appt.title'), t('appt.subtitle'), Icons.calendar_month,
            Routes.appointments),
        (t('sched.title'), t('sched.subtitle'), Icons.event_available,
            Routes.schedule),
        (t('profile.help'), t('help.subtitle'), Icons.help_outline,
            Routes.help),
      ]
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      children: [
        AppHeader(
          title: t('explore.title'),
          subtitle: t('explore.subtitle'),
          back: true,
        ),
        for (final group in _groups) ...[
          SectionHeader(group.$1),
          for (final entry in group.$2)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.md),
              child: AppListRow(
                title: entry.$1,
                subtitle: entry.$2,
                icon: entry.$3,
                onTap: () => Navigator.of(context).pushNamed(entry.$4),
              ),
            ),
        ],
      ],
    );
  }
}
