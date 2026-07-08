import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';
import 'glass_card.dart';

/// Numeric PIN entry with glass styling per design system.
class PinKeypad extends StatefulWidget {
  const PinKeypad({
    super.key,
    required this.pin,
    required this.length,
    required this.onPinChanged,
    this.enabled = true,
    this.showError = false,
    this.showBiometric = false,
    this.biometricEnabled = false,
    this.onBiometric,
  });

  final String pin;
  final int length;
  final ValueChanged<String> onPinChanged;
  final bool enabled;
  final bool showError;
  final bool showBiometric;
  final bool biometricEnabled;
  final VoidCallback? onBiometric;

  @override
  State<PinKeypad> createState() => _PinKeypadState();
}

class _PinKeypadState extends State<PinKeypad>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant PinKeypad oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showError && !oldWidget.showError) {
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _addDigit(String digit) {
    if (!widget.enabled || widget.pin.length >= widget.length) return;
    HapticFeedback.selectionClick();
    widget.onPinChanged(widget.pin + digit);
  }

  void _removeDigit() {
    if (!widget.enabled || widget.pin.isEmpty) return;
    HapticFeedback.selectionClick();
    widget.onPinChanged(widget.pin.substring(0, widget.pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: child,
            );
          },
          child: _PinDots(
            length: widget.length,
            filled: widget.pin.length,
            error: widget.showError,
          ),
        ),
        const SizedBox(height: 28),
        _KeypadGrid(
          enabled: widget.enabled,
          onDigit: _addDigit,
          onDelete: _removeDigit,
          showBiometric: widget.showBiometric,
          biometricEnabled: widget.biometricEnabled,
          onBiometric: widget.onBiometric,
        ),
      ],
    );
  }
}

class _PinDots extends StatelessWidget {
  const _PinDots({
    required this.length,
    required this.filled,
    required this.error,
  });

  final int length;
  final int filled;
  final bool error;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < length; i++) ...[
          if (i > 0) const SizedBox(width: 14),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < filled
                  ? (error ? kRedLight : kBrandColor)
                  : Colors.white.withValues(alpha: 0.12),
              border: Border.all(
                color: error && i < filled
                    ? kRedLight.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.18),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _KeypadGrid extends StatelessWidget {
  const _KeypadGrid({
    required this.enabled,
    required this.onDigit,
    required this.onDelete,
    this.showBiometric = false,
    this.biometricEnabled = false,
    this.onBiometric,
  });

  final bool enabled;
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final bool showBiometric;
  final bool biometricEnabled;
  final VoidCallback? onBiometric;

  static const _keys = [
  ['1', '2', '3'],
  ['4', '5', '6'],
  ['7', '8', '9'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in _keys) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final key in row) ...[
                _KeyButton(
                  label: key,
                  enabled: enabled,
                  onTap: () => onDigit(key),
                ),
                if (key != row.last) const SizedBox(width: 16),
              ],
            ],
          ),
          const SizedBox(height: 16),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showBiometric)
              _KeyButton(
                icon: LucideIcons.scanFace,
                enabled: enabled && biometricEnabled,
                onTap: onBiometric ?? () {},
              )
            else
              const SizedBox(width: 76, height: 76),
            const SizedBox(width: 16),
            _KeyButton(
              label: '0',
              enabled: enabled,
              onTap: () => onDigit('0'),
            ),
            const SizedBox(width: 16),
            _KeyButton(
              icon: LucideIcons.delete,
              enabled: enabled,
              onTap: onDelete,
            ),
          ],
        ),
      ],
    );
  }
}

class _KeyButton extends StatefulWidget {
  const _KeyButton({
    this.label,
    this.icon,
    required this.enabled,
    required this.onTap,
  }) : assert(label != null || icon != null);

  final String? label;
  final IconData? icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<_KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<_KeyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap();
            }
          : null,
      onTapCancel: widget.enabled ? () => setState(() => _pressed = false) : null,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Opacity(
          opacity: widget.enabled ? 1 : 0.45,
          child: GlassCard(
            padding: EdgeInsets.zero,
            radius: 16,
            blur: 20,
            child: SizedBox(
              width: 76,
              height: 76,
              child: Center(
                child: widget.label != null
                    ? Text(
                        widget.label!,
                        style: displayStyle(size: 24, weight: 600),
                      )
                    : Icon(widget.icon, size: 22, color: kTextMuted),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
