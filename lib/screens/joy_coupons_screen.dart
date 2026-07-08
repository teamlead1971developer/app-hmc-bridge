import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';
import '../models/joy_coupon.dart';
import '../services/app_refresh_service.dart';
import '../services/joy_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_controls.dart';
import '../widgets/glass_refresh.dart';

class JoyCouponsScreen extends StatefulWidget {
  const JoyCouponsScreen({super.key});

  @override
  State<JoyCouponsScreen> createState() => _JoyCouponsScreenState();
}

class _JoyCouponsScreenState extends State<JoyCouponsScreen> {
  final _joy = JoyService.instance;
  String _tagId = 'all';

  @override
  void initState() {
    super.initState();
    _joy.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const GlassPageHeader(title: 'Coupon / Voucher'),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
              child: Row(
                children: [
                  for (final tag in JoyService.couponTags) ...[
                    FilterChipButton(
                      label: tag.label,
                      selected: _tagId == tag.id,
                      onTap: () => setState(() => _tagId = tag.id),
                    ),
                    if (tag != JoyService.couponTags.last)
                      const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: _joy,
                builder: (context, _) {
                  final items = _joy.coupons(tagId: _tagId);
                  return GlassRefreshIndicator(
                    onRefresh: () => AppRefreshService.refresh(
                      AppRefreshScope.joy,
                    ),
                    child: items.isEmpty
                        ? LayoutBuilder(
                            builder: (context, constraints) {
                              return ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(
                                    height: constraints.maxHeight,
                                    child: Center(
                                      child: Text(
                                        'No coupons in this category.',
                                        style: bodyStyle(
                                          size: 14,
                                          color: kTextMuted,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
                            itemCount: items.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return _CouponRow(
                                item: item,
                                onTap: () => context.pushNamed(
                                  'joyCouponDetail',
                                  pathParameters: {'id': item.id},
                                ),
                              );
                            },
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CouponRow extends StatelessWidget {
  const _CouponRow({required this.item, required this.onTap});

  final JoyCoupon item;
  final VoidCallback onTap;

  static IconData _iconFor(String tagId) => switch (tagId) {
        'cafe' => LucideIcons.coffee,
        'store' => LucideIcons.shoppingBag,
        'partner' => LucideIcons.handshake,
        _ => LucideIcons.ticket,
      };

  @override
  Widget build(BuildContext context) {
    final accent = item.status == JoyCouponStatus.available;

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        radius: 16,
        blur: 24,
        child: Row(
          children: [
            RedTintIconTile(icon: _iconFor(item.tagId), size: 34),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: bodyStyle(size: 14, weight: 500)),
                  const SizedBox(height: 3),
                  Text(
                    'Valid until ${formatJoyDate(item.validUntil)}',
                    style: bodyStyle(size: 12, color: kTextMuted),
                  ),
                  if (item.summary != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.summary!,
                      style: bodyStyle(size: 11, color: kTextFaint),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            CategoryChip(
              label: item.status.label,
              accent: accent,
              uppercase: false,
            ),
          ],
        ),
      ),
    );
  }
}
