import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/branding.dart';
import 'glass_card.dart';

/// Life Card visual for The Joy — frosted glass hero with membership wordmark
/// and tier label (e.g. Staff 3).
class JoyLifeCard extends StatelessWidget {
  const JoyLifeCard({
    super.key,
    required this.tierLabel,
    this.aspectRatio = 1320 / 809,
  });

  final String tierLabel;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: GlassCard(
        radius: 22,
        blur: 26,
        borderColor: kGlassBorderHero,
        shadows: const [kRedGlowShadow, ...kHeroCardShadows],
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
        clipChild: false,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Positioned.fill(child: _JoyGlassAccentLayer()),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _JoyMembershipWordmark(),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    tierLabel,
                    style: displayStyle(size: 24, weight: 500),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Backdrop-style accents — soft glow and outline shapes only.
class _JoyGlassAccentLayer extends StatelessWidget {
  const _JoyGlassAccentLayer();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -56,
            top: -32,
            width: 200,
            height: 200,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      kBrandColor.withValues(alpha: 0.22),
                      kBrandColor.withValues(alpha: 0),
                    ],
                    stops: const [0, 0.75],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 24,
            bottom: 10,
            child: Transform.rotate(
              angle: 0.56,
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white.withValues(alpha: 0.03),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 76,
            top: 18,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kRedTintFill.withValues(alpha: 0.35),
                border: Border.all(color: kRedTintBorder.withValues(alpha: 0.6)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "THE JOY MEMBERSHIP" lockup from the Life Card artwork.
class _JoyMembershipWordmark extends StatelessWidget {
  const _JoyMembershipWordmark();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'THE',
          style: displayStyle(
            size: 11,
            weight: 400,
            letterSpacing: 0.14,
            color: kTextMuted,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'JOY',
              style: displayStyle(
                size: 42,
                weight: 700,
                height: 0.95,
                letterSpacing: 0.02,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'MEMBER\nSHIP',
              style: displayStyle(
                size: 11,
                weight: 300,
                height: 1.15,
                letterSpacing: 0.18,
                color: kTextMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
