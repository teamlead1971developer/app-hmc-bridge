import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/branding.dart';

/// Where the backdrop composition anchors. Each variant places one red glow
/// and one faint white glow.
enum GlowPosition { bottom, center, top }

/// App-wide dark backdrop: near-black base and blurred brand-red glow
/// (per DESIGN_SYSTEM.md "Backdrop").
///
/// Mounted once above the router's Navigator (see `main.dart`), so the
/// composition survives page transitions. Screens move it by setting
/// [GlassBackground.position]; the move animates automatically.
class GlassBackground extends StatelessWidget {
  const GlassBackground({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 700),
  });

  final Widget child;
  final Duration duration;

  static const baseColor = kBaseColor;

  /// Global backdrop position, shared across all screens.
  static final position = ValueNotifier<GlowPosition>(GlowPosition.top);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: baseColor)),
        Positioned.fill(
          child: ClipRect(
            child: ValueListenableBuilder<GlowPosition>(
              valueListenable: position,
              builder: (context, pos, _) =>
                  _Backdrop(variant: pos, duration: duration),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Layout of one backdrop element, in the design canvas' edge-offset terms.
class _Spot {
  const _Spot({this.top, this.bottom, this.left, this.right, this.topFraction});

  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  /// Overrides [top] as a fraction of the screen height.
  final double? topFraction;

  /// Resolves to a top-left anchor so moves between variants can animate.
  Offset resolve(Size screen, double size) {
    final x = left ?? screen.width - size - (right ?? 0);
    final y = topFraction != null
        ? screen.height * topFraction!
        : (top ?? screen.height - size - (bottom ?? 0));
    return Offset(x, y);
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop({required this.variant, required this.duration});

  final GlowPosition variant;
  final Duration duration;

  ({_Spot red, _Spot white}) get _spots => switch (variant) {
        GlowPosition.top => (
            red: const _Spot(top: -170, left: -90),
            white: const _Spot(top: 140, right: -120),
          ),
        GlowPosition.center => (
            red: const _Spot(topFraction: 0.30, left: -140),
            white: const _Spot(top: -80, right: -90),
          ),
        GlowPosition.bottom => (
            red: const _Spot(bottom: -190, right: -110),
            white: const _Spot(top: 60, left: -110),
          ),
      };

  ({double red, double white}) get _sizes => switch (variant) {
        GlowPosition.top => (red: 420, white: 260),
        GlowPosition.center => (red: 460, white: 240),
        GlowPosition.bottom => (red: 440, white: 250),
      };

  @override
  Widget build(BuildContext context) {
    final spots = _spots;
    final sizes = _sizes;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screen = constraints.biggest;

        Widget place(_Spot spot, double size, Widget child) {
          final offset = spot.resolve(screen, size);
          return AnimatedPositioned(
            duration: duration,
            curve: Curves.easeInOutCubic,
            left: offset.dx,
            top: offset.dy,
            width: size,
            height: size,
            child: child,
          );
        }

        return Stack(
          children: [
            place(
              spots.red,
              sizes.red,
              const _Drift(
                period: Duration(seconds: 18),
                child: _Glow(color: kBrandColor, opacity: 0.5),
              ),
            ),
            place(
              spots.white,
              sizes.white,
              const _Drift(
                period: Duration(seconds: 22),
                phase: 0.4,
                child: _Glow(color: Colors.white, opacity: 0.05),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Very slow vertical drift: ±26px, ease-in-out, alternating.
class _Drift extends StatefulWidget {
  const _Drift({required this.period, required this.child, this.phase = 0});

  final Duration period;
  final Widget child;

  /// Initial position in the cycle [0, 1), so elements don't move in step.
  final double phase;

  @override
  State<_Drift> createState() => _DriftState();
}

class _DriftState extends State<_Drift> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.period,
      value: widget.phase,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final drift = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    return AnimatedBuilder(
      animation: drift,
      child: widget.child,
      builder: (context, child) =>
          Transform.translate(offset: Offset(0, -26 * drift.value), child: child),
    );
  }
}

/// Radial glow: color fading to transparent at 70%, softly blurred.
class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.opacity});

  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
      child: Opacity(
        opacity: opacity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [color, color.withValues(alpha: 0)],
              stops: const [0, 0.7],
            ),
          ),
        ),
      ),
    );
  }
}
