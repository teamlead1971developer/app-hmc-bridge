import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';
import '../services/auth_session_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_controls.dart';
import '../widgets/pin_keypad.dart';

enum _ChangeStep { current, newPin, confirm }

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final _session = AuthSessionService.instance;
  _ChangeStep _step = _ChangeStep.current;
  String _pin = '';
  String _currentPin = '';
  String _newPinDraft = '';
  bool _showError = false;
  bool _busy = false;
  String? _errorMessage;
  String? _successMessage;

  static int get _pinLength => AuthSessionService.pinLength;

  String get _title => switch (_step) {
        _ChangeStep.current => 'Current PIN',
        _ChangeStep.newPin => 'New PIN',
        _ChangeStep.confirm => 'Confirm new PIN',
      };

  String get _subtitle => switch (_step) {
        _ChangeStep.current => 'Enter your current PIN to continue.',
        _ChangeStep.newPin => 'Choose a new ${AuthSessionService.pinLength}-digit PIN.',
        _ChangeStep.confirm => 'Enter the same new PIN again.',
      };

  Future<void> _onPinChanged(String value) async {
    if (_busy) return;
    setState(() {
      _pin = value;
      _showError = false;
      _errorMessage = null;
      _successMessage = null;
    });

    if (value.length < _pinLength) return;

    switch (_step) {
      case _ChangeStep.current:
        setState(() => _busy = true);
        final ok = await _session.checkPin(value);
        if (!mounted) return;
        if (!ok) {
          setState(() {
            _busy = false;
            _pin = '';
            _showError = true;
            _errorMessage = 'Incorrect PIN. Try again.';
          });
          return;
        }
        setState(() {
          _busy = false;
          _currentPin = value;
          _pin = '';
          _step = _ChangeStep.newPin;
        });
      case _ChangeStep.newPin:
        setState(() {
          _newPinDraft = value;
          _pin = '';
          _step = _ChangeStep.confirm;
        });
      case _ChangeStep.confirm:
        if (value != _newPinDraft) {
          setState(() {
            _showError = true;
            _errorMessage = 'PINs do not match. Start over.';
            _pin = '';
            _newPinDraft = '';
            _step = _ChangeStep.newPin;
          });
          return;
        }
        setState(() => _busy = true);
        final changed = await _session.changePin(
          currentPin: _currentPin,
          newPin: value,
        );
        if (!mounted) return;
        if (!changed) {
          setState(() {
            _busy = false;
            _pin = '';
            _step = _ChangeStep.current;
            _showError = true;
            _errorMessage = 'Could not update PIN. Try again.';
          });
          return;
        }
        setState(() {
          _busy = false;
          _successMessage = 'PIN updated.';
        });
        await Future.delayed(const Duration(milliseconds: 900));
        if (!mounted) return;
        context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const GlassPageHeader(title: 'Change PIN'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 32),
                child: GlassCard(
                  radius: 22,
                  blur: 26,
                  shadows: kHeroCardShadows,
                  padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(LucideIcons.keyRound, size: 28, color: kRedLight),
                      const SizedBox(height: 16),
                      Text(
                        _title,
                        style: displayStyle(size: 22, weight: 600),
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
                      if (_successMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _successMessage!,
                          style: bodyStyle(size: 13, color: kTextMuted),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 28),
                      PinKeypad(
                        pin: _pin,
                        length: _pinLength,
                        enabled: !_busy,
                        showError: _showError,
                        onPinChanged: _onPinChanged,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
