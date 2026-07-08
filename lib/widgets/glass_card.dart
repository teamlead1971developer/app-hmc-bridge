import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/branding.dart';

/// Frosted-glass surface: blurs whatever is behind it and adds a
/// translucent fill with a hairline border.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.padding = const EdgeInsets.all(24),
    this.radius = 16,
    this.blur = 24,
    this.fill = kGlassFill,
    this.borderColor = kGlassBorder,
    this.shadows,
    this.clipChild = true,
  });

  final Widget child;
  final double? width;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur;
  final Color fill;
  final Color borderColor;
  final List<BoxShadow>? shadows;
  final bool clipChild;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: fill,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor),
      boxShadow: shadows,
    );

    Widget surface = Container(
      width: width,
      padding: padding,
      decoration: decoration,
      child: child,
    );

    if (clipChild) {
      surface = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: surface,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: surface,
      ),
    );
  }
}
