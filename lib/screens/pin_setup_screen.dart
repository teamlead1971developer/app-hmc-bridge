import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';
import '../services/app_preferences_service.dart';
import '../services/auth_session_service.dart';
import '../widgets/glass_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/pin_keypad.dart';

enum _SetupStep { create, confirm }

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final _session = AuthSessionService.instance;
  _SetupStep _step = _SetupStep.create;
  String _pin = '';
  String _draftPin = '';
  bool _showError = false;
  bool _saving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GlassBackground.position.value = GlowPosition.center;
    });
  }

  String get _title => switch (_step) {
        _SetupStep.create => 'Create your PIN',
        _SetupStep.confirm => 'Confirm your PIN',
      };

  String get _subtitle => switch (_step) {
        _SetupStep.create =>
          'Choose a ${AuthSessionService.pinLength}-digit PIN to unlock the app after you close it.',
        _SetupStep.confirm => 'Enter the same PIN again to confirm.',
      };

  static int get _pinLength => AuthSessionService.pinLength;

  Future<void> _onPinChanged(String value) async {
    if (_saving) return;
    setState(() {
      _pin = value;
      _showError = false;
      _errorMessage = null;
    });

    if (value.length < _pinLength) return;

    if (_step == _SetupStep.create) {
      setState(() {
        _draftPin = value;
        _pin = '';
        _step = _SetupStep.confirm;
      });
      return;
    }

    if (value != _draftPin) {
      setState(() {
        _showError = true;
        _errorMessage = 'PINs do not match. Try again.';
        _pin = '';
        _draftPin = '';
        _step = _SetupStep.create;
      });
      return;
    }

    setState(() => _saving = true);
    await _session.setupPin(value);
    if (!mounted) return;
    final prefs = AppPreferencesService.instance;
    context.goNamed(prefs.onboardingCompleted ? 'home' : 'onboarding');
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
                      _title,
                      style: displayStyle(size: 24, weight: 600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _subtitle,
                      style: bodyStyle(size: 14, color: kTextMuted, height: 1.45),
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
                      enabled: !_saving,
                      showError: _showError,
                      onPinChanged: _onPinChanged,
                    ),
                  ],
                ),
              ),
              const Spacer(),
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
