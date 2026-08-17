import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../features/auth.dart';
import '../features/i18n.dart';
import '../routes.dart';
import '../ui/tokens.dart';
import '../ui/widgets.dart';

/// Turns a failure into something the user can act on, in their language.
String _message(AuthResult result, {required bool pin}) {
  return switch (result.failure) {
    AuthFailure.wrongCredentials =>
      pin ? t('auth.wrongLogin') : t('auth.wrongPassword'),
    AuthFailure.taken =>
      pin ? t('auth.usernameTaken') : t('auth.emailTaken'),
    AuthFailure.lockedOut => t('auth.lockedOut'),
    AuthFailure.unreachable => t('auth.unreachable'),
    _ => t('auth.unexpected'),
  };
}

/// Shared frame for the sign-in screens: a branded gradient header that the
/// content card overlaps, so the form reads as one object lifted off the page
/// rather than a bare list of fields on grey.
///
/// The header collapses when the keyboard is up — otherwise on a short screen the
/// card is squeezed until the fields scroll under the keyboard.
class _AuthShell extends StatelessWidget {
  const _AuthShell({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
    this.footer,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final keyboardUp = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      backgroundColor: AppColor.canvas,
      // resizeToAvoidBottomInset default (true) plus a scroll view: the card
      // lifts above the keyboard instead of being clipped by it.
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _header(context, compact: keyboardUp),
                  // Negative margin pulls the card up over the gradient.
                  Transform.translate(
                    offset: const Offset(0, -Space.xxl),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Space.lg),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(Space.lg),
                        decoration: BoxDecoration(
                          color: AppColor.surface,
                          borderRadius: BorderRadius.circular(Radii.xl),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14081B4B),
                              blurRadius: 24,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: children,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  Space.lg, 0, Space.lg, Space.base),
              child: footer,
            ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, {required bool compact}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        Space.lg,
        MediaQuery.paddingOf(context).top + Space.sm,
        Space.lg,
        compact ? Space.xxl : Space.xxl + Space.lg,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BackTarget(onBrand: true),
          SizedBox(height: compact ? Space.md : Space.lg),
          if (!compact) ...[
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(Radii.lg),
              ),
              child: Icon(icon, size: 38, color: Colors.white),
            ),
            const SizedBox(height: Space.base),
          ],
          Text(title,
              style: AppText.display.copyWith(color: Colors.white)),
          const SizedBox(height: Space.xs),
          Text(subtitle,
              style: AppText.body.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}

/// Error banner. Deliberately not a snackbar: a snackbar vanishes while a slow
/// reader is still reading it, and a failed sign-in is the one thing on screen
/// worth stating plainly.
class _ErrorNote extends StatelessWidget {
  const _ErrorNote(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Space.base),
      padding: const EdgeInsets.all(Space.md),
      decoration: BoxDecoration(
        color: AppColor.dangerTint,
        borderRadius: BorderRadius.circular(Radii.sm),
        border: Border.all(color: AppColor.danger.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              color: AppColor.dangerText, size: 22),
          const SizedBox(width: Space.md),
          Expanded(
            child: Text(message,
                style: AppText.body.copyWith(color: AppColor.dangerText)),
          ),
        ],
      ),
    );
  }
}

/// Patient sign-in, step one: type the username.
class PatientLoginScreen extends StatefulWidget {
  const PatientLoginScreen({super.key});

  @override
  State<PatientLoginScreen> createState() => _PatientLoginScreenState();
}

class _PatientLoginScreenState extends State<PatientLoginScreen> {
  final _username = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    // Enables and disables Continue as they type, without a setState per keypress
    // scattered through the build.
    _username.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _username.dispose();
    super.dispose();
  }

  void _next() {
    final name = _username.text.trim();
    if (name.isEmpty) {
      setState(() => _error = t('auth.usernameEmpty'));
      return;
    }
    setState(() => _error = null);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Localized(PinScreen(username: name)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _AuthShell(
      icon: Icons.accessibility_new,
      title: t('auth.patientTitle'),
      subtitle: t('auth.patientSubtitle'),
      footer: FilledButton.icon(
        onPressed: _username.text.trim().isEmpty ? null : _next,
        icon: const Icon(Icons.arrow_forward),
        label: Text(t('auth.continue')),
      ),
      children: [
        if (_error != null) _ErrorNote(_error!),
        TextField(
          controller: _username,
          autofocus: true,
          autocorrect: false,
          enableSuggestions: false,
          textCapitalization: TextCapitalization.none,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _next(),
          style: AppText.heading,
          decoration: InputDecoration(
            labelText: t('auth.username'),
            helperText: t('auth.usernameHint'),
            helperMaxLines: 2,
            prefixIcon: const Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: Space.md),
        Row(
          children: [
            const Icon(Icons.info_outline, size: 18, color: AppColor.inkSubtle),
            const SizedBox(width: Space.sm),
            Expanded(
              child: Text(t('auth.needHelp'),
                  style: AppText.caption
                      .copyWith(color: AppColor.inkSubtle)),
            ),
          ],
        ),
        const SizedBox(height: Space.md),
        Align(
          child: TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const Localized(PatientRegisterScreen()),
              ),
            ),
            icon: const Icon(Icons.person_add_alt),
            label: Text(t('auth.newPatient')),
          ),
        ),
      ],
    );
  }
}

/// The dots and keypad shared by PIN entry (sign-in) and PIN creation
/// (registration).
///
/// No text field and no system keyboard: the system keyboard puts small keys at
/// the bottom of the screen, which is the worst case for a one-handed user with a
/// tremor. These are large targets in a fixed grid, so their positions can be
/// learned by muscle memory.
class _PinPad extends StatelessWidget {
  const _PinPad({
    required this.pin,
    required this.length,
    required this.enabled,
    required this.onDigit,
    required this.onBackspace,
  });

  final String pin;
  final int length;
  final bool enabled;
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _dots(),
        const SizedBox(height: Space.lg),
        _keypad(),
      ],
    );
  }

  /// Filled dots rather than masked characters: larger, and countable at a glance
  /// without reading glyphs.
  Widget _dots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < length; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            margin: const EdgeInsets.symmetric(horizontal: Space.sm),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < pin.length
                  ? AppColor.brandStrong
                  : AppColor.surfaceSunken,
              border: Border.all(
                color: i < pin.length
                    ? AppColor.brandStrong
                    : AppColor.border,
                width: 2,
              ),
            ),
          ),
      ],
    );
  }

  Widget _keypad() {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ];

    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.md),
            child: Row(
              children: [for (final digit in row) _key(digit: digit)],
            ),
          ),
        Row(
          children: [
            // Empty slot keeps 0 centred under 8, so the grid stays predictable.
            const Expanded(child: SizedBox(height: 68)),
            _key(digit: '0'),
            _key(
              icon: Icons.backspace_outlined,
              onTap: onBackspace,
              semanticLabel: t('auth.delete'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _key({
    String? digit,
    IconData? icon,
    VoidCallback? onTap,
    String? semanticLabel,
  }) {
    // Expanded rather than a fixed width: the keys fill the card evenly on any
    // screen width instead of clustering in the middle of a wide one.
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.xs),
        child: SizedBox(
          // Well above the 56dp minimum: this is the one control a patient has
          // to hit accurately before they can use the app at all.
          height: 68,
          child: Semantics(
            button: true,
            label: semanticLabel ?? digit,
            child: Material(
              color: icon != null
                  ? Colors.transparent
                  : AppColor.surfaceSunken,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Radii.md),
                side: BorderSide(
                  color: icon != null ? Colors.transparent : AppColor.border,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: !enabled ? null : (onTap ?? () => onDigit(digit!)),
                child: Center(
                  child: icon != null
                      ? Icon(icon,
                          size: 26,
                          color: enabled
                              ? AppColor.inkMuted
                              : AppColor.inkDisabled)
                      : Text(
                          digit!,
                          style: AppText.display.copyWith(
                            color:
                                enabled ? AppColor.ink : AppColor.inkDisabled,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Patient sign-in, step two: a 4-digit PIN on a keypad.
class PinScreen extends StatefulWidget {
  const PinScreen({super.key, required this.username});

  final String username;

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  static const _pinLength = 4;

  String _pin = '';
  bool _busy = false;
  String? _error;
  int _lockedSeconds = 0;
  Timer? _lockTimer;

  @override
  void dispose() {
    _lockTimer?.cancel();
    super.dispose();
  }

  bool get _enabled => !_busy && _lockedSeconds == 0;

  void _press(String digit) {
    if (!_enabled || _pin.length >= _pinLength) return;
    HapticFeedback.selectionClick();
    // The error stays put until the next attempt resolves it. Clearing it here
    // instead re-flowed the column on the first keypress, sliding every key
    // upward under a finger already on its way to the second digit.
    setState(() => _pin += digit);
    if (_pin.length == _pinLength) _submit();
  }

  void _backspace() {
    if (_busy || _pin.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _startLockCountdown(Duration retryAfter) {
    _lockTimer?.cancel();
    setState(() => _lockedSeconds = retryAfter.inSeconds);
    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      setState(() => _lockedSeconds--);
      if (_lockedSeconds <= 0) {
        timer.cancel();
        setState(() => _error = null);
      }
    });
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    final result = await authStore.loginPatient(widget.username, _pin);
    if (!mounted) return;

    if (result.ok) {
      // Clear the whole stack: nothing behind a successful sign-in should be
      // reachable by pressing back.
      Navigator.of(context)
          .pushNamedAndRemoveUntil(Routes.dashboard, (r) => false);
      return;
    }

    HapticFeedback.heavyImpact();
    setState(() {
      _busy = false;
      _pin = '';
      _error = _message(result, pin: true);
    });
    if (result.failure == AuthFailure.lockedOut && result.retryAfter != null) {
      _startLockCountdown(result.retryAfter!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AuthShell(
      icon: Icons.lock_outline,
      title: t('auth.enterPin'),
      subtitle: _lockedSeconds > 0
          ? '$_lockedSeconds ${t('auth.lockedSeconds')}'
          : widget.username,
      children: [
        if (_error != null) _ErrorNote(_error!),
        _PinPad(
          pin: _pin,
          length: _pinLength,
          enabled: _enabled,
          onDigit: _press,
          onBackspace: _backspace,
        ),
        SizedBox(height: _busy ? Space.base : Space.sm),
        // Reserved either way, so confirming a PIN does not shift the keypad.
        SizedBox(
          height: 22,
          child: _busy
              ? Text(t('auth.signingIn'),
                  textAlign: TextAlign.center,
                  style: AppText.caption.copyWith(color: AppColor.inkMuted))
              : null,
        ),
      ],
    );
  }
}

/// Caregiver and physiotherapist sign-in.
///
/// A conventional email and password form: these accounts can see more than one
/// patient's clinical data, so a 4-digit PIN would be the wrong trade here even
/// though it is the right one for the patient's own screen.
class StaffLoginScreen extends StatefulWidget {
  const StaffLoginScreen({super.key, required this.destination});

  /// Where to land after signing in — the dashboard for the role they picked.
  final String destination;

  @override
  State<StaffLoginScreen> createState() => _StaffLoginScreenState();
}

class _StaffLoginScreenState extends State<StaffLoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _busy = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });

    final result = await authStore.loginStaff(
      _email.text.trim(),
      _password.text,
    );
    if (!mounted) return;

    if (result.ok) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(widget.destination, (r) => false);
      return;
    }

    setState(() {
      _busy = false;
      _error = _message(result, pin: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _AuthShell(
      icon: Icons.medical_services_outlined,
      title: t('auth.staffTitle'),
      subtitle: t('auth.staffSubtitle'),
      footer: FilledButton.icon(
        onPressed: _busy ? null : _submit,
        icon: const Icon(Icons.login),
        label: Text(_busy ? t('auth.signingIn') : t('auth.signIn')),
      ),
      children: [
        if (_error != null) _ErrorNote(_error!),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          enableSuggestions: false,
          enabled: !_busy,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: t('auth.email'),
            prefixIcon: const Icon(Icons.alternate_email),
          ),
        ),
        const SizedBox(height: Space.base),
        TextField(
          controller: _password,
          obscureText: _obscure,
          enabled: !_busy,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            labelText: t('auth.password'),
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
              tooltip: t('auth.password'),
            ),
          ),
        ),
        const SizedBox(height: Space.md),
        Align(
          child: TextButton.icon(
            onPressed: _busy
                ? null
                : () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => Localized(StaffRegisterScreen(
                            destination: widget.destination)),
                      ),
                    ),
            icon: const Icon(Icons.person_add_alt),
            label: Text(t('auth.newStaff')),
          ),
        ),
      ],
    );
  }
}

/// Patient sign-up, step one: who they are. The PIN comes on its own screen with
/// the same keypad they will use to sign in from then on.
class PatientRegisterScreen extends StatefulWidget {
  const PatientRegisterScreen({super.key});

  @override
  State<PatientRegisterScreen> createState() => _PatientRegisterScreenState();
}

class _PatientRegisterScreenState extends State<PatientRegisterScreen> {
  // Mirrors the backend's rule exactly, so nothing valid here is rejected there.
  static final _usernameRe = RegExp(r'^[a-z0-9][a-z0-9._-]{2,19}$');

  final _name = TextEditingController();
  final _username = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
    _username.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    super.dispose();
  }

  bool get _filled =>
      _name.text.trim().isNotEmpty && _username.text.trim().isNotEmpty;

  Future<void> _next() async {
    final name = _name.text.trim();
    final username = _username.text.trim().toLowerCase();

    if (name.isEmpty) {
      setState(() => _error = t('auth.fullNameEmpty'));
      return;
    }
    if (!_usernameRe.hasMatch(username)) {
      setState(() => _error = t('auth.usernameInvalid'));
      return;
    }

    setState(() => _error = null);
    // The PIN screen registers the account itself. It only ever comes back here
    // on a failure the user must fix on this form — a taken username.
    final failure = await Navigator.of(context).push<AuthFailure>(
      MaterialPageRoute<AuthFailure>(
        builder: (_) => Localized(_CreatePinScreen(
          name: name,
          username: username,
        )),
      ),
    );
    if (!mounted || failure == null) return;
    setState(() => _error = t('auth.usernameTaken'));
  }

  @override
  Widget build(BuildContext context) {
    return _AuthShell(
      icon: Icons.person_add_alt,
      title: t('auth.registerPatientTitle'),
      subtitle: t('auth.registerPatientSubtitle'),
      footer: FilledButton.icon(
        onPressed: _filled ? _next : null,
        icon: const Icon(Icons.arrow_forward),
        label: Text(t('auth.continue')),
      ),
      children: [
        if (_error != null) _ErrorNote(_error!),
        TextField(
          controller: _name,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: t('auth.fullName'),
            prefixIcon: const Icon(Icons.badge_outlined),
          ),
        ),
        const SizedBox(height: Space.base),
        TextField(
          controller: _username,
          autocorrect: false,
          enableSuggestions: false,
          textCapitalization: TextCapitalization.none,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _filled ? _next() : null,
          decoration: InputDecoration(
            labelText: t('auth.username'),
            helperText: t('auth.chooseUsernameHint'),
            helperMaxLines: 2,
            prefixIcon: const Icon(Icons.person_outline),
          ),
        ),
      ],
    );
  }
}

/// Patient sign-up, step two: choose a PIN on the keypad, then repeat it. Two
/// entries because there is no "show PIN" affordance on a dots display — a typo
/// here would otherwise lock them out of the account they just made.
class _CreatePinScreen extends StatefulWidget {
  const _CreatePinScreen({required this.name, required this.username});

  final String name;
  final String username;

  @override
  State<_CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<_CreatePinScreen> {
  static const _pinLength = 4;

  String _pin = '';
  String? _first; // Set once the first entry is complete; null = choosing.
  bool _busy = false;
  String? _error;

  bool get _confirming => _first != null;

  void _press(String digit) {
    if (_busy || _pin.length >= _pinLength) return;
    HapticFeedback.selectionClick();
    setState(() => _pin += digit);
    if (_pin.length == _pinLength) _complete();
  }

  void _backspace() {
    if (_busy || _pin.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _complete() {
    if (!_confirming) {
      setState(() {
        _first = _pin;
        _pin = '';
        _error = null;
      });
      return;
    }
    if (_pin != _first) {
      HapticFeedback.heavyImpact();
      // Back to the start: correcting only the second entry would let a typo in
      // the *first* entry become the account's PIN.
      setState(() {
        _first = null;
        _pin = '';
        _error = t('auth.pinMismatch');
      });
      return;
    }
    _submit();
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    final result = await authStore.registerPatient(
      name: widget.name,
      username: widget.username,
      pin: _pin,
    );
    if (!mounted) return;

    if (result.ok) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(Routes.dashboard, (r) => false);
      return;
    }

    if (result.failure == AuthFailure.taken) {
      // Only the previous form can fix this; hand the failure back to it.
      Navigator.of(context).pop(AuthFailure.taken);
      return;
    }

    HapticFeedback.heavyImpact();
    setState(() {
      _busy = false;
      _first = null;
      _pin = '';
      _error = _message(result, pin: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _AuthShell(
      icon: Icons.pin_outlined,
      title: _confirming ? t('auth.confirmPin') : t('auth.choosePin'),
      subtitle:
          _confirming ? widget.username : t('auth.choosePinSubtitle'),
      children: [
        if (_error != null) _ErrorNote(_error!),
        _PinPad(
          pin: _pin,
          length: _pinLength,
          enabled: !_busy,
          onDigit: _press,
          onBackspace: _backspace,
        ),
        SizedBox(height: _busy ? Space.base : Space.sm),
        // Reserved either way, so confirming a PIN does not shift the keypad.
        SizedBox(
          height: 22,
          child: _busy
              ? Text(t('auth.creatingAccount'),
                  textAlign: TextAlign.center,
                  style: AppText.caption.copyWith(color: AppColor.inkMuted))
              : null,
        ),
      ],
    );
  }
}

/// Caregiver and physiotherapist sign-up. The role is not asked for: it follows
/// from which door they came in through on the roles screen, the same way the
/// staff sign-in decides its destination.
class StaffRegisterScreen extends StatefulWidget {
  const StaffRegisterScreen({super.key, required this.destination});

  /// The dashboard route this account signs in to, which also determines the
  /// role it is created with.
  final String destination;

  @override
  State<StaffRegisterScreen> createState() => _StaffRegisterScreenState();
}

class _StaffRegisterScreenState extends State<StaffRegisterScreen> {
  static const _passwordMin = 8;
  static final _emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _busy = false;
  bool _obscure = true;
  String? _error;

  String get _role =>
      widget.destination == Routes.caregiverDashboard ? 'caregiver' : 'physio';

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;

    // The same checks the server makes, caught here so the fix is one field
    // away instead of a round-trip away.
    final String? problem;
    if (_name.text.trim().isEmpty) {
      problem = t('auth.fullNameEmpty');
    } else if (!_emailRe.hasMatch(_email.text.trim())) {
      problem = t('auth.emailInvalid');
    } else if (_password.text.length < _passwordMin) {
      problem = t('auth.passwordShort');
    } else if (_confirm.text != _password.text) {
      problem = t('auth.passwordMismatch');
    } else {
      problem = null;
    }
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    final result = await authStore.registerStaff(
      name: _name.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      role: _role,
    );
    if (!mounted) return;

    if (result.ok) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(widget.destination, (r) => false);
      return;
    }

    setState(() {
      _busy = false;
      _error = _message(result, pin: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _AuthShell(
      icon: Icons.person_add_alt,
      title: t('auth.registerStaffTitle'),
      subtitle: t('auth.staffSubtitle'),
      footer: FilledButton.icon(
        onPressed: _busy ? null : _submit,
        icon: const Icon(Icons.check),
        label: Text(
            _busy ? t('auth.creatingAccount') : t('auth.createAccount')),
      ),
      children: [
        if (_error != null) _ErrorNote(_error!),
        TextField(
          controller: _name,
          enabled: !_busy,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: t('auth.fullName'),
            prefixIcon: const Icon(Icons.badge_outlined),
          ),
        ),
        const SizedBox(height: Space.base),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          enableSuggestions: false,
          enabled: !_busy,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: t('auth.email'),
            prefixIcon: const Icon(Icons.alternate_email),
          ),
        ),
        const SizedBox(height: Space.base),
        TextField(
          controller: _password,
          obscureText: _obscure,
          enabled: !_busy,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: t('auth.password'),
            helperText: t('auth.passwordHint'),
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
              tooltip: t('auth.password'),
            ),
          ),
        ),
        const SizedBox(height: Space.base),
        TextField(
          controller: _confirm,
          obscureText: _obscure,
          enabled: !_busy,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            labelText: t('auth.confirmPassword'),
            prefixIcon: const Icon(Icons.lock_outline),
          ),
        ),
      ],
    );
  }
}
