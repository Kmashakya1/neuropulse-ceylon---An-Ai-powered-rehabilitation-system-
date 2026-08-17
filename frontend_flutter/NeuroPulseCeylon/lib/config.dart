/// Backend addresses.
///
/// There is no Expo dev server to derive the host from here, so it comes from a
/// compile-time define with a sensible default:
///
///   flutter run --dart-define=NPC_HOST=192.168.1.169
///
/// The default 10.0.2.2 is the Android emulator's alias for the host machine's
/// loopback, so an emulator works with no arguments. A physical phone needs the
/// machine's LAN address, and the ML service must be started with
/// `--host 0.0.0.0` or it will only be reachable via that emulator alias.
library;

const String kHost = String.fromEnvironment(
  'NPC_HOST',
  defaultValue: '10.0.2.2',
);

const int kMlPort = 8100;
const int kNodePort = 5000;

String get mlHttpBase => 'http://$kHost:$kMlPort';
String get nodeBase => 'http://$kHost:$kNodePort';

Uri exercisesUri(String lang) =>
    Uri.parse('$mlHttpBase/exercises?lang=$lang');

Uri alertsLatestUri() => Uri.parse('$nodeBase/api/alerts/latest');

// Auth lives on the Node service, not the ML one: the Python side is a stateless
// movement analyser and has no business holding credentials.
Uri authLoginPatientUri() => Uri.parse('$nodeBase/api/auth/login/patient');
Uri authLoginStaffUri() => Uri.parse('$nodeBase/api/auth/login/staff');
Uri authRegisterPatientUri() =>
    Uri.parse('$nodeBase/api/auth/register/patient');
Uri authRegisterStaffUri() => Uri.parse('$nodeBase/api/auth/register/staff');
Uri authMeUri() => Uri.parse('$nodeBase/api/auth/me');
Uri authLogoutUri() => Uri.parse('$nodeBase/api/auth/logout');

/// Live session fed by camera frames. See ml-service/app/frames.py for the
/// binary frame format this socket expects.
Uri frameSessionUri({
  required String exercise,
  required String patient,
  required String lang,
}) {
  return Uri.parse(
    'ws://$kHost:$kMlPort/ws/session/frames'
    '?exercise=$exercise&patient=$patient&lang=$lang',
  );
}
