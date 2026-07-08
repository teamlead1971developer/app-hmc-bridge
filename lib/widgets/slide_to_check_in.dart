import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';

/// Slide-to-check-in control: drag knob ≥80% to trigger [onComplete].
class SlideToCheckIn extends StatefulWidget {
  const SlideToCheckIn({
    super.key,
    required this.onComplete,
    this.enabled = true,
    this.label = 'Slide to check in',
    this.successLabel,
    this.completed = false,
  });

  final Future<void> Function() onComplete;
  final bool enabled;
  final String label;
  final String? successLabel;
  final bool completed;

  @override
  State<SlideToCheckIn> createState() => _SlideToCheckInState();
}

class _SlideToCheckInState extends State<SlideToCheckIn> {
  static const _knobSize = 44.0;
  static const _trackHeight = 60.0;
  static const _padding = 8.0;
  static const _threshold = 0.8;

  double _dragFraction = 0;
  bool _busy = false;
  bool _localCompleted = false;

  bool get _done => widget.completed || _localCompleted;

  @override
  void didUpdateWidget(SlideToCheckIn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.completed && !oldWidget.completed) {
      _dragFraction = 1;
    }
  }

  Future<void> _finish(double maxTravel) async {
    if (_busy || _done || !widget.enabled) return;
    setState(() {
      _busy = true;
      _dragFraction = 1;
    });
    await HapticFeedback.mediumImpact();
    try {
      await widget.onComplete();
      if (!mounted) return;
      setState(() => _localCompleted = true);
      await HapticFeedback.heavyImpact();
    } catch (_) {
      if (mounted) {
        setState(() {
          _dragFraction = 0;
          _busy = false;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxTravel = constraints.maxWidth - _knobSize - _padding * 2;
        final offset = _done ? maxTravel : maxTravel * _dragFraction;

        return Opacity(
          opacity: widget.enabled ? 1 : 0.45,
          child: Container(
            height: _trackHeight,
            clipBehavior: Clip.none,
            decoration: BoxDecoration(
              color: kGlassFill,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: kGlassBorder),
            ),
            padding: const EdgeInsets.all(_padding),
            child: SizedBox(
              height: _knobSize,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Text(
                    _done
                        ? (widget.successLabel ?? 'Checked in')
                        : widget.label,
                    style: bodyStyle(
                      size: 14,
                      color: _done ? kText : kTextMuted,
                      weight: _done ? 600 : 400,
                    ),
                  ),
                  Positioned(
                    left: offset,
                    top: 0,
                    child: _done
                      ? _Knob(icon: LucideIcons.check, glow: false)
                      : GestureDetector(
                          onHorizontalDragUpdate: widget.enabled && !_busy
                              ? (details) {
                                  setState(() {
                                    _dragFraction = (_dragFraction +
                                            details.delta.dx / maxTravel)
                                        .clamp(0.0, 1.0);
                                  });
                                }
                              : null,
                          onHorizontalDragEnd: widget.enabled && !_busy
                              ? (_) {
                                  if (_dragFraction >= _threshold) {
                                    _finish(maxTravel);
                                  } else {
                                    setState(() => _dragFraction = 0);
                                  }
                                }
                              : null,
                          child: _Knob(
                            icon: LucideIcons.arrowRight,
                            glow: true,
                          ),
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Knob extends StatelessWidget {
  const _Knob({required this.icon, required this.glow});

  final IconData icon;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _SlideToCheckInState._knobSize,
      height: _SlideToCheckInState._knobSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: kRedGradient,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        boxShadow: glow
            ? const [
                BoxShadow(
                  color: Color(0x80AC0F0D),
                  offset: Offset(0, 8),
                  blurRadius: 24,
                ),
              ]
            : null,
      ),
      child: Icon(icon, size: 18, color: Colors.white),
    );
  }
}
