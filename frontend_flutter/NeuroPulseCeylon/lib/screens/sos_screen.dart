import 'dart:async';

import 'package:flutter/material.dart';

import '../features/i18n.dart';

import '../routes.dart';
import '../ui/tokens.dart';

const _alertRed = Color(0xFFA5121F);

/// Emergency SOS.
///
/// Two things matter more than aesthetics:
///
///  1. It must be cancellable by TOUCH. The original React Native screen offered
///     only a voice command ("Say STOP to cancel"), which fails exactly when it
///     is needed — a patient who has just fallen may be winded, dysarthric (very
///     common after stroke), or in a noisy room. Cancel is the largest target on
///     screen and sits at the bottom, in reach of a hand on the floor.
///  2. State must be unambiguous. Each state says plainly what happened with an
///     icon as well as colour, because red-on-red conveys nothing to a user with
///     impaired contrast sensitivity.
enum SosStatus { counting, sent, cancelled }

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  static const _countdownSeconds = 10;

  int _seconds = _countdownSeconds;
  SosStatus _status = SosStatus.counting;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_status != SosStatus.counting) return;
      setState(() {
        if (_seconds <= 1) {
          _status = SosStatus.sent;
          _timer?.cancel();
        } else {
          _seconds--;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _leave() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed(Routes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _alertRed,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(
                  Space.lg, Space.base, Space.lg, 0),
              padding: const EdgeInsets.symmetric(vertical: Space.md),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(Radii.md),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.white, size: 22),
                  const SizedBox(width: Space.sm),
                  Text(
                    switch (_status) {
                      SosStatus.sent => t('sos.sent'),
                      SosStatus.cancelled => t('sos.cancelled'),
                      SosStatus.counting => t('sos.active'),
                    },
                    style: AppText.label.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(child: _body()),
            Padding(
              padding: const EdgeInsets.all(Space.lg),
              child: _status == SosStatus.counting
                  // Dark ink on white reads clearly against the red field; a
                  // filled button here would be white-on-white.
                  ? OutlinedButton.icon(
                      onPressed: () =>
                          setState(() => _status = SosStatus.cancelled),
                      icon: const Icon(Icons.close),
                      label: Text(t('sos.imOkCancel')),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(64),
                      ),
                    )
                  : OutlinedButton(
                      onPressed: _leave,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(64),
                      ),
                      child: Text(t('common.backToHome')),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_status == SosStatus.counting) ...[
            Text(t('sos.fallDetected'),
                style: AppText.display.copyWith(color: Colors.white),
                textAlign: TextAlign.center),
            const SizedBox(height: Space.lg),
            Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white54, width: 6),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$_seconds',
                      style: AppText.metric.copyWith(color: Colors.white)),
                  Text(t('sos.seconds'),
                      style: AppText.label.copyWith(color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: Space.lg),
            Text(t('sos.contacting'),
                style: AppText.body.copyWith(color: Colors.white)),
          ] else ...[
            Icon(
              _status == SosStatus.sent
                  ? Icons.check_circle
                  : Icons.cancel,
              size: 92,
              color: Colors.white,
            ),
            const SizedBox(height: Space.base),
            Text(
              _status == SosStatus.sent
                  ? t('sos.helpOnWay')
                  : t('sos.cancelled'),
              style: AppText.title.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Space.sm),
            Text(
              _status == SosStatus.sent
                  ? t('sos.helpBody')
                  : t('sos.cancelledBody'),
              style: AppText.body.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: Space.xl),
          Container(
            padding: const EdgeInsets.all(Space.base),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(Radii.lg),
            ),
            child: Row(
              children: [
                const Icon(Icons.person, color: Colors.white, size: 26),
                const SizedBox(width: Space.base),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t('sos.primaryContact'),
                          style:
                              AppText.caption.copyWith(color: Colors.white)),
                      Text('Dr. Sarah Jenkins',
                          style: AppText.subheading
                              .copyWith(color: Colors.white)),
                    ],
                  ),
                ),
                const Icon(Icons.call, color: Colors.white, size: 26),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
