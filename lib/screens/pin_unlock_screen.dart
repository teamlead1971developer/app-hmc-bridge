import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';
import '../services/app_preferences_service.dart';
import '../services/auth_session_service.dart';
import '../widgets/glass_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/pin_keypad.dart';

class PinUnlockScreen extends StatefulWidget {
  const PinUnlockScreen({super.key});

  @override
  State<PinUnlockScreen> createState() => _PinUnlockScreenState();
}

class _PinUnlockScreenState extends State<PinUnlockScreen> {
  final _session = AuthSessionService.instance;
  final _prefs = AppPreferencesService.instance;
  final _localAuth = LocalAuthentication();
  String _pin = '';
  bool _showError = false;
  bool _verifying = false;
  bool _biometricAvailable = false;
  String? _errorMessage;

  static int get _pinLength => AuthSessionService.pinLength;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GlassBackground.position.value = GlowPosition.center;
      _loadBiometricAvailability();
    });
  }

  Future<void> _loadBiometricAvailability() async {
    try {
      final can = await _localAuth.canCheckBiometrics;
      if (!mounted) return;
      setState(() => _biometricAvailable = can);
      if (_prefs.biometricUnlockEnabled && can) {
        _biometricUnlock(silent: true);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _biometricAvailable = false);
    }
  }

  Future<void> _onPinChanged(String value) async {
    if (_verifying) return;
    setState(() {
      _pin = value;
      _showError = false;
      _errorMessage = null;
    });

    if (value.length < _pinLength) return;

    setState(() => _verifying = true);
    final ok = await _session.verifyPin(value);
    if (!mounted) return;

    if (ok) {
      _goAfterUnlock();
      return;
    }

    setState(() {
      _verifying = false;
      _pin = '';
      _showError = true;
      _errorMessage = 'Incorrect PIN. Try again.';
    });
  }

  Future<void> _signInAgain() async {
    await _session.signOut();
    if (!mounted) return;
    context.goNamed('auth');
  }

  void _goAfterUnlock() {
    if (_prefs.onboardingCompleted) {
      context.goNamed('home');
    } else {
      context.goNamed('onboarding');
    }
  }

  Future<void> _biometricUnlock({bool silent = false}) async {
    if (!_prefs.biometricUnlockEnabled) return;
    try {
      final can = await _localAuth.canCheckBiometrics;
      if (!can) return;
      final ok = await _localAuth.authenticate(
        localizedReason: 'Unlock BRIDGE',
        biometricOnly: true,
      );
      if (ok && mounted) {
        _session.unlockSession();
        _goAfterUnlock();
      }
    } catch (_) {
      if (!silent && mounted) {
        setState(() {
          _errorMessage = 'Biometric unlock unavailable.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 12, 26, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                kLogoAsset,
                height: 24,
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
              ),
              const Spacer(),
              GlassCard(
                radius: 22,
                blur: 26,
                shadows: kHeroCardShadows,
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(LucideIcons.lock, size: 28, color: kRedLight),
                    const SizedBox(height: 16),
                    Text(
                      'Enter your PIN',
                      style: displayStyle(size: 24, weight: 600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Use your PIN to unlock the app.',
                      style: bodyStyle(size: 14, color: kTextMuted),
                      textAlign: TextAlign.center,
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        style: bodyStyle(size: 13, color: kRedLight),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 28),
                    PinKeypad(
                      pin: _pin,
                      length: _pinLength,
                      enabled: !_verifying,
                      showError: _showError,
                      onPinChanged: _onPinChanged,
                      showBiometric: true,
                      biometricEnabled: _prefs.biometricUnlockEnabled &&
                          _biometricAvailable &&
                          !_verifying,
                      onBiometric: () => _biometricUnlock(),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _signInAgain,
                child: Text(
                  'Sign in again',
                  style: bodyStyle(size: 13, color: kRedLight),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'For authorized personnel only.',
                style: bodyStyle(size: 12, color: kTextFaint),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
