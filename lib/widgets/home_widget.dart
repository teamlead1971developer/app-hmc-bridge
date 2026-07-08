import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/branding.dart';

/// Home screen header: full-width logo bar, styled like [AppNavbar].
class HomeWidget extends StatelessWidget {
  const HomeWidget({super.key});

  static const _outerPadding = EdgeInsets.fromLTRB(16, 12, 16, 0);
  static const _innerPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  static const _radius = 16.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _outerPadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_radius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                width: double.infinity,
                padding: _innerPadding,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(_radius),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Image.asset(kLogoAsset, height: 20, fit: BoxFit.contain),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
