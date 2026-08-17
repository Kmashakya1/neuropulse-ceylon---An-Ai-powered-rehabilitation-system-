import 'package:flutter/material.dart';

import '../features/i18n.dart';

import '../routes.dart';
import '../ui/bottom_nav.dart';
import '../ui/tokens.dart';
import '../features/auth.dart';
import '../ui/widgets.dart';

/// Patient home.
///
/// Ordering reflects urgency rather than visual balance: today's session first
/// (the thing the app exists to get them to do), then health reminders, then
/// emergency access. SOS is the only red element on the screen.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      bottomNav: const AppBottomNav(active: 'home'),
      children: [
        AppHeader(
          title: '${t('dash.hi')}, ${authStore.user?.name ?? ''}'.trim(),
          subtitle: t('dash.ready'),
          trailing: SizedBox(
            width: Sizes.target,
            height: Sizes.target,
            child: IconButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(Routes.notifications),
              icon: const Icon(Icons.notifications),
              tooltip: t('dash.notifications'),
              style: IconButton.styleFrom(
                backgroundColor: AppColor.surface,
                foregroundColor: AppColor.ink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Radii.md),
                ),
              ),
            ),
          ),
        ),
        AppCard(
          accent: AppColor.brand,
          child: Row(
            children: [
              Container(
                width: Sizes.chip,
                height: Sizes.chip,
                decoration: BoxDecoration(
                  color: AppColor.warningTint,
                  borderRadius: BorderRadius.circular(Radii.md),
                ),
                child: const Icon(Icons.local_fire_department,
                    size: 28, color: AppColor.warningText),
              ),
              const SizedBox(width: Space.base),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t('dash.streak'), style: AppText.subheading),
                    Text(t('dash.streakSub'), style: AppText.caption),
                  ],
                ),
              ),
              AppBadge(t('dash.onTrack'),
                  tone: BadgeTone.success, icon: Icons.check),
            ],
          ),
        ),
        SectionHeader(t('dash.todaysFocus')),
        AppCard(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: AppColor.brandTint,
                      borderRadius: BorderRadius.circular(Radii.md),
                    ),
                    child: const Icon(Icons.accessibility_new,
                        size: 32, color: AppColor.brandText),
                  ),
                  const SizedBox(width: Space.base),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t('dash.upperLimb'), style: AppText.subheading),
                        Text(t('dash.upperLimbSub'), style: AppText.caption),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Space.base),
              FilledButton.icon(
                onPressed: () =>
                    Navigator.of(context).pushNamed(Routes.exerciseLibrary),
                icon: const Icon(Icons.play_arrow),
                label: Text(t('dash.startSession')),
              ),
            ],
          ),
        ),
        SectionHeader(t('dash.healthToday')),
        Row(
          children: [
            StatTile(
              value: '10:30',
              label: t('dash.medicationTaken'),
              tone: BadgeTone.success,
              icon: Icons.medical_information,
            ),
            SizedBox(width: Space.md),
            StatTile(
              value: t('dash.due'),
              label: t('dash.bpReading'),
              tone: BadgeTone.warning,
              icon: Icons.monitor_heart,
            ),
          ],
        ),
        SectionHeader(t('dash.emergency')),
        AppListRow(
          title: t('dash.sos'),
          subtitle: t('dash.sosSub'),
          icon: Icons.warning_amber_rounded,
          iconBackground: AppColor.dangerTint,
          iconColor: AppColor.dangerText,
          onTap: () => Navigator.of(context).pushNamed(Routes.sos),
        ),
      ],
    );
  }
}
