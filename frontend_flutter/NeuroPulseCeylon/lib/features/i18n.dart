/// UI translations.
///
/// The ML service already returns exercise names and coaching cues in the
/// patient's language; this covers everything else — the labels, headings and
/// button text that were hardcoded English.
///
/// A plain keyed map rather than `flutter_localizations` and ARB codegen: the app
/// already has a language store to read from, and this keeps the strings in one
/// readable file that a Sinhala or Tamil speaker can review without needing
/// Flutter tooling.
///
/// TRANSLATION QUALITY: these are careful but machine-authored. Before this goes
/// in front of patients, a native speaker should review them — particularly the
/// clinical wording and the emergency screen, where being misunderstood matters
/// most. Missing keys fall back to English rather than showing a blank.
library;

import 'package:flutter/widgets.dart';

import 'language.dart';

const Map<String, Map<String, String>> _strings = {
  // -- common ---------------------------------------------------------------
  'common.continue': {'en': 'Continue', 'si': 'ඉදිරියට', 'ta': 'தொடரவும்'},
  'common.save': {'en': 'Save', 'si': 'සුරකින්න', 'ta': 'சேமிக்கவும்'},
  'common.tryAgain': {
    'en': 'Try again',
    'si': 'නැවත උත්සාහ කරන්න',
    'ta': 'மீண்டும் முயற்சிக்கவும்',
  },
  'common.ok': {'en': 'OK', 'si': 'හරි', 'ta': 'சரி'},
  'common.back': {'en': 'Back', 'si': 'ආපසු', 'ta': 'பின்'},
  'common.loading': {
    'en': 'Loading…',
    'si': 'පූරණය වෙමින්…',
    'ta': 'ஏற்றுகிறது…',
  },
  'common.comingSoon': {
    'en': 'Coming soon',
    'si': 'ඉක්මනින්',
    'ta': 'விரைவில்',
  },
  'common.reps': {'en': 'reps', 'si': 'වාර', 'ta': 'முறை'},
  'common.sessions': {'en': 'sessions', 'si': 'සැසි', 'ta': 'அமர்வுகள்'},
  'common.backToHome': {
    'en': 'Back to home',
    'si': 'මුල් පිටුවට',
    'ta': 'முகப்புக்கு',
  },

  // -- splash ---------------------------------------------------------------
  'splash.tagline': {
    'en': 'AI-powered stroke rehabilitation support',
    'si': 'ආඝාත පුනරුත්ථාපනය සඳහා බුද්ධිමත් සහාය',
    'ta': 'பக்கவாத மறுவாழ்வுக்கான அறிவார்ந்த ஆதரவு',
  },

  // -- language -------------------------------------------------------------
  'language.title': {'en': 'Language', 'si': 'භාෂාව', 'ta': 'மொழி'},
  'language.subtitle': {
    'en': 'Select your preferred language',
    'si': 'ඔබ කැමති භාෂාව තෝරන්න',
    'ta': 'உங்கள் விருப்ப மொழியைத் தேர்ந்தெடுக்கவும்',
  },
  'language.firstRunNote': {
    'en': 'You can change this at any time in your profile.',
    'si': 'ඔබට මෙය ඕනෑම වේලාවක ඔබේ පැතිකඩෙන් වෙනස් කළ හැක.',
    'ta': 'இதை எப்போது வேண்டுமானாலும் உங்கள் சுயவிவரத்தில் மாற்றலாம்.',
  },
  'language.settingsNote': {
    'en': 'Exercise names and coaching cues will use this language.',
    'si': 'ව්‍යායාම නාම සහ උපදෙස් මෙම භාෂාවෙන් දිස්වේ.',
    'ta': 'பயிற்சிப் பெயர்களும் அறிவுரைகளும் இந்த மொழியில் இருக்கும்.',
  },

  // -- roles ----------------------------------------------------------------
  'roles.welcome': {
    'en': 'Welcome',
    'si': 'සාදරයෙන් පිළිගනිමු',
    'ta': 'வரவேற்கிறோம்',
  },
  'roles.subtitle': {
    'en': 'Select your role to start your recovery journey',
    'si': 'ඔබේ සුවවීමේ ගමන ආරම්භ කිරීමට භූමිකාව තෝරන්න',
    'ta': 'உங்கள் மீட்புப் பயணத்தைத் தொடங்க பங்கைத் தேர்ந்தெடுக்கவும்',
  },
  'roles.patient': {'en': 'Patient', 'si': 'රෝගියා', 'ta': 'நோயாளி'},
  'roles.patientSub': {
    'en': 'Guided rehab exercises and daily progress',
    'si': 'මඟපෙන්වන ලද ව්‍යායාම සහ දෛනික ප්‍රගතිය',
    'ta': 'வழிகாட்டப்பட்ட பயிற்சிகளும் தினசரி முன்னேற்றமும்',
  },
  'roles.caregiver': {
    'en': 'Caregiver',
    'si': 'රැකබලා ගන්නා',
    'ta': 'பராமரிப்பாளர்',
  },
  'roles.caregiverSub': {
    'en': 'Monitor progress, goals and emergency alerts',
    'si': 'ප්‍රගතිය, ඉලක්ක සහ හදිසි අනතුරු ඇඟවීම් නිරීක්ෂණය',
    'ta': 'முன்னேற்றம், இலக்குகள், அவசர எச்சரிக்கைகளைக் கண்காணிக்க',
  },
  'roles.physio': {
    'en': 'Physiotherapist',
    'si': 'භෞත චිකිත්සක',
    'ta': 'இயன்முறை மருத்துவர்',
  },
  'roles.physioSub': {
    'en': 'Manage patients, plans and session data',
    'si': 'රෝගීන්, සැලසුම් සහ සැසි දත්ත කළමනාකරණය',
    'ta': 'நோயாளிகள், திட்டங்கள், அமர்வுத் தரவை நிர்வகிக்க',
  },
  'roles.haveAccount': {
    'en': 'Already have an account?  Log In',
    'si': 'දැනටමත් ගිණුමක් තිබේද?  ඇතුල් වන්න',
    'ta': 'ஏற்கனவே கணக்கு உள்ளதா?  உள்நுழையவும்',
  },

  // -- welcome --------------------------------------------------------------
  'welcome.hello': {'en': 'Hello', 'si': 'ආයුබෝවන්', 'ta': 'வணக்கம்'},
  'welcome.tapToStart': {
    'en': 'Tap the circle to start',
    'si': 'ආරම්භ කිරීමට රවුම ස්පර්ශ කරන්න',
    'ta': 'தொடங்க வட்டத்தைத் தொடவும்',
  },
  'welcome.login': {'en': 'LOGIN', 'si': 'ඇතුල් වන්න', 'ta': 'உள்நுழை'},
  'welcome.voiceLogin': {
    'en': 'Voice Login',
    'si': 'හඬ මගින් ඇතුල් වන්න',
    'ta': 'குரல் வழி நுழைவு',
  },
  'welcome.voiceNotReady': {
    'en': 'Voice login is not available yet',
    'si': 'හඬ මගින් ඇතුල් වීම තවම නොමැත',
    'ta': 'குரல் வழி நுழைவு இன்னும் இல்லை',
  },
  'welcome.needHelp': {
    'en': 'Need help? Ask your caregiver for assistance.',
    'si': 'උදව් අවශ්‍යද? ඔබේ රැකබලා ගන්නාගෙන් සහාය ලබා ගන්න.',
    'ta': 'உதவி தேவையா? உங்கள் பராமரிப்பாளரிடம் கேளுங்கள்.',
  },

  // -- bottom navigation ----------------------------------------------------
  'nav.home': {'en': 'Home', 'si': 'මුල', 'ta': 'முகப்பு'},
  'nav.plan': {'en': 'My Plan', 'si': 'සැලසුම', 'ta': 'திட்டம்'},
  'nav.progress': {'en': 'Progress', 'si': 'ප්‍රගතිය', 'ta': 'முன்னேற்றம்'},
  'nav.care': {'en': 'Care', 'si': 'සත්කාරය', 'ta': 'பராமரிப்பு'},
  'nav.me': {'en': 'Me', 'si': 'මම', 'ta': 'நான்'},

  // -- dashboard ------------------------------------------------------------
  'dash.hi': {'en': 'Hi', 'si': 'ආයුබෝවන්', 'ta': 'வணக்கம்'},
  'dash.ready': {
    'en': 'Ready for your recovery?',
    'si': 'සුවවීමට සූදානම්ද?',
    'ta': 'மீட்புக்குத் தயாரா?',
  },
  'dash.streak': {
    'en': 'Day 14 streak',
    'si': 'දින 14ක අඛණ්ඩතාව',
    'ta': '14 நாள் தொடர்ச்சி',
  },
  'dash.streakSub': {
    'en': 'Personal best reached',
    'si': 'පෞද්ගලික වාර්තාව',
    'ta': 'தனிப்பட்ட சாதனை',
  },
  'dash.onTrack': {
    'en': 'On track',
    'si': 'නිවැරදි මාවතේ',
    'ta': 'சரியான பாதையில்',
  },
  'dash.todaysFocus': {
    'en': "Today's focus",
    'si': 'අද අවධානය',
    'ta': 'இன்றைய கவனம்',
  },
  'dash.upperLimb': {
    'en': 'Upper Limb PT',
    'si': 'උඩු අත්පා ප්‍රතිකාරය',
    'ta': 'மேல் மூட்டு சிகிச்சை',
  },
  'dash.upperLimbSub': {
    'en': '15 min · Shoulder & arm',
    'si': 'මිනිත්තු 15 · උරහිස සහ අත',
    'ta': '15 நிமிடம் · தோள் மற்றும் கை',
  },
  'dash.startSession': {
    'en': 'Start session',
    'si': 'සැසිය අරඹන්න',
    'ta': 'அமர்வைத் தொடங்கு',
  },
  'dash.healthToday': {
    'en': 'Health today',
    'si': 'අද සෞඛ්‍යය',
    'ta': 'இன்றைய நலம்',
  },
  'dash.medicationTaken': {
    'en': 'Medication taken',
    'si': 'ඖෂධ ගෙන ඇත',
    'ta': 'மருந்து எடுக்கப்பட்டது',
  },
  'dash.bpReading': {
    'en': 'Blood pressure reading',
    'si': 'රුධිර පීඩන කියවීම',
    'ta': 'இரத்த அழுத்த அளவீடு',
  },
  'dash.due': {'en': 'Due', 'si': 'නියමිතයි', 'ta': 'நிலுவை'},
  'dash.emergency': {'en': 'Emergency', 'si': 'හදිසි අවස්ථා', 'ta': 'அவசரம்'},
  'dash.sos': {'en': 'Emergency SOS', 'si': 'හදිසි ආධාර', 'ta': 'அவசர உதவி'},
  'dash.sosSub': {
    'en': 'Alerts your caregiver immediately',
    'si': 'ඔබේ රැකබලා ගන්නාට වහාම දැනුම් දේ',
    'ta': 'உங்கள் பராமரிப்பாளருக்கு உடனே அறிவிக்கும்',
  },
  'dash.notifications': {
    'en': 'Notifications',
    'si': 'දැනුම්දීම්',
    'ta': 'அறிவிப்புகள்',
  },

  // -- exercise list --------------------------------------------------------
  'ex.title': {'en': 'Exercises', 'si': 'ව්‍යායාම', 'ta': 'பயிற்சிகள்'},
  'ex.trackable': {
    'en': 'exercises your coach can track',
    'si': 'ව්‍යායාම නිරීක්ෂණය කළ හැක',
    'ta': 'பயிற்சிகளைக் கண்காணிக்க முடியும்',
  },
  'ex.loadingFromCoach': {
    'en': 'Loading from your coach',
    'si': 'පූරණය වෙමින්…',
    'ta': 'ஏற்றுகிறது…',
  },
  'ex.unavailable': {
    'en': 'Coach service unavailable',
    'si': 'සේවාව ලබා ගත නොහැක',
    'ta': 'சேவை கிடைக்கவில்லை',
  },
  'ex.hold': {'en': 'Hold', 'si': 'රඳවා ගන්න', 'ta': 'பிடிக்கவும்'},
  'ex.seconds': {'en': 'seconds', 'si': 'තත්පර', 'ta': 'வினாடிகள்'},

  // -- session --------------------------------------------------------------
  'session.live': {'en': 'Live', 'si': 'සජීවී', 'ta': 'நேரலை'},
  'session.connecting': {
    'en': 'Connecting',
    'si': 'සම්බන්ධ වෙමින්',
    'ta': 'இணைக்கிறது',
  },
  'session.followAlong': {
    'en': 'FOLLOW ALONG',
    'si': 'අනුගමනය කරන්න',
    'ta': 'பின்பற்றவும்',
  },
  'session.gettingReady': {
    'en': 'Getting ready',
    'si': 'සූදානම් වෙමින්',
    'ta': 'தயாராகிறது',
  },
  'session.gettingReadySub': {
    'en': 'Starting the camera and connecting to your coach.',
    'si': 'කැමරාව ආරම්භ කර සම්බන්ධ වෙමින්.',
    'ta': 'கேமராவைத் தொடங்கி இணைக்கிறது.',
  },
  'session.cannotReach': {
    'en': 'Cannot reach the coach service',
    'si': 'සේවාවට සම්බන්ධ විය නොහැක',
    'ta': 'சேவையை அணுக முடியவில்லை',
  },
  'session.notVisible': {
    'en': 'Move so your whole body is in view',
    'si': 'ඔබේ මුළු සිරුරම පෙනෙන ලෙස සිටගන්න',
    'ta': 'உங்கள் முழு உடலும் தெரியுமாறு நகருங்கள்',
  },
  'session.up': {'en': 'up', 'si': 'ඉහළට', 'ta': 'மேலே'},
  'session.down': {'en': 'down', 'si': 'පහළට', 'ta': 'கீழே'},
  'session.form': {'en': 'Form', 'si': 'ඉරියව්ව', 'ta': 'நிலை'},
  'session.secondsHeld': {
    'en': 'SECONDS HELD',
    'si': 'තත්පර ගණන',
    'ta': 'வினாடிகள்',
  },
  'session.target': {'en': 'TARGET', 'si': 'ඉලක්කය', 'ta': 'இலக்கு'},
  'session.holding': {
    'en': 'Holding',
    'si': 'රඳවා ගෙන',
    'ta': 'பிடித்திருத்தல்',
  },
  'session.getIntoPosition': {
    'en': 'Get into position',
    'si': 'නිසි ඉරියව්වට එන්න',
    'ta': 'சரியான நிலைக்கு வரவும்',
  },
  'session.best': {'en': 'Best', 'si': 'හොඳම', 'ta': 'சிறந்தது'},
  'session.sent': {'en': 'sent', 'si': 'යැවූ', 'ta': 'அனுப்பியது'},
  'session.dropped': {'en': 'dropped', 'si': 'අත්හළ', 'ta': 'விடப்பட்டது'},
  'session.end': {
    'en': 'End session',
    'si': 'සැසිය අවසන් කරන්න',
    'ta': 'அமர்வை முடிக்க',
  },
  'session.finish': {'en': 'Finish', 'si': 'අවසන් කරන්න', 'ta': 'முடிக்க'},
  'session.noDemo': {
    'en': 'No demonstration video for this exercise',
    'si': 'මෙම ව්‍යායාමයට නිරූපණ වීඩියෝවක් නැත',
    'ta': 'இந்தப் பயிற்சிக்கு விளக்க வீடியோ இல்லை',
  },
  'session.demoUnavailable': {
    'en': 'Demonstration video unavailable',
    'si': 'නිරූපණ වීඩියෝව ලබා ගත නොහැක',
    'ta': 'விளக்க வீடியோ கிடைக்கவில்லை',
  },
  'session.fallTitle': {
    'en': 'Fall detected',
    'si': 'වැටීමක් හඳුනාගෙන ඇත',
    'ta': 'விழுந்தது கண்டறியப்பட்டது',
  },
  'session.fallBody': {
    'en':
        'Your caregiver has been alerted. Stay where you are if you are hurt.',
    'si': 'ඔබේ රැකබලා ගන්නාට දැනුම් දී ඇත. තුවාල නම් එතැනම සිටින්න.',
    'ta':
        'உங்கள் பராமரிப்பாளருக்கு அறிவிக்கப்பட்டது. காயமெனில் அங்கேயே இருங்கள்.',
  },
  'session.imOk': {'en': "I'm OK", 'si': 'මම හොඳින්', 'ta': 'நான் நலம்'},

  // -- SOS ------------------------------------------------------------------
  'sos.active': {
    'en': 'EMERGENCY ALERT ACTIVE',
    'si': 'හදිසි ඇඟවීම ක්‍රියාත්මකයි',
    'ta': 'அவசர எச்சரிக்கை இயங்குகிறது',
  },
  'sos.sent': {
    'en': 'ALERT SENT',
    'si': 'ඇඟවීම යවා ඇත',
    'ta': 'எச்சரிக்கை அனுப்பப்பட்டது',
  },
  'sos.cancelled': {
    'en': 'ALERT CANCELLED',
    'si': 'ඇඟවීම අවලංගුයි',
    'ta': 'எச்சரிக்கை ரத்து செய்யப்பட்டது',
  },
  'sos.fallDetected': {
    'en': 'Fall detected',
    'si': 'වැටීමක් හඳුනාගෙන ඇත',
    'ta': 'விழுந்தது கண்டறியப்பட்டது',
  },
  'sos.seconds': {'en': 'SECONDS', 'si': 'තත්පර', 'ta': 'வினாடிகள்'},
  'sos.contacting': {
    'en': 'Contacting your caregiver',
    'si': 'රැකබලා ගන්නා අමතමින්',
    'ta': 'பராமரிப்பாளரைத் தொடர்புகொள்கிறது',
  },
  'sos.helpOnWay': {
    'en': 'Help is on the way',
    'si': 'උදව් පැමිණෙමින්',
    'ta': 'உதவி வந்துகொண்டிருக்கிறது',
  },
  'sos.helpBody': {
    'en':
        'Your caregiver has been notified. Stay where you are if you are hurt.',
    'si': 'ඔබේ රැකබලා ගන්නාට දැනුම් දී ඇත. තුවාල නම් එතැනම සිටින්න.',
    'ta':
        'உங்கள் பராமரிப்பாளருக்கு அறிவிக்கப்பட்டது. காயமெனில் அங்கேயே இருங்கள்.',
  },
  'sos.cancelledBody': {
    'en': 'No one was contacted.',
    'si': 'කිසිවෙකු අමතා නැත.',
    'ta': 'யாரும் தொடர்பு கொள்ளப்படவில்லை.',
  },
  'sos.primaryContact': {
    'en': 'PRIMARY CONTACT',
    'si': 'ප්‍රධාන සම්බන්ධතාවය',
    'ta': 'முதன்மைத் தொடர்பு',
  },
  'sos.imOkCancel': {
    'en': "I'm OK — Cancel",
    'si': 'මම හොඳින් — අවලංගු',
    'ta': 'நான் நலம் — ரத்து',
  },

  // -- my plan --------------------------------------------------------------
  'plan.title': {'en': 'My Plan', 'si': 'මගේ සැලසුම', 'ta': 'என் திட்டம்'},
  'plan.subtitle': {
    'en': "Today's rehabilitation plan",
    'si': 'අද පුනරුත්ථාපන සැලසුම',
    'ta': 'இன்றைய மறுவாழ்வுத் திட்டம்',
  },
  'plan.notLinked': {
    'en': 'Not yet linked to your tracked sessions',
    'si': 'නිරීක්ෂිත සැසි සමඟ තවම සම්බන්ධ නැත',
    'ta': 'கண்காணிக்கப்பட்ட அமர்வுகளுடன் இணைக்கப்படவில்லை',
  },
  'plan.scheduled': {
    'en': 'Scheduled',
    'si': 'නියමිත',
    'ta': 'திட்டமிடப்பட்டது',
  },
  'plan.activities': {
    'en': 'activities',
    'si': 'ක්‍රියාකාරකම්',
    'ta': 'செயல்பாடுகள்',
  },
  'plan.tracked': {
    'en': 'Tracked exercises',
    'si': 'නිරීක්ෂිත ව්‍යායාම',
    'ta': 'கண்காணிக்கப்படும் பயிற்சிகள்',
  },
  'plan.startToday': {
    'en': "Start today's exercises",
    'si': 'අද ව්‍යායාම අරඹන්න',
    'ta': 'இன்றைய பயிற்சிகளைத் தொடங்கு',
  },
  'plan.startTodaySub': {
    'en': 'Guided sessions with live rep counting and form feedback',
    'si': 'සජීවී ගණන් කිරීම සහ ඉරියව් ප්‍රතිපෝෂණ සමඟ',
    'ta': 'நேரடி எண்ணிக்கை மற்றும் நிலை கருத்துடன்',
  },
  'plan.shoulder': {
    'en': 'Shoulder Exercise',
    'si': 'උරහිස් ව්‍යායාමය',
    'ta': 'தோள் பயிற்சி',
  },
  'plan.walking': {
    'en': 'Walking Practice',
    'si': 'ඇවිදීමේ පුහුණුව',
    'ta': 'நடைப் பயிற்சி',
  },
  'plan.grip': {
    'en': 'Hand Grip Training',
    'si': 'අත් ග්‍රහණ පුහුණුව',
    'ta': 'கைப்பிடிப் பயிற்சி',
  },
  'plan.breathing': {
    'en': 'Breathing Exercise',
    'si': 'ශ්වසන ව්‍යායාමය',
    'ta': 'சுவாசப் பயிற்சி',
  },
  'plan.minutes': {'en': 'minutes', 'si': 'මිනිත්තු', 'ta': 'நிமிடங்கள்'},

  // -- progress -------------------------------------------------------------
  'prog.title': {'en': 'Progress', 'si': 'ප්‍රගතිය', 'ta': 'முன்னேற்றம்'},
  'prog.subtitle': {
    'en': 'Track your rehabilitation journey',
    'si': 'ඔබේ පුනරුත්ථාපන ගමන නිරීක්ෂණය',
    'ta': 'உங்கள் மறுவாழ்வுப் பயணத்தைக் கண்காணிக்க',
  },
  'prog.today': {'en': 'Today', 'si': 'අද', 'ta': 'இன்று'},
  'prog.fromTracked': {
    'en': 'From your tracked sessions',
    'si': 'ඔබේ නිරීක්ෂිත සැසි වලින්',
    'ta': 'கண்காணிக்கப்பட்ட அமர்வுகளிலிருந்து',
  },
  'prog.noSessions': {
    'en': 'No sessions yet today',
    'si': 'අද තවම සැසි නැත',
    'ta': 'இன்று அமர்வுகள் இல்லை',
  },
  'prog.noSessionsSub': {
    'en': 'Finish an exercise and your reps appear here.',
    'si': 'ව්‍යායාමයක් අවසන් කළ පසු මෙහි දිස්වේ.',
    'ta': 'ஒரு பயிற்சியை முடித்தால் இங்கே தோன்றும்.',
  },
  'prog.completed': {
    'en': 'Exercises completed',
    'si': 'අවසන් කළ ව්‍යායාම',
    'ta': 'முடித்த பயிற்சிகள்',
  },
  'prog.totalReps': {
    'en': 'Total reps',
    'si': 'මුළු වාර ගණන',
    'ta': 'மொத்த முறை',
  },
  'prog.averageForm': {
    'en': 'Average form',
    'si': 'සාමාන්‍ය ඉරියව්ව',
    'ta': 'சராசரி நிலை',
  },
  'prog.longerTerm': {
    'en': 'Longer term',
    'si': 'දිගු කාලීන',
    'ta': 'நீண்ட காலம்',
  },
  'prog.sampleFigures': {
    'en': 'Sample figures — not measured yet',
    'si': 'නියැදි අගයන් — තවම මනින ලද නොවේ',
    'ta': 'மாதிரி எண்கள் — இன்னும் அளக்கப்படவில்லை',
  },
  'prog.improvement': {
    'en': 'Recovery improvement',
    'si': 'සුවවීමේ දියුණුව',
    'ta': 'மீட்பு முன்னேற்றம்',
  },
  'prog.placeholder': {
    'en': 'Placeholder pending backend history',
    'si': 'ඉතිහාස දත්ත ලැබෙන තෙක් තාවකාලික අගයකි',
    'ta': 'வரலாற்றுத் தரவு வரும் வரை தற்காலிக மதிப்பு',
  },
  'prog.weekly': {
    'en': 'Weekly sessions',
    'si': 'සතිපතා සැසි',
    'ta': 'வாராந்திர அமர்வுகள்',
  },
  'prog.streak': {'en': 'Day streak', 'si': 'අඛණ්ඩ දින', 'ta': 'தொடர் நாட்கள்'},
  'prog.coachFeedback': {
    'en': 'Coach feedback',
    'si': 'උපදෙස්',
    'ta': 'பயிற்சியாளர் கருத்து',
  },
  'prog.movementQuality': {
    'en': 'Movement quality',
    'si': 'චලන ගුණාත්මකභාවය',
    'ta': 'அசைவுத் தரம்',
  },
  'prog.feedbackBody': {
    'en':
        'Your shoulder mobility has improved this week. Keep going with the daily exercises.',
    'si': 'මෙම සතියේ ඔබේ උරහිස් චලනය දියුණු වී ඇත. දෛනික ව්‍යායාම දිගටම කරන්න.',
    'ta':
        'இந்த வாரம் தோள் அசைவு மேம்பட்டுள்ளது. தினசரி பயிற்சிகளைத் தொடருங்கள்.',
  },

  // -- history --------------------------------------------------------------
  'hist.title': {'en': 'History', 'si': 'ඉතිහාසය', 'ta': 'வரலாறு'},
  'hist.subtitle': {
    'en': 'Completed rehabilitation sessions',
    'si': 'අවසන් කළ පුනරුත්ථාපන සැසි',
    'ta': 'முடிக்கப்பட்ட மறுவாழ்வு அமர்வுகள்',
  },
  'hist.noneToday': {
    'en': 'No sessions recorded today.',
    'si': 'අද සැසි වාර්තා වී නැත.',
    'ta': 'இன்று அமர்வுகள் பதிவாகவில்லை.',
  },
  'hist.earlier': {'en': 'Earlier', 'si': 'පෙර', 'ta': 'முந்தையவை'},
  'hist.sampleData': {
    'en': 'Sample data — history is not synced yet',
    'si': 'නියැදි දත්ත — ඉතිහාසය තවම සමමුහුර්ත නොවේ',
    'ta': 'மாதிரித் தரவு — வரலாறு ஒத்திசைக்கப்படவில்லை',
  },
  'hist.accuracy': {'en': 'Accuracy', 'si': 'නිරවද්‍යතාව', 'ta': 'துல்லியம்'},

  // -- care -----------------------------------------------------------------
  'care.title': {'en': 'Care', 'si': 'සත්කාරය', 'ta': 'பராமரிப்பு'},
  'care.subtitle': {
    'en': 'Stay connected with your recovery team',
    'si': 'ඔබේ සුවවීමේ කණ්ඩායම සමඟ සම්බන්ධ වන්න',
    'ta': 'உங்கள் மீட்புக் குழுவுடன் இணைந்திருங்கள்',
  },
  'care.assignedPhysio': {
    'en': 'ASSIGNED PHYSIOTHERAPIST',
    'si': 'නියමිත භෞත චිකිත්සක',
    'ta': 'நியமிக்கப்பட்ட இயன்முறை மருத்துவர்',
  },
  'care.availableNow': {
    'en': 'Available now',
    'si': 'දැන් ලබා ගත හැක',
    'ta': 'இப்போது கிடைக்கிறார்',
  },
  'care.chatNow': {
    'en': 'Chat now',
    'si': 'දැන් කතා කරන්න',
    'ta': 'இப்போது உரையாடு',
  },
  'care.dailyReport': {
    'en': 'Daily recovery report',
    'si': 'දෛනික සුවවීමේ වාර්තාව',
    'ta': 'தினசரி மீட்பு அறிக்கை',
  },
  'care.dailyReportBody': {
    'en': 'Your progress today is improving well.',
    'si': 'අද ඔබේ ප්‍රගතිය හොඳින් දියුණු වෙමින් පවතී.',
    'ta': 'இன்று உங்கள் முன்னேற்றம் நன்றாக உள்ளது.',
  },
  'care.advice': {
    'en': 'Physiotherapy advice',
    'si': 'භෞත චිකිත්සක උපදෙස්',
    'ta': 'இயன்முறை ஆலோசனை',
  },
  'care.adviceBody': {
    'en':
        'Focus on slow shoulder movements and avoid sudden arm lifting today.',
    'si': 'අද සෙමින් උරහිස් චලනය කරන්න, හදිසියේ අත ඔසවීමෙන් වළකින්න.',
    'ta':
        'இன்று மெதுவான தோள் அசைவில் கவனம் செலுத்துங்கள், திடீர் கை உயர்த்தலைத் தவிர்க்கவும்.',
  },
  'care.emergencyAssist': {
    'en': 'Emergency assistance',
    'si': 'හදිසි සහාය',
    'ta': 'அவசர உதவி',
  },
  'care.emergencyAssistBody': {
    'en': 'Contact your caregiver or emergency support immediately.',
    'si': 'වහාම ඔබේ රැකබලා ගන්නා හෝ හදිසි සේවා අමතන්න.',
    'ta': 'உடனே உங்கள் பராமரிப்பாளரையோ அவசர சேவையையோ தொடர்பு கொள்ளுங்கள்.',
  },

  // -- caregiver / physio ---------------------------------------------------
  'cg.title': {'en': 'Caregiver', 'si': 'රැකබලා ගන්නා', 'ta': 'பராமரிப்பாளர்'},
  'cg.subtitle': {
    'en': 'Monitor patient wellbeing and alerts',
    'si': 'රෝගියාගේ සුවතාව සහ ඇඟවීම් නිරීක්ෂණය',
    'ta': 'நோயாளியின் நலனையும் எச்சரிக்கைகளையும் கண்காணிக்க',
  },
  'cg.fallAlert': {
    'en': 'FALL ALERT',
    'si': 'වැටීමේ ඇඟවීම',
    'ta': 'விழுந்த எச்சரிக்கை',
  },
  'cg.mayHaveFallen': {
    'en': 'may have fallen',
    'si': 'වැටී ඇති හැකියාව',
    'ta': 'விழுந்திருக்கலாம்',
  },
  'cg.immediate': {
    'en': 'Immediate attention required',
    'si': 'වහාම අවධානය අවශ්‍යයි',
    'ta': 'உடனடி கவனம் தேவை',
  },
  'cg.openEmergency': {
    'en': 'Open emergency screen',
    'si': 'හදිසි තිරය විවෘත කරන්න',
    'ta': 'அவசரத் திரையைத் திற',
  },
  'cg.cannotReachAlerts': {
    'en': 'Cannot reach the alert service',
    'si': 'ඇඟවීම් සේවාවට සම්බන්ධ විය නොහැක',
    'ta': 'எச்சரிக்கை சேவையை அணுக முடியவில்லை',
  },
  'cg.alertsPaused': {
    'en': 'Fall alerts will not appear until the connection is restored.',
    'si': 'සම්බන්ධතාවය යථා තත්ත්වයට පත්වන තෙක් ඇඟවීම් නොපෙන්වයි.',
    'ta': 'இணைப்பு மீளும் வரை எச்சரிக்கைகள் தோன்றாது.',
  },
  'cg.patient': {'en': 'Patient', 'si': 'රෝගියා', 'ta': 'நோயாளி'},
  'cg.recoveryProgress': {
    'en': 'Recovery progress',
    'si': 'සුවවීමේ ප්‍රගතිය',
    'ta': 'மீட்பு முன்னேற்றம்',
  },
  'cg.lastSessionToday': {
    'en': 'Last session today',
    'si': 'අද අවසන් සැසිය',
    'ta': 'இன்றைய கடைசி அமர்வு',
  },
  'cg.reminders': {
    'en': 'Reminders',
    'si': 'මතක් කිරීම්',
    'ta': 'நினைவூட்டல்கள்',
  },
  'cg.medReminder': {
    'en': 'Medication reminder',
    'si': 'ඖෂධ මතක් කිරීම',
    'ta': 'மருந்து நினைவூட்டல்',
  },
  'cg.bpMed': {
    'en': 'Blood pressure medication',
    'si': 'රුධිර පීඩන ඖෂධ',
    'ta': 'இரத்த அழுத்த மருந்து',
  },
  'cg.upcomingTherapy': {
    'en': 'Upcoming therapy session',
    'si': 'ඉදිරි ප්‍රතිකාර සැසිය',
    'ta': 'வரவிருக்கும் சிகிச்சை',
  },
  'cg.contactPhysio': {
    'en': 'Contact physiotherapist',
    'si': 'භෞත චිකිත්සක අමතන්න',
    'ta': 'மருத்துவரைத் தொடர்பு கொள்ள',
  },

  'physio.title': {
    'en': 'Physiotherapist',
    'si': 'භෞත චිකිත්සක',
    'ta': 'இயன்முறை மருத்துவர்',
  },
  'physio.subtitle': {
    'en': 'Monitor patient rehabilitation progress',
    'si': 'රෝගීන්ගේ පුනරුත්ථාපන ප්‍රගතිය නිරීක්ෂණය',
    'ta': 'நோயாளிகளின் மறுவாழ்வு முன்னேற்றத்தைக் கண்காணிக்க',
  },
  'physio.patients': {'en': 'Patients', 'si': 'රෝගීන්', 'ta': 'நோயாளிகள்'},
  'physio.sessionsToday': {
    'en': 'Sessions today',
    'si': 'අද සැසි',
    'ta': 'இன்றைய அமர்வுகள்',
  },
  'physio.active': {'en': 'active', 'si': 'සක්‍රීය', 'ta': 'செயலில்'},
  'physio.recovery': {'en': 'Recovery', 'si': 'සුවවීම', 'ta': 'மீட்பு'},
  'physio.lastSession': {
    'en': 'Last session',
    'si': 'අවසන් සැසිය',
    'ta': 'கடைசி அமர்வு',
  },
  'physio.recommendation': {
    'en': 'Recommendation',
    'si': 'නිර්දේශය',
    'ta': 'பரிந்துரை',
  },
  'physio.sampleInsight': {
    'en': 'Sample insight',
    'si': 'නියැදි විශ්ලේෂණය',
    'ta': 'மாதிரி பகுப்பாய்வு',
  },
  'physio.recommendBody': {
    'en':
        '3 patients would benefit from increased shoulder mobility exercises this week.',
    'si':
        'මෙම සතියේ රෝගීන් 3 දෙනෙකුට උරහිස් චලන ව්‍යායාම වැඩි කිරීම ප්‍රයෝජනවත් වේ.',
    'ta':
        'இந்த வாரம் 3 நோயாளிகளுக்கு தோள் அசைவுப் பயிற்சிகளை அதிகரிப்பது நல்லது.',
  },

  // -- profile / settings ---------------------------------------------------
  'profile.title': {
    'en': 'My Profile',
    'si': 'මගේ පැතිකඩ',
    'ta': 'என் சுயவிவரம்',
  },
  'profile.patientRole': {
    'en': 'Stroke recovery patient',
    'si': 'ආඝාත සුවවීමේ රෝගියා',
    'ta': 'பக்கவாத மீட்பு நோயாளி',
  },
  'profile.medicalInfo': {
    'en': 'Medical information',
    'si': 'වෛද්‍ය තොරතුරු',
    'ta': 'மருத்துவத் தகவல்',
  },
  'profile.age': {'en': 'Age', 'si': 'වයස', 'ta': 'வயது'},
  'profile.bloodGroup': {
    'en': 'Blood group',
    'si': 'රුධිර කාණ්ඩය',
    'ta': 'இரத்தப் பிரிவு',
  },
  'profile.strokeType': {
    'en': 'Stroke type',
    'si': 'ආඝාත වර්ගය',
    'ta': 'பக்கவாத வகை',
  },
  'profile.ischemic': {
    'en': 'Ischemic stroke',
    'si': 'ඉස්කිමික් ආඝාතය',
    'ta': 'இஸ்கிமிக் பக்கவாதம்',
  },
  'profile.emergencyContact': {
    'en': 'Emergency contact',
    'si': 'හදිසි සම්බන්ධතාවය',
    'ta': 'அவசரத் தொடர்பு',
  },
  'profile.primaryCaregiver': {
    'en': 'Primary caregiver',
    'si': 'ප්‍රධාන රැකබලා ගන්නා',
    'ta': 'முதன்மைப் பராமரிப்பாளர்',
  },
  'profile.preferences': {
    'en': 'Preferences',
    'si': 'මනාපයන්',
    'ta': 'விருப்பங்கள்',
  },
  'profile.languageSub': {
    'en': 'Used for exercise names and coaching cues',
    'si': 'ව්‍යායාම නාම සහ උපදෙස් සඳහා',
    'ta': 'பயிற்சிப் பெயர்கள் மற்றும் அறிவுரைகளுக்கு',
  },
  'profile.accessibility': {
    'en': 'Accessibility & notifications',
    'si': 'ප්‍රවේශ්‍යතාව සහ දැනුම්දීම්',
    'ta': 'அணுகல் மற்றும் அறிவிப்புகள்',
  },
  'profile.help': {'en': 'Help', 'si': 'උදව්', 'ta': 'உதவி'},
  'profile.about': {
    'en': 'About this app',
    'si': 'මෙම යෙදුම ගැන',
    'ta': 'இந்த செயலி பற்றி',
  },
  'profile.edit': {
    'en': 'Edit profile',
    'si': 'පැතිකඩ සංස්කරණය',
    'ta': 'சுயவிவரத்தைத் திருத்து',
  },

  'set.title': {'en': 'Settings', 'si': 'සැකසුම්', 'ta': 'அமைப்புகள்'},
  'set.subtitle': {
    'en': 'Customise your rehabilitation experience',
    'si': 'ඔබේ පුනරුත්ථාපන අත්දැකීම සකසන්න',
    'ta': 'உங்கள் மறுவாழ்வு அனுபவத்தை அமைக்கவும்',
  },
  'set.accessibility': {
    'en': 'Accessibility',
    'si': 'ප්‍රවේශ්‍යතාව',
    'ta': 'அணுகல்',
  },
  'set.voice': {'en': 'Voice assistance', 'si': 'හඬ සහාය', 'ta': 'குரல் உதவி'},
  'set.voiceSub': {
    'en': 'Spoken guidance during exercises',
    'si': 'ව්‍යායාම අතරතුර හඬ මඟපෙන්වීම',
    'ta': 'பயிற்சியின்போது குரல் வழிகாட்டல்',
  },
  'set.contrast': {
    'en': 'Higher contrast',
    'si': 'වැඩි වර්ණ වෙනස',
    'ta': 'அதிக மாறுபாடு',
  },
  'set.contrastSub': {
    'en': 'Stronger colour separation for easier reading',
    'si': 'පහසු කියවීම සඳහා වර්ණ වෙනස වැඩි කරයි',
    'ta': 'எளிதாகப் படிக்க வண்ண வேறுபாட்டை அதிகரிக்கும்',
  },
  'set.notifications': {
    'en': 'Notifications',
    'si': 'දැනුම්දීම්',
    'ta': 'அறிவிப்புகள்',
  },
  'set.medReminders': {
    'en': 'Medication reminders',
    'si': 'ඖෂධ මතක් කිරීම්',
    'ta': 'மருந்து நினைவூட்டல்கள்',
  },
  'set.medRemindersSub': {
    'en': 'Daily reminders at your scheduled times',
    'si': 'නියමිත වේලාවන්හි දෛනික මතක් කිරීම්',
    'ta': 'குறித்த நேரங்களில் தினசரி நினைவூட்டல்கள்',
  },

  // -- help / about ---------------------------------------------------------
  'help.title': {'en': 'Help', 'si': 'උදව්', 'ta': 'உதவி'},
  'help.subtitle': {
    'en': 'Common questions and support',
    'si': 'පොදු ප්‍රශ්න සහ සහාය',
    'ta': 'பொதுவான கேள்விகளும் ஆதரவும்',
  },
  'help.q1': {
    'en': 'How do I start an exercise?',
    'si': 'ව්‍යායාමයක් අරඹන්නේ කෙසේද?',
    'ta': 'பயிற்சியை எப்படித் தொடங்குவது?',
  },
  'help.a1': {
    'en':
        'Open Exercises from the home screen and choose one. The app counts your reps as you move.',
    'si':
        'මුල් පිටුවෙන් ව්‍යායාම විවෘත කර එකක් තෝරන්න. ඔබ චලනය වන විට යෙදුම ගණන් කරයි.',
    'ta':
        'முகப்பிலிருந்து பயிற்சிகளைத் திறந்து ஒன்றைத் தேர்வு செய்யுங்கள். நீங்கள் அசையும்போது செயலி எண்ணும்.',
  },
  'help.q2': {
    'en': 'How does the movement tracking work?',
    'si': 'චලන නිරීක්ෂණය ක්‍රියා කරන්නේ කෙසේද?',
    'ta': 'அசைவுக் கண்காணிப்பு எப்படி வேலை செய்கிறது?',
  },
  'help.a2': {
    'en':
        'Your phone camera watches your body position and measures joint angles.',
    'si': 'ඔබේ දුරකථන කැමරාව සිරුරේ ඉරියව්ව බලා සන්ධි කෝණ මනියි.',
    'ta':
        'உங்கள் தொலைபேசி கேமரா உடல் நிலையைப் பார்த்து மூட்டுக் கோணங்களை அளக்கிறது.',
  },
  'help.q3': {
    'en': 'How do emergency alerts work?',
    'si': 'හදිසි ඇඟවීම් ක්‍රියා කරන්නේ කෙසේද?',
    'ta': 'அவசர எச்சரிக்கைகள் எப்படி வேலை செய்கின்றன?',
  },
  'help.a3': {
    'en':
        'If a fall is detected your caregiver is alerted automatically. You have ten seconds to cancel.',
    'si':
        'වැටීමක් හඳුනාගත් විට රැකබලා ගන්නාට ස්වයංක්‍රීයව දැනුම් දේ. අවලංගු කිරීමට තත්පර දහයක් ඇත.',
    'ta':
        'விழுந்தால் பராமரிப்பாளருக்குத் தானாக அறிவிக்கப்படும். ரத்து செய்ய பத்து வினாடிகள் உள்ளன.',
  },
  'help.q4': {
    'en': 'Can I use voice commands?',
    'si': 'හඬ විධාන භාවිත කළ හැකිද?',
    'ta': 'குரல் கட்டளைகளைப் பயன்படுத்தலாமா?',
  },
  'help.a4': {
    'en': 'Voice guidance is planned for navigating exercises hands-free.',
    'si': 'අත් නොයොදා ව්‍යායාම හැසිරවීමට හඬ මඟපෙන්වීම සැලසුම් කර ඇත.',
    'ta':
        'கைகள் இல்லாமல் பயிற்சிகளை இயக்க குரல் வழிகாட்டல் திட்டமிடப்பட்டுள்ளது.',
  },
  'help.needMore': {
    'en': 'Need more help?',
    'si': 'තවත් උදව් අවශ්‍යද?',
    'ta': 'மேலும் உதவி தேவையா?',
  },
  'help.needMoreBody': {
    'en':
        'Contact Neuro Pulse Ceylon support, or ask your caregiver or physiotherapist.',
    'si':
        'Neuro Pulse Ceylon සහාය අමතන්න, නැතහොත් රැකබලා ගන්නාගෙන් හෝ චිකිත්සකයාගෙන් අසන්න.',
    'ta':
        'Neuro Pulse Ceylon ஆதரவைத் தொடர்பு கொள்ளுங்கள், அல்லது உங்கள் பராமரிப்பாளரிடம் கேளுங்கள்.',
  },

  'about.title': {'en': 'About', 'si': 'පිළිබඳව', 'ta': 'பற்றி'},
  'about.subtitle': {
    'en': 'Stroke rehabilitation platform',
    'si': 'ආඝාත පුනරුත්ථාපන වේදිකාව',
    'ta': 'பக்கவாத மறுவாழ்வு தளம்',
  },
  'about.overview': {
    'en': 'Project overview',
    'si': 'ව්‍යාපෘති දළ විශ්ලේෂණය',
    'ta': 'திட்ட மேலோட்டம்',
  },
  'about.overviewBody': {
    'en':
        'A mobile rehabilitation platform supporting stroke recovery with guided exercises and automatic movement tracking.',
    'si':
        'මඟපෙන්වන ලද ව්‍යායාම සහ ස්වයංක්‍රීය චලන නිරීක්ෂණය සමඟ ආඝාත සුවවීමට සහාය වන ජංගම වේදිකාවකි.',
    'ta':
        'வழிகாட்டப்பட்ட பயிற்சிகளுடனும் தானியங்கி அசைவுக் கண்காணிப்புடனும் பக்கவாத மீட்புக்கு உதவும் கைபேசி தளம்.',
  },
  'about.features': {
    'en': 'Key features',
    'si': 'ප්‍රධාන අංග',
    'ta': 'முக்கிய அம்சங்கள்',
  },
  'about.f1': {
    'en': 'Exercise tracking with live rep counting',
    'si': 'සජීවී ගණන් කිරීම සමඟ ව්‍යායාම නිරීක්ෂණය',
    'ta': 'நேரடி எண்ணிக்கையுடன் பயிற்சிக் கண்காணிப்பு',
  },
  'about.f2': {
    'en': 'Form feedback from joint-angle measurement',
    'si': 'සන්ධි කෝණ මැනීමෙන් ඉරියව් ප්‍රතිපෝෂණය',
    'ta': 'மூட்டுக் கோண அளவீட்டிலிருந்து நிலைக் கருத்து',
  },
  'about.f3': {
    'en': 'Fall detection and SOS alerts',
    'si': 'වැටීම් හඳුනාගැනීම සහ හදිසි ඇඟවීම්',
    'ta': 'விழுதல் கண்டறிதலும் அவசர எச்சரிக்கையும்',
  },
  'about.f4': {
    'en': 'Progress monitoring',
    'si': 'ප්‍රගති නිරීක්ෂණය',
    'ta': 'முன்னேற்றக் கண்காணிப்பு',
  },
  'about.f5': {
    'en': 'Physiotherapist support',
    'si': 'භෞත චිකිත්සක සහාය',
    'ta': 'இயன்முறை மருத்துவர் ஆதரவு',
  },
  'about.builtWith': {
    'en': 'Built with',
    'si': 'නිර්මාණය කර ඇත්තේ',
    'ta': 'உருவாக்கப்பட்டது',
  },
  'about.project': {'en': 'Project', 'si': 'ව්‍යාපෘතිය', 'ta': 'திட்டம்'},
  'about.finalYear': {
    'en': 'Final year research project',
    'si': 'අවසන් වසර පර්යේෂණ ව්‍යාපෘතිය',
    'ta': 'இறுதி ஆண்டு ஆய்வுத் திட்டம்',
  },
  'about.projectBody': {
    'en':
        'Developed as research into intelligent healthcare support for stroke rehabilitation in Sri Lanka.',
    'si':
        'ශ්‍රී ලංකාවේ ආඝාත පුනරුත්ථාපනය සඳහා බුද්ධිමත් සෞඛ්‍ය සහාය පිළිබඳ පර්යේෂණයක් ලෙස සංවර්ධනය කරන ලදී.',
    'ta':
        'இலங்கையில் பக்கவாத மறுவாழ்வுக்கான அறிவார்ந்த சுகாதார ஆதரவு குறித்த ஆய்வாக உருவாக்கப்பட்டது.',
  },

  // -- notifications --------------------------------------------------------
  'notif.title': {
    'en': 'Notifications',
    'si': 'දැනුම්දීම්',
    'ta': 'அறிவிப்புகள்',
  },
  'notif.subtitle': {
    'en': 'Stay updated with your recovery',
    'si': 'ඔබේ සුවවීම පිළිබඳ යාවත්කාලීනව සිටින්න',
    'ta': 'உங்கள் மீட்பு குறித்து அறிந்திருங்கள்',
  },
  'notif.medBody': {
    'en': 'Time to take your blood pressure medication.',
    'si': 'රුධිර පීඩන ඖෂධ ගැනීමට වේලාවයි.',
    'ta': 'இரத்த அழுத்த மருந்து எடுக்கும் நேரம்.',
  },
  'notif.sessionDue': {
    'en': 'Exercise session due',
    'si': 'ව්‍යායාම සැසිය නියමිතයි',
    'ta': 'பயிற்சி அமர்வு நிலுவை',
  },
  'notif.sessionBody': {
    'en': 'Shoulder mobility exercise is scheduled now.',
    'si': 'උරහිස් චලන ව්‍යායාමය දැන් නියමිතයි.',
    'ta': 'தோள் அசைவுப் பயிற்சி இப்போது திட்டமிடப்பட்டுள்ளது.',
  },
  'notif.insight': {
    'en': 'New insight available',
    'si': 'නව විශ්ලේෂණයක්',
    'ta': 'புதிய பகுப்பாய்வு',
  },
  'notif.insightBody': {
    'en': 'Your recovery performance improved this week.',
    'si': 'මෙම සතියේ ඔබේ සුවවීම දියුණු වී ඇත.',
    'ta': 'இந்த வாரம் உங்கள் மீட்பு மேம்பட்டுள்ளது.',
  },
  'notif.physioMsg': {
    'en': 'Physiotherapist message',
    'si': 'චිකිත්සකයාගේ පණිවිඩය',
    'ta': 'மருத்துவர் செய்தி',
  },
  'notif.physioMsgBody': {
    'en': 'New rehabilitation advice received.',
    'si': 'නව පුනරුත්ථාපන උපදෙස් ලැබී ඇත.',
    'ta': 'புதிய மறுவாழ்வு ஆலோசனை வந்துள்ளது.',
  },

  // -- report / schedule / appointments -------------------------------------
  'report.title': {
    'en': 'Recovery Report',
    'si': 'සුවවීමේ වාර්තාව',
    'ta': 'மீட்பு அறிக்கை',
  },
  'report.subtitle': {
    'en': 'Rehabilitation summary',
    'si': 'පුනරුත්ථාපන සාරාංශය',
    'ta': 'மறுவாழ்வுச் சுருக்கம்',
  },
  'report.sample': {
    'en': 'Sample report — figures are not measured',
    'si': 'නියැදි වාර්තාවකි — අගයන් මනින ලද නොවේ',
    'ta': 'மாதிரி அறிக்கை — எண்கள் அளக்கப்படவில்லை',
  },
  'report.notClinical': {
    'en':
        'Not for clinical use. Ask your physiotherapist to interpret any measurement.',
    'si': 'සායනික භාවිතය සඳහා නොවේ. ඕනෑම මිනුමක් ගැන චිකිත්සකයාගෙන් අසන්න.',
    'ta':
        'மருத்துவப் பயன்பாட்டுக்கு அல்ல. எந்த அளவீட்டையும் மருத்துவரிடம் கேளுங்கள்.',
  },
  'report.name': {'en': 'Name', 'si': 'නම', 'ta': 'பெயர்'},
  'report.statistics': {
    'en': 'Statistics',
    'si': 'සංඛ්‍යාලේඛන',
    'ta': 'புள்ளிவிவரங்கள்',
  },
  'report.accuracy': {
    'en': 'Exercise accuracy',
    'si': 'ව්‍යායාම නිරවද්‍යතාව',
    'ta': 'பயிற்சித் துல்லியம்',
  },
  'report.improvementRate': {
    'en': 'Improvement rate',
    'si': 'දියුණුවේ අනුපාතය',
    'ta': 'முன்னேற்ற விகிதம்',
  },
  'report.summary': {'en': 'Summary', 'si': 'සාරාංශය', 'ta': 'சுருக்கம்'},
  'report.summaryBody': {
    'en': 'Strong improvement in upper limb mobility and balance coordination.',
    'si': 'උඩු අත්පා චලනය සහ සමතුලිතතාවයේ ශක්තිමත් දියුණුවක්.',
    'ta': 'மேல் மூட்டு அசைவிலும் சமநிலையிலும் நல்ல முன்னேற்றம்.',
  },
  'report.physioNotes': {
    'en': 'Physiotherapist notes',
    'si': 'චිකිත්සක සටහන්',
    'ta': 'மருத்துவர் குறிப்புகள்',
  },
  'report.physioNotesBody': {
    'en':
        'Patient demonstrates better posture control and shoulder movement this week.',
    'si': 'මෙම සතියේ රෝගියාගේ ඉරියව් පාලනය සහ උරහිස් චලනය වඩා හොඳය.',
    'ta':
        'இந்த வாரம் நோயாளியின் தோரணைக் கட்டுப்பாடும் தோள் அசைவும் சிறப்பாக உள்ளது.',
  },

  'sched.title': {'en': 'Schedule', 'si': 'කාලසටහන', 'ta': 'அட்டவணை'},
  'sched.subtitle': {
    'en': 'Your upcoming rehabilitation sessions',
    'si': 'ඔබේ ඉදිරි පුනරුත්ථාපන සැසි',
    'ta': 'உங்கள் வரவிருக்கும் மறுவாழ்வு அமர்வுகள்',
  },
  'sched.thisWeek': {'en': 'This week', 'si': 'මෙම සතිය', 'ta': 'இந்த வாரம்'},
  'sched.reminder': {'en': 'Reminder', 'si': 'මතක් කිරීම', 'ta': 'நினைவூட்டல்'},
  'sched.reminderBody': {
    'en':
        'Try to complete at least one exercise every day. Little and often works better than one long session.',
    'si':
        'දිනකට අවම වශයෙන් එක් ව්‍යායාමයක් කරන්න. දිගු සැසියකට වඩා කෙටි නමුත් නිතර හොඳය.',
    'ta':
        'ஒவ்வொரு நாளும் குறைந்தது ஒரு பயிற்சியாவது செய்யுங்கள். நீண்ட அமர்வை விட குறுகிய தொடர் பயிற்சி சிறந்தது.',
  },

  'appt.title': {'en': 'Appointments', 'si': 'හමුවීම්', 'ta': 'சந்திப்புகள்'},
  'appt.subtitle': {
    'en': 'Book your rehabilitation sessions',
    'si': 'ඔබේ පුනරුත්ථාපන සැසි වෙන් කරන්න',
    'ta': 'உங்கள் மறுவாழ்வு அமர்வுகளை முன்பதிவு செய்யவும்',
  },
  'appt.upcoming': {'en': 'Upcoming', 'si': 'ඉදිරි', 'ta': 'வரவிருக்கும்'},
  'appt.availableSlots': {
    'en': 'Available slots',
    'si': 'ලබා ගත හැකි වේලාවන්',
    'ta': 'கிடைக்கும் நேரங்கள்',
  },
  'appt.selectSlot': {
    'en': 'Select a time slot',
    'si': 'වේලාවක් තෝරන්න',
    'ta': 'ஒரு நேரத்தைத் தேர்ந்தெடுக்கவும்',
  },
  'appt.book': {'en': 'Book', 'si': 'වෙන් කරන්න', 'ta': 'முன்பதிவு'},
  'appt.selected': {
    'en': 'Selected',
    'si': 'තෝරාගත්',
    'ta': 'தேர்ந்தெடுக்கப்பட்டது',
  },
  'appt.requested': {'en': 'Requested', 'si': 'ඉල්ලා ඇත', 'ta': 'கோரப்பட்டது'},
  'appt.unit': {
    'en': 'Neuro Rehabilitation Unit',
    'si': 'ස්නායු පුනරුත්ථාපන ඒකකය',
    'ta': 'நரம்பு மறுவாழ்வு பிரிவு',
  },

  // -- explore / leaderboard / insights / brain / voice / chat --------------
  'explore.title': {'en': 'Explore', 'si': 'ගවේෂණය', 'ta': 'ஆராயுங்கள்'},
  'explore.subtitle': {
    'en': 'Everything in Neuro Pulse Ceylon',
    'si': 'Neuro Pulse Ceylon හි සියල්ල',
    'ta': 'Neuro Pulse Ceylon இல் உள்ள அனைத்தும்',
  },
  'explore.rehab': {
    'en': 'Rehabilitation',
    'si': 'පුනරුත්ථාපනය',
    'ta': 'மறுவாழ்வு',
  },
  'explore.tracking': {
    'en': 'Tracking',
    'si': 'නිරීක්ෂණය',
    'ta': 'கண்காணிப்பு',
  },
  'explore.support': {'en': 'Support', 'si': 'සහාය', 'ta': 'ஆதரவு'},

  'lead.title': {
    'en': 'Leaderboard',
    'si': 'ප්‍රමුඛ ලැයිස්තුව',
    'ta': 'தரவரிசை',
  },
  'lead.subtitle': {
    'en': 'Stay motivated through progress',
    'si': 'ප්‍රගතිය තුළින් උනන්දුව රැක ගන්න',
    'ta': 'முன்னேற்றத்தால் ஊக்கம் பெறுங்கள்',
  },
  'lead.points': {
    'en': 'recovery points',
    'si': 'සුවවීමේ ලකුණු',
    'ta': 'மீட்புப் புள்ளிகள்',
  },
  'lead.you': {'en': 'You', 'si': 'ඔබ', 'ta': 'நீங்கள்'},
  'lead.motivation': {
    'en': 'Daily motivation',
    'si': 'දෛනික උනන්දුව',
    'ta': 'தினசரி ஊக்கம்',
  },
  'lead.motivationBody': {
    'en':
        'Consistency leads to stronger recovery. Small daily sessions beat occasional long ones.',
    'si': 'අඛණ්ඩතාව ශක්තිමත් සුවවීමකට මඟ පාදයි. කුඩා දෛනික සැසි වඩා හොඳය.',
    'ta':
        'தொடர்ச்சி வலுவான மீட்புக்கு வழிவகுக்கும். சிறிய தினசரி அமர்வுகளே சிறந்தவை.',
  },

  'ins.title': {'en': 'Insights', 'si': 'විශ්ලේෂණ', 'ta': 'பகுப்பாய்வு'},
  'ins.subtitle': {
    'en': 'Personalised rehabilitation analysis',
    'si': 'පුද්ගලීකරණය කළ විශ්ලේෂණය',
    'ta': 'தனிப்பயன் பகுப்பாய்வு',
  },
  'ins.illustrative': {
    'en': 'Illustrative only — not computed from your data',
    'si': 'නිදර්ශන පමණි — ඔබේ දත්ත වලින් ගණනය නොකෙරේ',
    'ta': 'விளக்கத்திற்கு மட்டுமே — உங்கள் தரவிலிருந்து அல்ல',
  },
  'ins.weekly': {
    'en': 'Weekly analysis',
    'si': 'සතිපතා විශ්ලේෂණය',
    'ta': 'வாராந்திர பகுப்பாய்வு',
  },
  'ins.weeklyBody': {
    'en': 'Upper limb mobility improved by 12% this week.',
    'si': 'මෙම සතියේ උඩු අත්පා චලනය 12%කින් දියුණු විය.',
    'ta': 'இந்த வாரம் மேல் மூட்டு அசைவு 12% மேம்பட்டது.',
  },
  'ins.recommended': {
    'en': 'Recommended exercise',
    'si': 'නිර්දේශිත ව්‍යායාමය',
    'ta': 'பரிந்துரைக்கப்பட்ட பயிற்சி',
  },
  'ins.recommendedBody': {
    'en': 'Increase shoulder mobility sessions.',
    'si': 'උරහිස් චලන සැසි වැඩි කරන්න.',
    'ta': 'தோள் அசைவு அமர்வுகளை அதிகரிக்கவும்.',
  },
  'ins.observation': {'en': 'Observation', 'si': 'නිරීක්ෂණය', 'ta': 'கவனிப்பு'},
  'ins.observationBody': {
    'en': 'Slight imbalance detected during standing exercises.',
    'si': 'සිටගෙන කරන ව්‍යායාම වලදී සුළු අසමතුලිතතාවක්.',
    'ta': 'நின்று செய்யும் பயிற்சிகளில் சிறிய சமநிலையின்மை.',
  },
  'ins.outlook': {
    'en': 'Recovery outlook',
    'si': 'සුවවීමේ අපේක්ෂාව',
    'ta': 'மீட்பு எதிர்பார்ப்பு',
  },
  'ins.outlookBody': {
    'en':
        'Example projection over six weeks. Ask your physiotherapist for a real assessment.',
    'si':
        'සති හයක උදාහරණ පුරෝකථනයකි. සැබෑ තක්සේරුවක් සඳහා චිකිත්සකයාගෙන් අසන්න.',
    'ta':
        'ஆறு வாரங்களுக்கான உதாரணக் கணிப்பு. உண்மையான மதிப்பீட்டுக்கு மருத்துவரிடம் கேளுங்கள்.',
  },

  'brain.title': {
    'en': 'Brain Training',
    'si': 'මොළ පුහුණුව',
    'ta': 'மூளைப் பயிற்சி',
  },
  'brain.subtitle': {
    'en': 'Cognitive rehabilitation activities',
    'si': 'සංජානන පුනරුත්ථාපන ක්‍රියාකාරකම්',
    'ta': 'அறிவாற்றல் மறுவாழ்வு செயல்பாடுகள்',
  },
  'brain.memory': {
    'en': 'Memory Match',
    'si': 'මතක ගැලපීම',
    'ta': 'நினைவுப் பொருத்தம்',
  },
  'brain.memorySub': {
    'en': 'Improve short-term memory and concentration.',
    'si': 'කෙටි කාලීන මතකය සහ අවධානය දියුණු කරයි.',
    'ta': 'குறுகிய கால நினைவாற்றலையும் கவனத்தையும் மேம்படுத்தும்.',
  },
  'brain.reaction': {
    'en': 'Reaction Training',
    'si': 'ප්‍රතිචාර පුහුණුව',
    'ta': 'எதிர்வினைப் பயிற்சி',
  },
  'brain.reactionSub': {
    'en': 'Enhance reaction speed and response time.',
    'si': 'ප්‍රතිචාර වේගය වැඩි කරයි.',
    'ta': 'எதிர்வினை வேகத்தை அதிகரிக்கும்.',
  },
  'brain.focus': {
    'en': 'Focus Challenge',
    'si': 'අවධාන අභියෝගය',
    'ta': 'கவன சவால்',
  },
  'brain.focusSub': {
    'en': 'Strengthen attention and concentration.',
    'si': 'අවධානය ශක්තිමත් කරයි.',
    'ta': 'கவனத்தை வலுப்படுத்தும்.',
  },
  'brain.notAvailable': {
    'en': 'This activity is not available yet.',
    'si': 'මෙම ක්‍රියාකාරකම තවම නොමැත.',
    'ta': 'இந்தச் செயல்பாடு இன்னும் இல்லை.',
  },
  'brain.why': {
    'en': 'Why this helps',
    'si': 'මෙය උපකාරී වන්නේ ඇයි',
    'ta': 'இது ஏன் உதவுகிறது',
  },
  'brain.whyBody': {
    'en':
        'Daily cognitive exercises may support memory and mental sharpness alongside physical rehabilitation.',
    'si': 'දෛනික සංජානන ව්‍යායාම මතකයට සහ මානසික තියුණුබවට උපකාරී විය හැක.',
    'ta':
        'தினசரி அறிவாற்றல் பயிற்சிகள் நினைவாற்றலுக்கும் மனத் தெளிவுக்கும் உதவலாம்.',
  },

  'voice.title': {
    'en': 'Voice Assistant',
    'si': 'හඬ සහායක',
    'ta': 'குரல் உதவியாளர்',
  },
  'voice.subtitle': {
    'en': 'Speak commands for easier navigation',
    'si': 'පහසු භාවිතය සඳහා හඬ විධාන',
    'ta': 'எளிதாகப் பயன்படுத்த குரல் கட்டளைகள்',
  },
  'voice.listening': {
    'en': 'Listening…',
    'si': 'සවන් දෙමින්…',
    'ta': 'கேட்கிறது…',
  },
  'voice.tapToStart': {
    'en': 'Tap the button below to start',
    'si': 'ආරම්භ කිරීමට පහත බොත්තම ඔබන්න',
    'ta': 'தொடங்க கீழே உள்ள பொத்தானை அழுத்தவும்',
  },
  'voice.notWired': {
    'en': 'Not available yet',
    'si': 'තවම නොමැත',
    'ta': 'இன்னும் இல்லை',
  },
  'voice.trySaying': {
    'en': 'Try saying',
    'si': 'මෙසේ කියන්න',
    'ta': 'இப்படிச் சொல்லுங்கள்',
  },
  'voice.start': {
    'en': 'Start voice assistant',
    'si': 'හඬ සහායක අරඹන්න',
    'ta': 'குரல் உதவியாளரைத் தொடங்கு',
  },
  'voice.stop': {'en': 'Stop listening', 'si': 'නවත්වන්න', 'ta': 'நிறுத்து'},
  'voice.cmdStart': {
    'en': 'Start exercise',
    'si': 'ව්‍යායාමය අරඹන්න',
    'ta': 'பயிற்சியைத் தொடங்கு',
  },
  'voice.cmdCall': {
    'en': 'Call caregiver',
    'si': 'රැකබලා ගන්නාට කතා කරන්න',
    'ta': 'பராமரிப்பாளரை அழை',
  },
  'voice.cmdProgress': {
    'en': 'Open progress',
    'si': 'ප්‍රගතිය විවෘත කරන්න',
    'ta': 'முன்னேற்றத்தைத் திற',
  },
  'voice.cmdHelp': {
    'en': 'Emergency help',
    'si': 'හදිසි උදව්',
    'ta': 'அவசர உதவி',
  },

  'chat.online': {'en': 'Online', 'si': 'සබැඳි', 'ta': 'இணைப்பில்'},
  'chat.type': {
    'en': 'Type a message',
    'si': 'පණිවිඩයක් ලියන්න',
    'ta': 'செய்தியை எழுதுங்கள்',
  },
  'chat.send': {
    'en': 'Send message',
    'si': 'පණිවිඩය යවන්න',
    'ta': 'செய்தி அனுப்பு',
  },
  'chat.m1': {
    'en': 'Good morning! How are your shoulder exercises going today?',
    'si': 'සුබ උදෑසනක්! අද උරහිස් ව්‍යායාම කෙසේද?',
    'ta': 'காலை வணக்கம்! இன்று தோள் பயிற்சிகள் எப்படி உள்ளன?',
  },
  'chat.m2': {
    'en': "I completed today's session successfully.",
    'si': 'මම අද සැසිය සාර්ථකව අවසන් කළා.',
    'ta': 'இன்றைய அமர்வை வெற்றிகரமாக முடித்தேன்.',
  },
  'chat.m3': {
    'en': 'Excellent progress. Continue the mobility exercises daily.',
    'si': 'විශිෂ්ට ප්‍රගතියක්. චලන ව්‍යායාම දිනපතා කරන්න.',
    'ta': 'சிறந்த முன்னேற்றம். அசைவுப் பயிற்சிகளைத் தினமும் தொடருங்கள்.',
  },

  // -- exercise details / video ---------------------------------------------
  'det.instructions': {
    'en': 'Instructions',
    'si': 'උපදෙස්',
    'ta': 'வழிமுறைகள்',
  },
  'det.benefits': {'en': 'Benefits', 'si': 'ප්‍රතිලාභ', 'ta': 'நன்மைகள்'},
  'det.safety': {'en': 'Safety', 'si': 'ආරක්ෂාව', 'ta': 'பாதுகாப்பு'},
  'det.safetyBody': {
    'en':
        'Stop if you feel pain or dizziness, and tell your physiotherapist. Discomfort is not a sign of progress.',
    'si':
        'වේදනාවක් හෝ කරකැවිල්ලක් දැනුණොත් නවත්වා චිකිත්සකයාට කියන්න. අපහසුතාව ප්‍රගතියක් නොවේ.',
    'ta':
        'வலி அல்லது தலைச்சுற்றல் இருந்தால் நிறுத்தி மருத்துவரிடம் சொல்லுங்கள். அசௌகரியம் முன்னேற்றத்தின் அறிகுறி அல்ல.',
  },
  'det.startTracked': {
    'en': 'Start tracked session',
    'si': 'නිරීක්ෂිත සැසිය අරඹන්න',
    'ta': 'கண்காணிப்பு அமர்வைத் தொடங்கு',
  },
  'det.watchDemo': {
    'en': 'Watch demonstration',
    'si': 'නිරූපණය බලන්න',
    'ta': 'விளக்கத்தைப் பார்',
  },
  'det.duration': {'en': 'Duration', 'si': 'කාලය', 'ta': 'கால அளவு'},
  'det.beginner': {'en': 'Beginner', 'si': 'ආරම්භක', 'ta': 'தொடக்கநிலை'},
  'det.demoVideo': {
    'en': 'Demonstration video',
    'si': 'නිරූපණ වීඩියෝව',
    'ta': 'விளக்க வீடியோ',
  },
  'det.playerNotConnected': {
    'en': 'Player not connected yet',
    'si': 'ධාවකය තවම සම්බන්ධ නැත',
    'ta': 'இயக்கி இன்னும் இணைக்கப்படவில்லை',
  },

  // Days and relative dates. The demo content below carries fixed weekday
  // labels; these let those labels follow the selected language.
  'day.today': {'en': 'Today', 'si': 'අද', 'ta': 'இன்று'},
  'day.yesterday': {'en': 'Yesterday', 'si': 'ඊයේ', 'ta': 'நேற்று'},
  'day.tomorrow': {'en': 'Tomorrow', 'si': 'හෙට', 'ta': 'நாளை'},
  'day.monday': {'en': 'Monday', 'si': 'සඳුදා', 'ta': 'திங்கள்'},
  'day.tuesday': {'en': 'Tuesday', 'si': 'අඟහරුවාදා', 'ta': 'செவ்வாய்'},
  'day.wednesday': {'en': 'Wednesday', 'si': 'බදාදා', 'ta': 'புதன்'},
  'day.thursday': {'en': 'Thursday', 'si': 'බ්‍රහස්පතින්දා', 'ta': 'வியாழன்'},

  // Exercise-detail demo content.
  'det.shoulderMobility': {
    'en': 'Shoulder Mobility',
    'si': 'උරහිස් චලනය',
    'ta': 'தோள்பட்டை இயக்கம்',
  },
  'det.sessionSubtitle': {
    'en': 'Rehabilitation training session',
    'si': 'පුනරුත්ථාපන පුහුණු සැසිය',
    'ta': 'மறுவாழ்வு பயிற்சி அமர்வு',
  },
  'step.sit': {
    'en': 'Sit comfortably on a chair',
    'si': 'පුටුවක සුවපහසුව හිඳගන්න',
    'ta': 'நாற்காலியில் வசதியாக அமரவும்',
  },
  'step.backStraight': {
    'en': 'Keep your back straight',
    'si': 'කොඳු ඇට පෙළ කෙළින් තබාගන්න',
    'ta': 'முதுகை நேராக வைத்திருங்கள்',
  },
  'step.raiseArm': {
    'en': 'Slowly raise your arm',
    'si': 'අත සෙමින් ඔසවන්න',
    'ta': 'கையை மெதுவாக உயர்த்துங்கள்',
  },
  'step.hold3': {
    'en': 'Hold for 3 seconds',
    'si': 'තත්පර 3ක් රඳවා ගන්න',
    'ta': '3 வினாடிகள் வைத்திருங்கள்',
  },
  'step.lower': {
    'en': 'Lower your arm gently',
    'si': 'අත සෙමින් පහත් කරන්න',
    'ta': 'கையை மெதுவாக இறக்குங்கள்',
  },
  'step.repeat10': {
    'en': 'Repeat 10 times',
    'si': 'වාර 10ක් නැවත කරන්න',
    'ta': '10 முறை மீண்டும் செய்யவும்',
  },
  'step.stopIfPain': {
    'en': 'Stop if you feel discomfort',
    'si': 'අපහසුවක් දැනුණොත් නවත්වන්න',
    'ta': 'அசௌகரியம் இருந்தால் நிறுத்துங்கள்',
  },
  'benefit.mobility': {
    'en': 'Improves shoulder mobility',
    'si': 'උරහිස් චලනය වැඩි දියුණු කරයි',
    'ta': 'தோள்பட்டை இயக்கத்தை மேம்படுத்தும்',
  },
  'benefit.strength': {
    'en': 'Increases arm strength',
    'si': 'අතේ ශක්තිය වැඩි කරයි',
    'ta': 'கை வலிமையை அதிகரிக்கும்',
  },
  'benefit.coordination': {
    'en': 'Enhances coordination',
    'si': 'සම්බන්ධීකරණය වැඩි දියුණු කරයි',
    'ta': 'ஒருங்கிணைப்பை மேம்படுத்தும்',
  },
  'benefit.recovery': {
    'en': 'Supports stroke recovery',
    'si': 'ආඝාත සුවවීමට උදව් වේ',
    'ta': 'பக்கவாத மீட்புக்கு உதவும்',
  },

  // Schedule / history demo content.
  'sched.upperLimb': {
    'en': 'Upper Limb Therapy',
    'si': 'උඩු අත්පා ප්‍රතිකාරය',
    'ta': 'மேல் மூட்டு சிகிச்சை',
  },
  'sched.balance': {
    'en': 'Balance Rehabilitation',
    'si': 'තුලනය පුනරුත්ථාපනය',
    'ta': 'சமநிலை மறுவாழ்வு',
  },
  'sched.mobility': {
    'en': 'Mobility Exercise Session',
    'si': 'චලන ව්‍යායාම සැසිය',
    'ta': 'இயக்க பயிற்சி அமர்வு',
  },
  'sched.physioLabel': {
    'en': 'Physiotherapist',
    'si': 'භෞත චිකිත්සක',
    'ta': 'இயன்முறை மருத்துவர்',
  },
  'sched.guided': {
    'en': 'Guided recovery training',
    'si': 'මඟපෙන්වන ලද සුවවීමේ පුහුණුව',
    'ta': 'வழிகாட்டப்பட்ட மீட்புப் பயிற்சி',
  },
  'hist.armCoord': {
    'en': 'Arm Coordination Exercise',
    'si': 'අත් සම්බන්ධීකරණ ව්‍යායාමය',
    'ta': 'கை ஒருங்கிணைப்பு பயிற்சி',
  },
  'hist.sampleNote': {
    'en': 'Sample data — history is not synced yet',
    'si': 'නියැදි දත්ත — ඉතිහාසය තවම සමමුහුර්ත නොවේ',
    'ta': 'மாதிரி தரவு — வரலாறு இன்னும் ஒத்திசைக்கப்படவில்லை',
  },
  'hist.form': {'en': 'Form', 'si': 'ඉරියව්ව', 'ta': 'நிலை'},

  // Navigation additions: every screen needs a way in and a way back.
  'roles.changeLanguage': {
    'en': 'Change language',
    'si': 'භාෂාව වෙනස් කරන්න',
    'ta': 'மொழியை மாற்று',
  },
  'explore.openAll': {
    'en': 'Explore all features',
    'si': 'සියලු විශේෂාංග ගවේෂණය කරන්න',
    'ta': 'அனைத்து அம்சங்களையும் ஆராயுங்கள்',
  },
  'explore.guide': {
    'en': 'Exercise guide',
    'si': 'ව්‍යායාම මාර්ගෝපදේශය',
    'ta': 'பயிற்சி வழிகாட்டி',
  },
  'explore.guideSub': {
    'en': 'Written instructions, safety notes and a demonstration',
    'si': 'ලිඛිත උපදෙස්, ආරක්ෂක සටහන් සහ ප්‍රදර්ශනයක්',
    'ta': 'எழுத்து வழிமுறைகள், பாதுகாப்புக் குறிப்புகள் மற்றும் ஒரு விளக்கம்',
  },

  // Sign in / sign out.
  'auth.whoAreYou': {
    'en': 'Who is exercising?',
    'si': 'ව්‍යායාම කරන්නේ කවුද?',
    'ta': 'யார் பயிற்சி செய்கிறார்?',
  },
  'auth.tapYourName': {
    'en': 'Tap your name to continue',
    'si': 'ඉදිරියට යාමට ඔබේ නම ස්පර්ශ කරන්න',
    'ta': 'தொடர உங்கள் பெயரைத் தொடுங்கள்',
  },
  'auth.enterPin': {
    'en': 'Enter your PIN',
    'si': 'ඔබේ PIN ඇතුළු කරන්න',
    'ta': 'உங்கள் PIN ஐ உள்ளிடுங்கள்',
  },
  'auth.pinHint': {
    'en': 'Four digits',
    'si': 'ඉලක්කම් හතරක්',
    'ta': 'நான்கு இலக்கங்கள்',
  },
  'auth.staffTitle': {
    'en': 'Staff sign in',
    'si': 'කාර්ය මණ්ඩල පිවිසුම',
    'ta': 'ஊழியர் உள்நுழைவு',
  },
  'auth.email': {'en': 'Email', 'si': 'ඊමේල්', 'ta': 'மின்னஞ்சல்'},
  'auth.password': {'en': 'Password', 'si': 'මුරපදය', 'ta': 'கடவுச்சொல்'},
  'auth.signIn': {'en': 'Sign in', 'si': 'පිවිසෙන්න', 'ta': 'உள்நுழை'},
  'auth.signingIn': {
    'en': 'Signing in…',
    'si': 'පිවිසෙමින්…',
    'ta': 'உள்நுழைகிறது…',
  },
  'auth.wrongPin': {
    'en': 'That PIN is not right. Try again.',
    'si': 'එම PIN නිවැරදි නොවේ. නැවත උත්සාහ කරන්න.',
    'ta': 'அந்த PIN சரியல்ல. மீண்டும் முயற்சிக்கவும்.',
  },
  'auth.wrongPassword': {
    'en': 'Email or password is not right.',
    'si': 'ඊමේල් හෝ මුරපදය නිවැරදි නොවේ.',
    'ta': 'மின்னஞ்சல் அல்லது கடவுச்சொல் சரியல்ல.',
  },
  'auth.lockedOut': {
    'en': 'Too many attempts. Please wait a moment.',
    'si': 'උත්සාහ ගණන වැඩියි. මොහොතක් රැඳී සිටින්න.',
    'ta': 'அதிக முயற்சிகள். சற்று காத்திருங்கள்.',
  },
  'auth.lockedSeconds': {
    'en': 'seconds left',
    'si': 'තත්පර ඉතිරිව ඇත',
    'ta': 'வினாடிகள் உள்ளன',
  },
  'auth.unreachable': {
    'en': 'Cannot reach the service. Check your connection.',
    'si': 'සේවාවට සම්බන්ධ විය නොහැක. ඔබේ සම්බන්ධතාවය පරීක්ෂා කරන්න.',
    'ta': 'சேவையை அணுக முடியவில்லை. இணைப்பைச் சரிபார்க்கவும்.',
  },
  'auth.unexpected': {
    'en': 'Something went wrong. Try again.',
    'si': 'යම් දෝෂයක් සිදු විය. නැවත උත්සාහ කරන්න.',
    'ta': 'ஏதோ தவறாகிவிட்டது. மீண்டும் முயற்சிக்கவும்.',
  },
  'auth.noPatients': {
    'en': 'No accounts found on the service.',
    'si': 'සේවාවේ ගිණුම් හමු නොවීය.',
    'ta': 'சேவையில் கணக்குகள் இல்லை.',
  },
  'auth.delete': {'en': 'Delete', 'si': 'මකන්න', 'ta': 'நீக்கு'},
  'auth.logout': {'en': 'Log out', 'si': 'පිටවෙන්න', 'ta': 'வெளியேறு'},
  'auth.logoutSub': {
    'en': 'You will need your PIN to return',
    'si': 'නැවත පැමිණීමට ඔබේ PIN අවශ්‍ය වේ',
    'ta': 'திரும்ப வர உங்கள் PIN தேவைப்படும்',
  },
  'auth.logoutStaffSub': {
    'en': 'You will need your password to return',
    'si': 'නැවත පැමිණීමට ඔබේ මුරපදය අවශ්‍ය වේ',
    'ta': 'திரும்ப வர உங்கள் கடவுச்சொல் தேவைப்படும்',
  },
  'auth.logoutConfirm': {
    'en': 'Log out of NeuroPulse?',
    'si': 'NeuroPulse වෙතින් පිටවෙන්නද?',
    'ta': 'NeuroPulse இலிருந்து வெளியேறவா?',
  },
  'auth.logoutCancel': {
    'en': 'Stay signed in',
    'si': 'පිවිසී සිටින්න',
    'ta': 'உள்நுழைந்தே இரு',
  },
  'auth.signedInAs': {
    'en': 'Signed in as',
    'si': 'පිවිසී ඇත්තේ',
    'ta': 'உள்நுழைந்தவர்',
  },
  'profile.account': {'en': 'Account', 'si': 'ගිණුම', 'ta': 'கணக்கு'},

  // Username-based patient sign-in.
  'auth.patientTitle': {
    'en': 'Patient sign in',
    'si': 'රෝගී පිවිසුම',
    'ta': 'நோயாளி உள்நுழைவு',
  },
  'auth.patientSubtitle': {
    'en': 'Enter your username to begin',
    'si': 'ආරම්භ කිරීමට ඔබේ පරිශීලක නාමය ඇතුළු කරන්න',
    'ta': 'தொடங்க உங்கள் பயனர்பெயரை உள்ளிடுங்கள்',
  },
  'auth.username': {'en': 'Username', 'si': 'පරිශීලක නාමය', 'ta': 'பயனர்பெயர்'},
  'auth.usernameHint': {
    'en': 'The name your care team gave you',
    'si': 'ඔබේ සත්කාර කණ්ඩායම ලබා දුන් නාමය',
    'ta': 'உங்கள் பராமரிப்புக் குழு வழங்கிய பெயர்',
  },
  'auth.usernameEmpty': {
    'en': 'Please enter your username.',
    'si': 'ඔබේ පරිශීලක නාමය ඇතුළු කරන්න.',
    'ta': 'உங்கள் பயனர்பெயரை உள்ளிடுங்கள்.',
  },
  'auth.continue': {'en': 'Continue', 'si': 'ඉදිරියට', 'ta': 'தொடரவும்'},
  'auth.wrongLogin': {
    'en': 'Username or PIN is not right.',
    'si': 'පරිශීලක නාමය හෝ PIN නිවැරදි නොවේ.',
    'ta': 'பயனர்பெயர் அல்லது PIN சரியல்ல.',
  },
  'auth.staffSubtitle': {
    'en': 'For caregivers and therapists',
    'si': 'රැකබලා ගන්නන් සහ චිකිත්සකයින් සඳහා',
    'ta': 'பராமரிப்பாளர்கள் மற்றும் சிகிச்சையாளர்களுக்கு',
  },
  'auth.needHelp': {
    'en': 'Ask your care team if you have forgotten it.',
    'si': 'අමතක වී නම් ඔබේ සත්කාර කණ්ඩායමෙන් විමසන්න.',
    'ta': 'மறந்துவிட்டால் உங்கள் பராமரிப்புக் குழுவைக் கேளுங்கள்.',
  },

  // Registration.
  'auth.createAccount': {
    'en': 'Create account',
    'si': 'ගිණුමක් සාදන්න',
    'ta': 'கணக்கை உருவாக்கு',
  },
  'auth.creatingAccount': {
    'en': 'Creating account…',
    'si': 'ගිණුම සාදමින්…',
    'ta': 'கணக்கு உருவாக்கப்படுகிறது…',
  },
  'auth.newPatient': {
    'en': 'New patient? Create an account',
    'si': 'නව රෝගියෙක්ද? ගිණුමක් සාදන්න',
    'ta': 'புதிய நோயாளியா? கணக்கை உருவாக்குங்கள்',
  },
  'auth.newStaff': {
    'en': 'New here? Create an account',
    'si': 'අලුත්ද? ගිණුමක් සාදන්න',
    'ta': 'புதியவரா? கணக்கை உருவாக்குங்கள்',
  },
  'auth.registerPatientTitle': {
    'en': 'Create your account',
    'si': 'ඔබේ ගිණුම සාදන්න',
    'ta': 'உங்கள் கணக்கை உருவாக்குங்கள்',
  },
  'auth.registerPatientSubtitle': {
    'en': 'A username and a 4-digit PIN is all you need',
    'si': 'අවශ්‍ය වන්නේ පරිශීලක නාමයක් සහ ඉලක්කම් 4ක PIN එකක් පමණි',
    'ta': 'ஒரு பயனர்பெயரும் 4 இலக்க PIN உம் மட்டுமே தேவை',
  },
  'auth.registerStaffTitle': {
    'en': 'Create staff account',
    'si': 'කාර්ය මණ්ඩල ගිණුමක් සාදන්න',
    'ta': 'ஊழியர் கணக்கை உருவாக்கு',
  },
  'auth.fullName': {
    'en': 'Full name',
    'si': 'සම්පූර්ණ නම',
    'ta': 'முழுப் பெயர்',
  },
  'auth.fullNameEmpty': {
    'en': 'Please enter your name.',
    'si': 'ඔබේ නම ඇතුළු කරන්න.',
    'ta': 'உங்கள் பெயரை உள்ளிடுங்கள்.',
  },
  'auth.chooseUsernameHint': {
    'en': 'Letters, numbers, dots or dashes — 3 to 20 characters',
    'si': 'අකුරු, ඉලක්කම්, තිත් හෝ ඉරි — අක්ෂර 3 සිට 20 දක්වා',
    'ta': 'எழுத்துகள், எண்கள், புள்ளிகள் அல்லது கோடுகள் — 3 முதல் 20 எழுத்துகள்',
  },
  'auth.usernameInvalid': {
    'en': 'Usernames are 3–20 letters, numbers, dots or dashes.',
    'si': 'පරිශීලක නාම යනු අකුරු, ඉලක්කම්, තිත් හෝ ඉරි 3–20 කි.',
    'ta': 'பயனர்பெயர் 3–20 எழுத்துகள், எண்கள், புள்ளிகள் அல்லது கோடுகள்.',
  },
  'auth.usernameTaken': {
    'en': 'That username is already taken. Try another.',
    'si': 'එම පරිශීලක නාමය දැනටමත් භාවිතයේ ඇත. වෙනත් එකක් උත්සාහ කරන්න.',
    'ta': 'அந்த பயனர்பெயர் ஏற்கனவே உள்ளது. வேறொன்றை முயற்சிக்கவும்.',
  },
  'auth.choosePin': {
    'en': 'Choose a PIN',
    'si': 'PIN එකක් තෝරන්න',
    'ta': 'PIN ஐத் தேர்ந்தெடுங்கள்',
  },
  'auth.choosePinSubtitle': {
    'en': 'Pick four digits you will remember',
    'si': 'ඔබට මතක තබාගත හැකි ඉලක්කම් හතරක් තෝරන්න',
    'ta': 'நினைவில் வைக்கக்கூடிய நான்கு இலக்கங்களைத் தேர்ந்தெடுங்கள்',
  },
  'auth.confirmPin': {
    'en': 'Enter the PIN again',
    'si': 'PIN නැවත ඇතුළු කරන්න',
    'ta': 'PIN ஐ மீண்டும் உள்ளிடுங்கள்',
  },
  'auth.pinMismatch': {
    'en': 'The PINs did not match. Start again.',
    'si': 'PIN දෙක නොගැලපේ. නැවත ආරම්භ කරන්න.',
    'ta': 'PIN கள் பொருந்தவில்லை. மீண்டும் தொடங்கவும்.',
  },
  'auth.emailInvalid': {
    'en': 'Enter a valid email address.',
    'si': 'වලංගු ඊමේල් ලිපිනයක් ඇතුළු කරන්න.',
    'ta': 'சரியான மின்னஞ்சல் முகவரியை உள்ளிடுங்கள்.',
  },
  'auth.emailTaken': {
    'en': 'An account with this email already exists.',
    'si': 'මෙම ඊමේල් ලිපිනය සමඟ ගිණුමක් දැනටමත් ඇත.',
    'ta': 'இந்த மின்னஞ்சலுடன் ஏற்கனவே ஒரு கணக்கு உள்ளது.',
  },
  'auth.passwordHint': {
    'en': 'At least 8 characters',
    'si': 'අවම වශයෙන් අක්ෂර 8ක්',
    'ta': 'குறைந்தது 8 எழுத்துகள்',
  },
  'auth.passwordShort': {
    'en': 'Password needs at least 8 characters.',
    'si': 'මුරපදයට අවම වශයෙන් අක්ෂර 8ක් අවශ්‍යයි.',
    'ta': 'கடவுச்சொல்லுக்கு குறைந்தது 8 எழுத்துகள் தேவை.',
  },
  'auth.confirmPassword': {
    'en': 'Confirm password',
    'si': 'මුරපදය තහවුරු කරන්න',
    'ta': 'கடவுச்சொல்லை உறுதிப்படுத்து',
  },
  'auth.passwordMismatch': {
    'en': 'The passwords do not match.',
    'si': 'මුරපද නොගැලපේ.',
    'ta': 'கடவுச்சொற்கள் பொருந்தவில்லை.',
  },
};

/// Look up a UI string in the patient's current language.
///
/// Falls back to English, then to the key itself. A missing translation should
/// show readable English rather than a blank or a crash.
String t(String key) {
  final entry = _strings[key];
  if (entry == null) {
    assert(false, 'missing translation key: $key');
    return key;
  }
  return entry[languageStore.code] ?? entry['en'] ?? key;
}

/// Convenience for the many `<n> <noun>` labels, e.g. "12 වාර".
String tCount(int n, String key) => '$n ${t(key)}';

/// Rebuilds one route's subtree when the selected language changes.
///
/// Every route needs this because [t] is a plain global function with no
/// BuildContext, so nothing registers an inherited dependency on the language the
/// way a widget reading Theme or Localizations would. Rebuilding MaterialApp is
/// not enough on its own either: a Navigator does not re-invoke a route's builder
/// just because an ancestor rebuilt, so pages already on the stack kept whatever
/// language they were first built in — change the language from the roles screen
/// and the picker switched while the screen behind it stayed English.
///
/// The key is what makes it work. Route bodies are `const`, so the same canonical
/// widget instance is handed back on every rebuild and Flutter skips the subtree.
/// Changing the key forces a fresh element instead. That does discard State,
/// which is the right call here: a screen holding text fetched in the old
/// language should reload rather than keep it.
class Localized extends StatelessWidget {
  const Localized(this.child, {super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: languageStore,
      builder: (context, _) =>
          KeyedSubtree(key: ValueKey(languageStore.code), child: child),
    );
  }
}
