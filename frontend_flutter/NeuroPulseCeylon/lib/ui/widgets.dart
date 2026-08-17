/// Shared widgets. Screens compose these rather than styling from scratch, so
/// spacing, target sizes and contrast stay consistent — see tokens.dart for why
/// the sizes are what they are.
library;

import 'package:flutter/material.dart';

import '../features/auth.dart';
import '../features/i18n.dart';
import '../routes.dart';
import 'tokens.dart';

/// Page shell: canvas background, safe area, consistent padding, and an optional
/// footer pinned outside the scroll area.
///
/// The footer is where primary actions belong. Hemiparesis means one-handed use,
/// so the main action has to sit in thumb reach rather than a top corner.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.children,
    this.footer,
    this.night = false,
    this.scroll = true,
    this.bottomNav,
  });

  final List<Widget> children;
  final Widget? footer;
  final bool night;
  final bool scroll;
  final Widget? bottomNav;

  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.lg),
      child: scroll
          ? ListView(
              padding: const EdgeInsets.only(top: Space.sm, bottom: Space.xxl),
              children: children,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
    );

    return Scaffold(
      backgroundColor: night ? AppColor.night : AppColor.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: body),
            if (footer != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    Space.lg, Space.base, Space.lg, Space.sm),
                child: footer,
              ),
            ?bottomNav,
          ],
        ),
      ),
    );
  }
}

/// The back control on its own, for screens with no title block to hang it off.
/// A full 56dp target with a visible surface — a bare chevron is both hard to hit
/// and hard to see.
class BackTarget extends StatelessWidget {
  const BackTarget({super.key, this.night = false, this.onBrand = false});

  /// Dark surface, for the near-black session screen.
  final bool night;

  /// Translucent white, for the brand gradient. The dark [night] surface reads as
  /// a heavy blob against teal, so the two cases are not interchangeable.
  final bool onBrand;

  @override
  Widget build(BuildContext context) {
    final light = night || onBrand;

    return SizedBox(
      width: Sizes.target,
      height: Sizes.target,
      child: IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: Icon(Icons.chevron_left,
            color: light ? AppColor.onNight : AppColor.ink),
        iconSize: 30,
        tooltip: t('common.back'),
        style: IconButton.styleFrom(
          backgroundColor: onBrand
              ? Colors.white24
              : (night ? AppColor.nightSurface : AppColor.surface),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.md),
          ),
        ),
      ),
    );
  }
}

/// Screen title block. `back` renders the same control alongside the title.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.back = false,
    this.trailing,
    this.night = false,
  });

  final String title;
  final String? subtitle;
  final bool back;
  final Widget? trailing;
  final bool night;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Space.md, bottom: Space.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (back) ...[
            BackTarget(night: night),
            const SizedBox(width: Space.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppText.title.copyWith(
                    color: night ? AppColor.onNight : AppColor.ink,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: Space.xs),
                  Text(
                    subtitle!,
                    style: AppText.body.copyWith(
                      color:
                          night ? AppColor.onNightMuted : AppColor.inkMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Label above a group of rows.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.meta});

  final String title;
  final String? meta;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Space.lg, bottom: Space.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: Text(title, style: AppText.heading)),
          if (meta != null)
            Text(meta!,
                style: AppText.caption.copyWith(color: AppColor.inkSubtle)),
        ],
      ),
    );
  }
}

/// Surface panel. `accent` draws a left bar for status emphasis.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.accent,
    this.onTap,
    this.sunken = false,
  });

  final Widget child;
  final Color? accent;
  final VoidCallback? onTap;
  final bool sunken;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      decoration: BoxDecoration(
        color: sunken ? AppColor.surfaceSunken : AppColor.surface,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: accent == null
            ? null
            : Border(left: BorderSide(color: accent!, width: 5)),
        boxShadow: sunken
            ? null
            : const [
                BoxShadow(
                  color: Color(0x14081B4B),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
      ),
      padding: const EdgeInsets.all(Space.base),
      child: child,
    );

    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.lg),
      child: content,
    );
  }
}

/// The workhorse row. Minimum height is 76dp — taller than the 56dp target —
/// because these are the main navigation surface and are often used one-handed.
class AppListRow extends StatelessWidget {
  const AppListRow({
    super.key,
    required this.title,
    this.meta,
    this.subtitle,
    this.icon,
    this.iconBackground,
    this.iconColor,
    this.onTap,
    this.trailing,
    this.child,
    this.highlight = false,
    this.showChevron = true,
  });

  final String title;
  final String? meta;
  final String? subtitle;
  final IconData? icon;
  final Color? iconBackground;
  final Color? iconColor;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Widget? child;
  final bool highlight;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final row = Container(
      constraints: const BoxConstraints(minHeight: Sizes.row),
      decoration: BoxDecoration(
        color: highlight ? AppColor.brandTint : AppColor.surface,
        borderRadius: BorderRadius.circular(Radii.lg),
        boxShadow: const [
          BoxShadow(
              color: Color(0x14081B4B), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.all(Space.base),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: Sizes.chip,
              height: Sizes.chip,
              decoration: BoxDecoration(
                color: iconBackground ?? AppColor.brandTint,
                borderRadius: BorderRadius.circular(Radii.md),
              ),
              child: Icon(icon,
                  size: 28, color: iconColor ?? AppColor.brandText),
            ),
            const SizedBox(width: Space.base),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.subheading),
                if (meta != null) ...[
                  const SizedBox(height: 2),
                  Text(meta!,
                      style: AppText.bodyStrong
                          .copyWith(color: AppColor.brandText)),
                ],
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(subtitle!,
                      style:
                          AppText.caption.copyWith(color: AppColor.inkMuted)),
                ],
                if (child != null) ...[
                  const SizedBox(height: Space.sm),
                  child!,
                ],
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          else if (showChevron && onTap != null)
            const Icon(Icons.chevron_right, color: AppColor.inkDisabled),
        ],
      ),
    );

    if (onTap == null) return row;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.lg),
      child: row,
    );
  }
}

enum BadgeTone { neutral, brand, success, warning, danger, info }

/// Status pill. Tones pair a tinted background with a darkened foreground so the
/// label stays legible, and an icon can carry the meaning too — colour alone is
/// unreliable for users with impaired contrast sensitivity.
class AppBadge extends StatelessWidget {
  const AppBadge(this.label, {super.key, this.tone = BadgeTone.neutral, this.icon});

  final String label;
  final BadgeTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      BadgeTone.neutral => (AppColor.surfaceSunken, AppColor.inkMuted),
      BadgeTone.brand => (AppColor.brandTint, AppColor.brandText),
      BadgeTone.success => (AppColor.successTint, AppColor.success),
      BadgeTone.warning => (AppColor.warningTint, AppColor.warningText),
      BadgeTone.danger => (AppColor.dangerTint, AppColor.dangerText),
      BadgeTone.info => (const Color(0xFFDBEAFE), const Color(0xFF1E40AF)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: Space.xs),
          ],
          Flexible(
            child: Text(label, style: AppText.caption.copyWith(color: fg)),
          ),
        ],
      ),
    );
  }
}

/// Big number plus label, for dashboards.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.value,
    required this.label,
    this.tone = BadgeTone.brand,
    this.icon,
  });

  final String value;
  final String label;
  final BadgeTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      BadgeTone.success => (AppColor.successTint, AppColor.success),
      BadgeTone.warning => (AppColor.warningTint, AppColor.warningText),
      BadgeTone.danger => (AppColor.dangerTint, AppColor.dangerText),
      _ => (AppColor.brandTint, AppColor.brandText),
    };

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(Space.base),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(Radii.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) Icon(icon, size: 22, color: fg),
            Text(value, style: AppText.title.copyWith(color: fg)),
            Text(label,
                style: AppText.caption.copyWith(color: fg), maxLines: 2),
          ],
        ),
      ),
    );
  }
}

/// Bulleted list with the marker in its own column, so wrapped lines stay
/// aligned — which matters more in Sinhala and Tamil, where the same sentence
/// runs longer and wraps more often.
class Bullets extends StatelessWidget {
  const Bullets(this.items, {super.key, this.icon, this.tone = BadgeTone.brand});

  final List<String> items;
  final IconData? icon;
  final BadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      BadgeTone.success => AppColor.success,
      BadgeTone.neutral => AppColor.inkSubtle,
      _ => AppColor.brandText,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: Space.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Icon(icon ?? Icons.circle,
                        size: icon == null ? 8 : 18, color: color),
                  ),
                  const SizedBox(width: Space.md),
                  Expanded(
                    child: Text(item,
                        style:
                            AppText.body.copyWith(color: AppColor.inkMuted)),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

/// Branded header used by the onboarding screens.
///
/// Text sits toward the darker end of the gradient: white on the light cyan is
/// only about 2.2:1, which fails AA badly.
///
/// Named BrandHero rather than Hero because Flutter already has a Hero widget for
/// route transitions, and shadowing it would break that.
class BrandHero extends StatelessWidget {
  const BrandHero({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.compact = false,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: compact ? Space.lg : Space.xxl,
        horizontal: Space.lg,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.brandLight, AppColor.brand],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(Radii.xl),
          bottomRight: Radius.circular(Radii.xl),
        ),
      ),
      child: Column(
        children: [
          if (icon != null) ...[
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(Radii.xl),
              ),
              child: Icon(icon, size: compact ? 40 : 50, color: Colors.white),
            ),
            const SizedBox(height: Space.base),
          ],
          Text(
            title,
            style: (compact ? AppText.title : AppText.display)
                .copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: Space.sm),
            Text(
              subtitle!,
              style: AppText.body.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Label/value pair for read-only detail screens.
class FieldRow extends StatelessWidget {
  const FieldRow(this.label, this.value, {super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: AppText.caption.copyWith(color: AppColor.inkSubtle)),
          Text(value, style: AppText.bodyStrong),
        ],
      ),
    );
  }
}

/// Empty and error states. Always says what happened and offers the next step —
/// a bare "no data" leaves a patient stuck.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.title,
    this.body,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.isError = false,
  });

  final String title;
  final String? body;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: isError ? AppColor.dangerTint : AppColor.brandTint,
                  borderRadius: BorderRadius.circular(Radii.xl),
                ),
                child: Icon(icon,
                    size: 38,
                    color:
                        isError ? AppColor.dangerText : AppColor.brandText),
              ),
            const SizedBox(height: Space.base),
            Text(title, style: AppText.heading, textAlign: TextAlign.center),
            if (body != null) ...[
              const SizedBox(height: Space.sm),
              Text(body!,
                  style: AppText.body.copyWith(color: AppColor.inkMuted),
                  textAlign: TextAlign.center),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: Space.base),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Centred spinner with a label, so a wait is never an unexplained blank screen.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.label = 'Loading…'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColor.brand),
          const SizedBox(height: Space.base),
          Text(label, style: AppText.body.copyWith(color: AppColor.inkMuted)),
        ],
      ),
    );
  }
}

/// Sign-out control, shared by the patient profile and the three role dashboards.
///
/// Confirms first: logging out costs a patient their PIN and a stumble back
/// through the sign-in flow, which is a poor outcome for a mis-tap. On confirm it
/// revokes the token server-side and returns to the role picker with an empty
/// stack, so back cannot walk into a signed-out dashboard.
class LogoutRow extends StatelessWidget {
  const LogoutRow({super.key});

  Future<void> _confirm(BuildContext context) async {
    final agreed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.logout, size: 34),
        title: Text(t('auth.logoutConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(t('auth.logoutCancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(t('auth.logout')),
          ),
        ],
      ),
    );

    if (agreed != true || !context.mounted) return;

    final navigator = Navigator.of(context);
    await authStore.logout();
    if (!context.mounted) return;
    navigator.pushNamedAndRemoveUntil(Routes.roles, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = authStore.user;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(t('profile.account')),
        if (user != null)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.md),
            // Row/Expanded so the card fills the width. A bare FieldRow lets the
            // card shrink to the text, which read as a stray tag rather than a
            // section of the page.
            child: AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: FieldRow(
                        t('auth.signedInAs'), user.email ?? user.name),
                  ),
                ],
              ),
            ),
          ),
        AppListRow(
          title: t('auth.logout'),
          subtitle: user != null && user.isPatient
              ? t('auth.logoutSub')
              : t('auth.logoutStaffSub'),
          icon: Icons.logout,
          iconBackground: AppColor.dangerTint,
          iconColor: AppColor.dangerText,
          showChevron: false,
          onTap: () => _confirm(context),
        ),
      ],
    );
  }
}
