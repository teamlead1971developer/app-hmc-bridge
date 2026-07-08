import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';
import '../services/app_refresh_service.dart';
import '../services/joy_service.dart';
import '../widgets/glass_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_controls.dart';
import '../widgets/glass_refresh.dart';
import '../widgets/joy_member_card.dart';

class TheJoyScreen extends StatefulWidget {
  const TheJoyScreen({super.key});

  @override
  State<TheJoyScreen> createState() => _TheJoyScreenState();
}

class _TheJoyScreenState extends State<TheJoyScreen> {
  final _joy = JoyService.instance;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GlassBackground.position.value = GlowPosition.top;
    });
    _load();
  }

  Future<void> _load() async {
    await _joy.ensureLoaded();
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _onRefresh() async {
    await AppRefreshService.refresh(AppRefreshScope.joy);
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const GlassPageHeader(title: 'The Joy'),
            Expanded(
              child: GlassRefreshIndicator(
                onRefresh: _onRefresh,
                child: _loading
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          return ListView(
                            physics: kGlassRefreshPhysics,
                            children: [
                              SizedBox(
                                height: constraints.maxHeight,
                                child: Center(
                                  child: Text(
                                    'Loading membership…',
                                    style: monoStyle(size: 14, color: kTextMuted),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      )
                    : ListenableBuilder(
                        listenable: _joy,
                        builder: (context, _) {
                          final member = _joy.member!;
                          final available = _joy.availablePrivileges.length;
                          final coupons = _joy.coupons().length;

                          return SingleChildScrollView(
                            physics: kGlassRefreshPhysics,
                            padding: const EdgeInsets.fromLTRB(22, 14, 22, 32),
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              JoyMembershipPanel(member: member),
                              const SizedBox(height: 18),
                              GlassSectionHeader(
                                'Benefits',
                                trailing: Text(
                                  '$available privileges · $coupons coupons',
                                  style: bodyStyle(size: 12, color: kTextMuted),
                                ),
                              ),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final width =
                                      (constraints.maxWidth - 10) / 2;
                                  return Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      SizedBox(
                                        width: width,
                                        child: _JoyBenefitTile(
                                          icon: LucideIcons.gift,
                                          label: 'Privileges',
                                          caption:
                                              '$available available this month',
                                          onTap: () => context.pushNamed(
                                            'joyPrivileges',
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: width,
                                        child: _JoyBenefitTile(
                                          icon: LucideIcons.ticket,
                                          label: 'Coupon / Voucher',
                                          caption: '$coupons in your wallet',
                                          onTap: () => context.pushNamed(
                                            'joyCoupons',
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    LucideIcons.info,
                                    size: 12,
                                    color: kTextFaint,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Staff receive two 20% discount privileges each month.',
                                      style: bodyStyle(
                                        size: 11,
                                        color: kTextFaint,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JoyBenefitTile extends StatefulWidget {
  const _JoyBenefitTile({
    required this.icon,
    required this.label,
    required this.caption,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String caption;
  final VoidCallback onTap;

  @override
  State<_JoyBenefitTile> createState() => _JoyBenefitTileState();
}

class _JoyBenefitTileState extends State<_JoyBenefitTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: GlassCard(
          padding: const EdgeInsets.all(13),
          radius: 16,
          blur: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RedTintIconTile(icon: widget.icon, size: 34),
              const SizedBox(height: 11),
              Text(
                widget.label,
                style: bodyStyle(size: 13, weight: 500),
              ),
              const SizedBox(height: 3),
              Text(
                widget.caption,
                style: bodyStyle(size: 11, color: kTextFaint),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
