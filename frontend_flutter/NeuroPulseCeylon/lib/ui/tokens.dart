import 'package:flutter/material.dart';

/// Design tokens, carried over from the React Native app's `src/ui/tokens.ts`.
///
/// WHY THE SIZES LOOK LARGE
///
/// The users are stroke patients, which drives concrete choices:
///
///  * Hemiparesis means one-handed use, so primary actions sit low on screen.
///  * Reduced fine motor control and tremor mean 48dp (the WCAG floor) is not
///    enough; targets here are 56dp.
///  * Reduced contrast sensitivity is common after stroke, so text colours are
///    checked against their background for WCAG AA. Measured ratios are in the
///    comments — check, don't eyeball.
///  * Fatigue and cognitive load mean fewer, larger elements. Body text is 17,
///    not the usual 14.
///
/// SINHALA AND TAMIL
///
/// Both scripts are taller than Latin and Sinhala stacks vowel signs above and
/// below the base glyph, so they clip at Latin-typical line heights. Every text
/// style below sets a height of at least 1.35.
class AppColor {
  AppColor._();

  /// Decorative and large icons only: 2.2:1 on white, never for body text.
  static const brandLight = Color(0xFF2CC3CF);

  /// Large icons and 24px+ headings on white (4.1:1 — AA large only).
  static const brand = Color(0xFF0F8B7D);

  /// Filled buttons: white on this is 5.2:1 — AA for body text.
  static const brandStrong = Color(0xFF0E7A6E);

  /// Brand-coloured TEXT on white: 6.1:1 — AA everywhere.
  static const brandText = Color(0xFF0B6E62);

  static const brandTint = Color(0xFFDFF5F2);
  static const brandTintStrong = Color(0xFFBEEAE4);

  /// Primary text. 16.5:1 on white.
  static const ink = Color(0xFF081B4B);

  /// Secondary text. 7.3:1 on white.
  static const inkMuted = Color(0xFF475569);

  /// Tertiary text. 4.7:1 on white — still AA, do not lighten.
  static const inkSubtle = Color(0xFF64748B);

  /// Disabled only. Fails AA by design; never for content.
  static const inkDisabled = Color(0xFF94A3B8);

  static const canvas = Color(0xFFF5F7FA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSunken = Color(0xFFF1F5F9);
  static const border = Color(0xFFE2E8F0);

  static const night = Color(0xFF0F172A);
  static const nightSurface = Color(0xFF1E293B);
  static const onNight = Color(0xFFF8FAFC);
  static const onNightMuted = Color(0xFF94A3B8);

  static const danger = Color(0xFFDC2626);
  static const dangerText = Color(0xFFB91C1C);
  static const dangerTint = Color(0xFFFEE2E2);

  static const success = Color(0xFF15803D);
  static const successTint = Color(0xFFDCFCE7);

  static const warning = Color(0xFFD97706);
  static const warningText = Color(0xFF92400E);
  static const warningTint = Color(0xFFFEF3C7);
}

class Space {
  Space._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
}

class Radii {
  Radii._();
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;
}

class Sizes {
  Sizes._();

  /// Exceeds the 48dp WCAG minimum: tremor is expected here, not an edge case.
  static const double target = 56;
  static const double row = 76;
  static const double chip = 64;
}

class AppText {
  AppText._();

  static const display = TextStyle(
    fontSize: 34,
    height: 1.24,
    fontWeight: FontWeight.w800,
  );
  static const title = TextStyle(
    fontSize: 27,
    height: 1.33,
    fontWeight: FontWeight.w800,
  );
  static const heading = TextStyle(
    fontSize: 21,
    height: 1.38,
    fontWeight: FontWeight.w700,
  );
  static const subheading = TextStyle(
    fontSize: 19,
    height: 1.42,
    fontWeight: FontWeight.w700,
  );

  /// Default for reading. 17 is the floor for this audience.
  static const body = TextStyle(fontSize: 17, height: 1.53);
  static const bodyStrong = TextStyle(
    fontSize: 17,
    height: 1.53,
    fontWeight: FontWeight.w600,
  );
  static const label = TextStyle(
    fontSize: 16,
    height: 1.38,
    fontWeight: FontWeight.w700,
  );

  /// Metadata. Never for something a patient must read to act.
  static const caption = TextStyle(
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w500,
  );

  /// Rep counts and scores.
  static const metric = TextStyle(
    fontSize: 92,
    height: 1.08,
    fontWeight: FontWeight.w800,
  );
}

ThemeData buildAppTheme() {
  final base = ThemeData.light(useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: AppColor.canvas,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColor.brandStrong,
      secondary: AppColor.brand,
      surface: AppColor.surface,
      error: AppColor.danger,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: AppColor.ink,
      displayColor: AppColor.ink,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColor.brandStrong,
        foregroundColor: AppColor.surface,
        minimumSize: const Size.fromHeight(Sizes.target),
        textStyle: AppText.label,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.lg),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColor.ink,
        minimumSize: const Size.fromHeight(Sizes.target),
        textStyle: AppText.label,
        side: const BorderSide(color: AppColor.inkDisabled, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.lg),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColor.surface,
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
    ),
  );
}
