import 'package:flutter/material.dart';

import '../core/branding.dart';

/// Scroll physics that allow pull-to-refresh even when content is short.
const kGlassRefreshPhysics = AlwaysScrollableScrollPhysics();

/// Branded pull-to-refresh wrapper — use on any vertically scrollable child.
class GlassRefreshIndicator extends StatelessWidget {
  const GlassRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: kBrandColor,
      backgroundColor: kGlassFill,
      displacement: 24,
      child: child,
    );
  }
}
