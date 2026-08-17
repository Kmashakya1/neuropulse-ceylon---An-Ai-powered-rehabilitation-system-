/// Route names, mirroring the file-based routes of the React Native app so the
/// two stay recognisably the same product.
class Routes {
  Routes._();

  static const splash = '/';
  static const languageFirstRun = '/language-first-run';
  static const language = '/language';
  static const roles = '/roles';
  static const welcome = '/welcome';
  static const patientLogin = '/patient-login';

  /// Where a role lands once signed in.
  static String homeFor(String role) => switch (role) {
    'caregiver' => caregiverDashboard,
    'physio' => physioDashboard,
    _ => dashboard,
  };

  static const dashboard = '/dashboard';
  static const exerciseLibrary = '/exercise-library';
  static const exerciseDetails = '/exercise-details';
  static const exerciseVideo = '/exercise-video';
  static const myPlan = '/myplan';
  static const progress = '/progress';
  static const care = '/care';
  static const profile = '/profile';
  static const settings = '/settings';
  static const sos = '/sos';

  static const history = '/history';
  static const report = '/report';
  static const schedule = '/schedule';
  static const appointments = '/appointments';
  static const notifications = '/notifications';
  static const chat = '/chat';
  static const help = '/help';
  static const about = '/about';
  static const explore = '/explore';
  static const leaderboard = '/leaderboard';
  static const insights = '/insights';
  static const brainTraining = '/brain-training';
  static const voiceAssistant = '/voice-assistant';

  static const caregiverDashboard = '/caregiver-dashboard';
  static const physioDashboard = '/physio-dashboard';
}
