import 'package:flutter/material.dart';

import '../features/auth.dart';
import '../features/i18n.dart';

import '../features/language.dart';
import '../routes.dart';
import '../ui/bottom_nav.dart';
import '../ui/tokens.dart';
import '../ui/widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      bottomNav: const AppBottomNav(active: 'me'),
      children: [
        AppHeader(title: t('profile.title')),
        AppCard(
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColor.brandTint,
                  borderRadius: BorderRadius.circular(Radii.lg),
                ),
                child: const Icon(Icons.person,
                    size: 38, color: AppColor.brandText),
              ),
              const SizedBox(width: Space.base),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(authStore.user?.name ?? '', style: AppText.heading),
                    Text(t('profile.patientRole'), style: AppText.body),
                  ],
                ),
              ),
            ],
          ),
        ),
        SectionHeader(t('profile.medicalInfo')),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FieldRow(t('profile.age'), '${authStore.user?.age ?? '—'}'),
              FieldRow(t('profile.bloodGroup'), 'O+'),
              FieldRow(t('profile.strokeType'), t('profile.ischemic')),
            ],
          ),
        ),
        SectionHeader(t('profile.emergencyContact')),
        AppListRow(
          title: 'Sarah Fernando',
          subtitle: t('profile.primaryCaregiver'),
          icon: Icons.call,
          iconBackground: AppColor.dangerTint,
          iconColor: AppColor.dangerText,
          showChevron: false,
        ),
        SectionHeader(t('profile.preferences')),
        AppListRow(
          title: t('explore.title'),
          subtitle: t('explore.openAll'),
          icon: Icons.apps,
          onTap: () => Navigator.of(context).pushNamed(Routes.explore),
        ),
        const SizedBox(height: Space.md),
        AppListRow(
          title: t('language.title'),
          meta: languageStore.language.native,
          subtitle: t('profile.languageSub'),
          icon: Icons.language,
          onTap: () => Navigator.of(context).pushNamed(Routes.language),
        ),
        const SizedBox(height: Space.md),
        AppListRow(
          title: t('profile.accessibility'),
          icon: Icons.settings,
          onTap: () => Navigator.of(context).pushNamed(Routes.settings),
        ),
        const SizedBox(height: Space.md),
        AppListRow(
          title: t('profile.help'),
          icon: Icons.help_outline,
          onTap: () => Navigator.of(context).pushNamed(Routes.help),
        ),
        const SizedBox(height: Space.md),
        AppListRow(
          title: t('profile.about'),
          icon: Icons.info_outline,
          onTap: () => Navigator.of(context).pushNamed(Routes.about),
        ),
        const LogoutRow(),
      ],
    );
  }
}

/// The React Native original showed states as text with emoji ticks ("Enabled ✅")
/// that were not controls — nothing could be changed. These are real switches, so
/// the labels are honest; the values are local until there is somewhere to persist
/// them.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _voice = true;
  bool _highContrast = false;
  bool _medication = true;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      children: [
        AppHeader(
          title: t('set.title'),
          subtitle: t('set.subtitle'),
          back: true,
        ),
        SectionHeader(t('set.accessibility')),
        AppListRow(
          title: t('language.title'),
          meta: languageStore.language.native,
          icon: Icons.language,
          onTap: () async {
            await Navigator.of(context).pushNamed(Routes.language);
            if (mounted) setState(() {});
          },
        ),
        const SizedBox(height: Space.md),
        AppListRow(
          title: t('set.voice'),
          subtitle: t('set.voiceSub'),
          icon: Icons.mic,
          showChevron: false,
          trailing: Switch(
            value: _voice,
            onChanged: (v) => setState(() => _voice = v),
          ),
        ),
        const SizedBox(height: Space.md),
        AppListRow(
          title: t('set.contrast'),
          subtitle: t('set.contrastSub'),
          icon: Icons.contrast,
          showChevron: false,
          trailing: Switch(
            value: _highContrast,
            onChanged: (v) => setState(() => _highContrast = v),
          ),
        ),
        SectionHeader(t('set.notifications')),
        AppListRow(
          title: t('set.medReminders'),
          subtitle: t('set.medRemindersSub'),
          icon: Icons.medical_information,
          showChevron: false,
          trailing: Switch(
            value: _medication,
            onChanged: (v) => setState(() => _medication = v),
          ),
        ),
        const SectionHeader('Emergency'),
        AppListRow(
          title: t('profile.emergencyContact'),
          subtitle: 'Sarah Fernando · ${t('profile.primaryCaregiver')}',
          icon: Icons.call,
          iconBackground: AppColor.dangerTint,
          iconColor: AppColor.dangerText,
          onTap: () => Navigator.of(context).pushNamed(Routes.profile),
        ),
      ],
    );
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static List<(String, String)> get _faqs => [
    (t('help.q1'), t('help.a1')),
    (t('help.q2'), t('help.a2')),
    (t('help.q3'), t('help.a3')),
    (t('help.q4'), t('help.a4')),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      children: [
        AppHeader(
          title: t('profile.help'),
          subtitle: t('help.subtitle'),
          back: true,
        ),
        for (final faq in _faqs)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.md),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(faq.$1, style: AppText.subheading),
                  const SizedBox(height: Space.sm),
                  Text(faq.$2,
                      style:
                          AppText.body.copyWith(color: AppColor.inkMuted)),
                ],
              ),
            ),
          ),
        SectionHeader(t('help.needMore')),
        AppCard(
          accent: AppColor.brand,
          child: Text(
            t('help.needMoreBody'),
            style: AppText.body,
          ),
        ),
      ],
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      children: [
        AppHeader(
          title: t('about.title'),
          subtitle: t('about.subtitle'),
          back: true,
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t('about.overview'), style: AppText.subheading),
              SizedBox(height: Space.sm),
              Text(
                t('about.overviewBody'),
                style: AppText.body,
              ),
            ],
          ),
        ),
        SectionHeader(t('about.features')),
        AppCard(
          child: Bullets(
            [
              t('about.f1'),
              t('about.f2'),
              t('about.f3'),
              t('about.f4'),
              t('about.f5'),
            ],
            icon: Icons.check_circle,
            tone: BadgeTone.success,
          ),
        ),
        SectionHeader(t('about.builtWith')),
        const AppCard(
          child: Bullets([
            'Flutter and Dart',
            'MediaPipe pose estimation',
            'Python analysis service',
          ]),
        ),
        SectionHeader(t('about.project')),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBadge(t('about.finalYear'),
                  tone: BadgeTone.brand, icon: Icons.school),
              SizedBox(height: Space.md),
              Text(
                t('about.projectBody'),
                style: AppText.body,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
