import 'package:flutter/material.dart';

import 'features/auth.dart';
import 'features/i18n.dart';
import 'features/language.dart';
import 'routes.dart';
import 'screens/auth_screens.dart';
import 'screens/care_screens.dart';
import 'screens/dashboard_screen.dart';
import 'screens/exercise_list_screen.dart';
import 'screens/extra_screens.dart';
import 'screens/info_screens.dart';
import 'screens/onboarding_screens.dart';
import 'screens/profile_screens.dart';
import 'screens/progress_screens.dart';
import 'screens/sos_screen.dart';
import 'ui/tokens.dart';

Future<void> main() async {
  // Must come first. Both stores below reach shared_preferences over a platform
  // channel, and a channel call before the binding exists throws — which the
  // stores caught and swallowed, so the language silently reset to English on
  // every launch and a restored session was never found.
  WidgetsFlutterBinding.ensureInitialized();

  // Read the stored language before the first frame, so screens never fetch the
  // exercise catalogue in the wrong language and then have to refetch.
  await languageStore.load();
  // Restores the stored token and refreshes the profile in the background, so
  // the splash screen already knows whether to go to a dashboard or to sign-in.
  await authStore.load();
  runApp(const NeuroPulseApp());
}

class NeuroPulseApp extends StatelessWidget {
  const NeuroPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Language changes are handled per route by Localized, not here: rebuilding
    // MaterialApp does not reach pages already on the Navigator's stack. This
    // listener is only for sign-in and sign-out, which always rebuild the stack
    // anyway, so it just keeps the first frame after a session change honest.
    return ListenableBuilder(
      listenable: authStore,
      builder: (context, _) => _app(),
    );
  }

  Widget _app() {
    return MaterialApp(
      title: 'NeuroPulse Ceylon',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      initialRoute: Routes.splash,
      routes: {
        Routes.splash: (_) => const Localized(SplashScreen()),
        Routes.languageFirstRun: (_) =>
            const Localized(LanguageScreen(firstRun: true)),
        Routes.language: (_) =>
            const Localized(LanguageScreen(firstRun: false)),
        Routes.roles: (_) => const Localized(RolesScreen()),
        Routes.welcome: (_) => const Localized(WelcomeScreen()),
        Routes.patientLogin: (_) => const Localized(PatientLoginScreen()),

        Routes.dashboard: (_) => const Localized(DashboardScreen()),
        Routes.exerciseLibrary: (_) => const Localized(ExerciseListScreen()),
        Routes.exerciseDetails: (_) => const Localized(ExerciseDetailsScreen()),
        Routes.exerciseVideo: (_) => const Localized(ExerciseVideoScreen()),
        Routes.myPlan: (_) => const Localized(MyPlanScreen()),
        Routes.progress: (_) => const Localized(ProgressScreen()),
        Routes.care: (_) => const Localized(CareScreen()),
        Routes.profile: (_) => const Localized(ProfileScreen()),
        Routes.settings: (_) => const Localized(SettingsScreen()),
        Routes.sos: (_) => const Localized(SosScreen()),

        Routes.history: (_) => const Localized(HistoryScreen()),
        Routes.report: (_) => const Localized(ReportScreen()),
        Routes.schedule: (_) => const Localized(ScheduleScreen()),
        Routes.appointments: (_) => const Localized(AppointmentsScreen()),
        Routes.notifications: (_) => const Localized(NotificationsScreen()),
        Routes.chat: (_) => const Localized(ChatScreen()),
        Routes.help: (_) => const Localized(HelpScreen()),
        Routes.about: (_) => const Localized(AboutScreen()),
        Routes.explore: (_) => const Localized(ExploreScreen()),
        Routes.leaderboard: (_) => const Localized(LeaderboardScreen()),
        Routes.insights: (_) => const Localized(InsightsScreen()),
        Routes.brainTraining: (_) => const Localized(BrainTrainingScreen()),
        Routes.voiceAssistant: (_) => const Localized(VoiceAssistantScreen()),

        Routes.caregiverDashboard: (_) =>
            const Localized(CaregiverDashboardScreen()),
        Routes.physioDashboard: (_) => const Localized(PhysioDashboardScreen()),
      },
    );
  }
}
