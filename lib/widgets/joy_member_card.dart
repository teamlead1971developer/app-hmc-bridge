import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';
import '../models/joy_member.dart';
import '../services/joy_service.dart';
import 'glass_card.dart';
import 'glass_controls.dart';
import 'joy_life_card.dart';

/// Membership block for The Joy hub — life card, member summary, and QR code.
class JoyMembershipPanel extends StatelessWidget {
  const JoyMembershipPanel({super.key, required this.member});

  final JoyMember member;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        JoyLifeCard(tierLabel: member.tier.label),
        const SizedBox(height: 14),
        const GlassSectionHeader('Membership'),
        JoyMemberSummaryHero(member: member),
      ],
    );
  }
}

/// Member details and point balance — hero glass card.
class JoyMemberSummaryHero extends StatelessWidget {
  const JoyMemberSummaryHero({super.key, required this.member});

  final JoyMember member;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 22,
      blur: 26,
      shadows: kHeroCardShadows,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            member.fullName,
            style: displayStyle(size: 17, weight: 600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (member.nickname.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              member.nickname,
              style: bodyStyle(size: 13, color: kTextMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 10),
          _JoyCompactField(
            label: 'Email',
            value: member.email,
            fadeTruncate: true,
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _JoyCompactField(label: 'Tel', value: member.tel),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _JoyCompactField(
                  label: 'Birthday',
                  value: formatJoyDate(member.birthday),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Point balance',
                          style: bodyStyle(size: 11, color: kTextFaint),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${member.pointBalance}',
                              style: displayStyle(size: 24, weight: 600),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Points',
                              style: bodyStyle(size: 13, color: kTextMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Points expiring',
                          style: bodyStyle(size: 11, color: kTextFaint),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${member.expiringPoints}',
                              style: displayStyle(size: 15, weight: 600),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Points',
                              style: bodyStyle(size: 12, color: kTextMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Expiry date',
                          style: bodyStyle(size: 11, color: kTextFaint),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatJoyDate(member.expiringPointsDate),
                          style: bodyStyle(size: 12),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => context.pushNamed('joyPointHistory'),
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Point history',
                                style: bodyStyle(size: 12, color: kRedLight),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                LucideIcons.chevronRight,
                                size: 14,
                                color: kRedLight,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _JoyMemberQr(code: member.memberCode),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JoyMemberQr extends StatelessWidget {
  const _JoyMemberQr({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return QrImageView(
                  data: code,
                  size: constraints.maxWidth,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          code,
          style: monoStyle(size: 9),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _JoyCompactField extends StatelessWidget {
  const _JoyCompactField({
    required this.label,
    required this.value,
    this.fadeTruncate = false,
  });

  final String label;
  final String value;
  final bool fadeTruncate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: bodyStyle(size: 10, color: kTextFaint)),
        const SizedBox(height: 2),
        Text(
          value,
          style: bodyStyle(size: 13),
          maxLines: fadeTruncate ? 1 : 2,
          overflow: fadeTruncate ? TextOverflow.fade : TextOverflow.ellipsis,
          softWrap: !fadeTruncate,
        ),
      ],
    );
  }
}
