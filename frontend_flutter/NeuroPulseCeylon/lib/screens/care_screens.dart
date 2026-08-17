import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../features/i18n.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../routes.dart';
import '../ui/bottom_nav.dart';
import '../ui/tokens.dart';
import '../ui/widgets.dart';

class CareScreen extends StatelessWidget {
  const CareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      bottomNav: const AppBottomNav(active: 'care'),
      children: [
        AppHeader(
          title: t('care.title'),
          subtitle: t('care.subtitle'),
        ),
        AppCard(
          accent: AppColor.brand,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: Sizes.chip,
                    height: Sizes.chip,
                    decoration: BoxDecoration(
                      color: AppColor.brandTint,
                      borderRadius: BorderRadius.circular(Radii.md),
                    ),
                    child: const Icon(Icons.medical_services,
                        size: 28, color: AppColor.brandText),
                  ),
                  const SizedBox(width: Space.base),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t('care.assignedPhysio'), style: AppText.caption),
                        Text('Dr. Sarah Jenkins', style: AppText.subheading),
                        SizedBox(height: Space.xs),
                        AppBadge(t('care.availableNow'),
                            tone: BadgeTone.success, icon: Icons.circle),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Space.base),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pushNamed(Routes.chat),
                icon: const Icon(Icons.chat_bubble_outline),
                label: Text(t('care.chatNow')),
              ),
            ],
          ),
        ),
        SectionHeader(t('prog.today')),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t('care.dailyReport'), style: AppText.subheading),
              SizedBox(height: Space.sm),
              Text(t('care.dailyReportBody'), style: AppText.body),
            ],
          ),
        ),
        const SizedBox(height: Space.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t('care.advice'), style: AppText.subheading),
              SizedBox(height: Space.sm),
              Text(
                t('care.adviceBody'),
                style: AppText.body,
              ),
            ],
          ),
        ),
        SectionHeader(t('dash.emergency')),
        AppCard(
          accent: AppColor.danger,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t('care.emergencyAssist'), style: AppText.subheading),
              const SizedBox(height: Space.sm),
              Text(t('care.emergencyAssistBody'), style: AppText.body),
              const SizedBox(height: Space.base),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pushNamed(Routes.sos),
                icon: const Icon(Icons.warning_amber_rounded),
                label: Text(t('dash.sos')),
                style: FilledButton.styleFrom(
                    backgroundColor: AppColor.danger),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Polls the Node backend for the latest fall alert. When one arrives it takes
/// over the top of the screen — a caregiver scanning this needs the alert to be
/// impossible to miss.
class CaregiverDashboardScreen extends StatefulWidget {
  const CaregiverDashboardScreen({super.key});

  @override
  State<CaregiverDashboardScreen> createState() =>
      _CaregiverDashboardScreenState();
}

class _CaregiverDashboardScreenState extends State<CaregiverDashboardScreen> {
  Timer? _timer;
  Map<String, dynamic>? _alert;
  bool? _reachable;

  @override
  void initState() {
    super.initState();
    _poll();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _poll());
  }

  Future<void> _poll() async {
    try {
      final response =
          await http.get(alertsLatestUri()).timeout(const Duration(seconds: 5));
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _reachable = true;
        _alert = data['status'] == 'Fall Detected' ? data : null;
      });
    } catch (_) {
      if (mounted) setState(() => _reachable = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      children: [
        AppHeader(
          title: t('cg.title'),
          subtitle: t('cg.subtitle'),
          back: true,
        ),
        if (_alert != null)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.md),
            child: AppCard(
              accent: AppColor.danger,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppBadge(t('cg.fallAlert'),
                      tone: BadgeTone.danger,
                      icon: Icons.warning_amber_rounded),
                  const SizedBox(height: Space.sm),
                  Text('${_alert!['patient']} ${t('cg.mayHaveFallen')}',
                      style: AppText.heading),
                  Text(t('cg.immediate'), style: AppText.body),
                  const SizedBox(height: Space.base),
                  FilledButton.icon(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(Routes.sos),
                    icon: const Icon(Icons.call),
                    label: Text(t('cg.openEmergency')),
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColor.danger),
                  ),
                ],
              ),
            ),
          ),
        if (_reachable == false)
          AppCard(
            accent: AppColor.warning,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBadge(t('cg.cannotReachAlerts'),
                    tone: BadgeTone.warning, icon: Icons.cloud_off),
                SizedBox(height: Space.sm),
                Text(t('cg.alertsPaused'), style: AppText.caption),
              ],
            ),
          ),
        SectionHeader(t('cg.patient')),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('John Fernando', style: AppText.heading),
              SizedBox(height: Space.base),
              Row(
                children: [
                  StatTile(value: '78%', label: t('cg.recoveryProgress')),
                  SizedBox(width: Space.md),
                  StatTile(
                      value: '10:30',
                      label: t('cg.lastSessionToday'),
                      tone: BadgeTone.success),
                ],
              ),
            ],
          ),
        ),
        SectionHeader(t('cg.reminders')),
        AppListRow(
          title: t('cg.medReminder'),
          meta: '7:00 PM',
          subtitle: t('cg.bpMed'),
          icon: Icons.medical_information,
          iconBackground: AppColor.warningTint,
          iconColor: AppColor.warningText,
          showChevron: false,
        ),
        const SizedBox(height: Space.md),
        AppListRow(
          title: t('cg.upcomingTherapy'),
          meta: '${t('day.tomorrow')} · 9:30 AM',
          icon: Icons.calendar_month,
          showChevron: false,
        ),
        const SizedBox(height: Space.lg),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pushNamed(Routes.chat),
          icon: const Icon(Icons.chat_bubble_outline),
          label: Text(t('cg.contactPhysio')),
        ),
        const LogoutRow(),
      ],
    );
  }
}

class PhysioDashboardScreen extends StatelessWidget {
  const PhysioDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      children: [
        AppHeader(
          title: t('physio.title'),
          subtitle: t('physio.subtitle'),
          back: true,
        ),
        Row(
          children: [
            StatTile(value: '24', label: t('physio.patients'), icon: Icons.groups),
            SizedBox(width: Space.md),
            StatTile(
                value: '6',
                label: t('physio.sessionsToday'),
                tone: BadgeTone.success,
                icon: Icons.calendar_month),
          ],
        ),
        SectionHeader(t('physio.patients'), meta: '2 ${t('physio.active')}'),
        for (final patient in [
          ('John Fernando', 78, t('day.today')),
          ('Nimal Perera', 64, t('day.yesterday')),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: Space.md),
            child: AppListRow(
              title: patient.$1,
              meta: '${t('physio.recovery')} ${patient.$2}%',
              subtitle: '${t('physio.lastSession')}: ${patient.$3}',
              icon: Icons.person,
              onTap: () => Navigator.of(context).pushNamed(Routes.report),
            ),
          ),
        SectionHeader(t('physio.recommendation')),
        AppCard(
          accent: AppColor.brand,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBadge(t('physio.sampleInsight'),
                  tone: BadgeTone.warning, icon: Icons.info_outline),
              SizedBox(height: Space.sm),
              Text(
                t('physio.recommendBody'),
                style: AppText.body,
              ),
            ],
          ),
        ),
        const LogoutRow(),
      ],
    );
  }
}
