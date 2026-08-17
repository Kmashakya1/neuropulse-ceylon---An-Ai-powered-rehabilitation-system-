import 'dart:async';

import 'package:flutter/material.dart';

import '../features/i18n.dart';

import '../features/auth.dart';
import '../features/language.dart';
import '../routes.dart';
import '../ui/tokens.dart';
import '../ui/widgets.dart';
import 'auth_screens.dart';

/// Splash. Replaces the React Native version, which scheduled two navigations —
/// a useEffect timer plus a bare setTimeout in the render body that re-fired on
/// every render with no cleanup.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      // A restored session skips onboarding entirely and lands on the home for
      // that role; only a signed-out user sees the language and role pickers.
      final user = authStore.user;
      Navigator.of(context).pushReplacementNamed(
        authStore.signedIn && user != null
            ? Routes.homeFor(user.role)
            : Routes.languageFirstRun,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColor.brandLight, AppColor.brand],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 128,
                  height: 128,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.psychology,
                      size: 68, color: AppColor.brand),
                ),
                const SizedBox(height: Space.xl),
                Text('Neuro Pulse Ceylon',
                    style: AppText.display.copyWith(color: Colors.white),
                    textAlign: TextAlign.center),
                const SizedBox(height: Space.md),
                Text(t('splash.tagline'),
                    style: AppText.body.copyWith(color: Colors.white),
                    textAlign: TextAlign.center),
                const SizedBox(height: Space.xxl),
                const CircularProgressIndicator(color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Language picker, shared by the first-run flow and settings — the React Native
/// app had these as two 460-line near-duplicates that had already drifted apart.
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key, required this.firstRun});

  final bool firstRun;

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BrandHero(
              title: t('language.title'),
              subtitle: t('language.subtitle'),
              icon: Icons.language,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(Space.lg),
                children: [
                  for (final option in Language.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Space.base),
                      child: _option(option),
                    ),
                  const SizedBox(height: Space.sm),
                  Text(
                    widget.firstRun
                        ? t('language.firstRunNote')
                        : t('language.settingsNote'),
                    style:
                        AppText.caption.copyWith(color: AppColor.inkSubtle),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  Space.lg, 0, Space.lg, Space.base),
              child: FilledButton.icon(
                onPressed: () {
                  if (widget.firstRun) {
                    Navigator.of(context).pushReplacementNamed(Routes.roles);
                  } else {
                    Navigator.of(context).maybePop();
                  }
                },
                icon: const Icon(Icons.arrow_forward),
                label: Text(widget.firstRun ? t('common.continue') : t('common.save')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _option(Language option) {
    final selected = languageStore.language == option;

    return InkWell(
      onTap: () async {
        await languageStore.set(option);
        if (mounted) setState(() {});
      },
      borderRadius: BorderRadius.circular(Radii.lg),
      child: Container(
        constraints: const BoxConstraints(minHeight: 76),
        padding: const EdgeInsets.symmetric(
            horizontal: Space.lg, vertical: Space.base),
        decoration: BoxDecoration(
          color: selected ? AppColor.brandTint : AppColor.surface,
          borderRadius: BorderRadius.circular(Radii.lg),
          border: Border.all(
            color: selected ? AppColor.brand : AppColor.border,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.native, style: AppText.subheading),
                  Text(option.english,
                      style: AppText.caption
                          .copyWith(color: AppColor.inkSubtle)),
                ],
              ),
            ),
            // A tick as well as the border and fill: colour alone is unreliable
            // for users with reduced contrast sensitivity.
            if (selected)
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColor.brandStrong,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 20, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}

/// Role selection.
class RolesScreen extends StatelessWidget {
  const RolesScreen({super.key});

  static List<(String, String, IconData, String)> get _roles => [
    (t('roles.patient'), t('roles.patientSub'), Icons.accessibility_new,
        Routes.welcome),
    (t('roles.caregiver'), t('roles.caregiverSub'), Icons.favorite,
        Routes.caregiverDashboard),
    (t('roles.physio'), t('roles.physioSub'), Icons.medical_services,
        Routes.physioDashboard),
  ];

  /// Patients get their own tap-a-name-then-PIN flow; everyone else signs in
  /// with a password and is then dropped on the dashboard for their role.
  void _open(BuildContext context, String destination) {
    if (destination == Routes.welcome) {
      Navigator.of(context).pushNamed(Routes.welcome);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Localized(StaffLoginScreen(destination: destination)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            BrandHero(
              title: t('roles.welcome'),
              subtitle: t('roles.subtitle'),
              icon: Icons.groups,
            ),
            Padding(
              padding: const EdgeInsets.all(Space.lg),
              child: Column(
                children: [
                  for (final role in _roles)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Space.md),
                      child: AppListRow(
                        title: role.$1,
                        subtitle: role.$2,
                        icon: role.$3,
                        onTap: () => _open(context, role.$4),
                      ),
                    ),
                  const SizedBox(height: Space.sm),
                  Text(t('roles.haveAccount'),
                      style: AppText.body
                          .copyWith(color: AppColor.inkMuted)),
                  const SizedBox(height: Space.md),
                  // The first-run picker replaced itself with this screen, so
                  // there is nothing to pop back to. This reopens the picker as
                  // its settings variant, which returns here on save.
                  TextButton.icon(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(Routes.language),
                    icon: const Icon(Icons.language),
                    label: Text(t('roles.changeLanguage')),
                  ),
                  // Clear of the gesture bar; the Sinhala label sat flush to
                  // the screen edge without it.
                  const SizedBox(height: Space.lg),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Patient sign-in. Deliberately the sparsest screen in the app: one very large
/// target plus a voice alternative, because a patient arriving here may be
/// fatigued, one-handed and unfamiliar with the phone.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      scroll: false,
      footer: Column(
        children: [
          OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(t('welcome.voiceNotReady'))),
            ),
            icon: const Icon(Icons.mic),
            label: Text(t('welcome.voiceLogin')),
          ),
          const SizedBox(height: Space.sm),
          Text(t('welcome.needHelp'),
              style: AppText.caption.copyWith(color: AppColor.inkSubtle),
              textAlign: TextAlign.center),
        ],
      ),
      children: [
        const Padding(
          padding: EdgeInsets.only(top: Space.md),
          child: Align(alignment: Alignment.centerLeft, child: BackTarget()),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: AppColor.brand,
                  borderRadius: BorderRadius.circular(Radii.xl),
                ),
                child: const Icon(Icons.accessibility_new,
                    size: 44, color: Colors.white),
              ),
              const SizedBox(height: Space.base),
              Text(t('welcome.hello'), style: AppText.display),
              Text(t('welcome.tapToStart'),
                  style: AppText.body.copyWith(color: AppColor.inkMuted)),
              const SizedBox(height: Space.xl),
              InkWell(
                onTap: () =>
                    Navigator.of(context).pushNamed(Routes.patientLogin),
                customBorder: const CircleBorder(),
                child: Container(
                  width: 230,
                  height: 230,
                  decoration: const BoxDecoration(
                    color: AppColor.brandStrong,
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.account_circle,
                          size: 110, color: Colors.white),
                      Text(t('welcome.login'),
                          style:
                              AppText.heading.copyWith(color: Colors.white)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Space.base),
              TextButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const Localized(PatientRegisterScreen()),
                  ),
                ),
                icon: const Icon(Icons.person_add_alt),
                label: Text(t('auth.newPatient')),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
