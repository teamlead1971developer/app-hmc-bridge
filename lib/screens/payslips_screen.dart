import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';
import '../models/payslip.dart';
import '../screens/payslip_detail_screen.dart';
import '../services/app_refresh_service.dart';
import '../services/payslip_service.dart';
import '../widgets/app_toast.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_controls.dart';
import '../widgets/glass_refresh.dart';

class PayslipsScreen extends StatelessWidget {
  const PayslipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = PayslipService.instance;
    final payslips = service.all;
    final ytdNet = service.ytdNetAmount;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const GlassPageHeader(title: 'My pay'),
            Expanded(
              child: GlassRefreshIndicator(
                onRefresh: () => AppRefreshService.refresh(
                  AppRefreshScope.payslips,
                ),
                child: SingleChildScrollView(
                  physics: kGlassRefreshPhysics,
                  padding: const EdgeInsets.fromLTRB(22, 14, 22, 32),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GlassCard(
                      radius: 22,
                      blur: 26,
                      shadows: kHeroCardShadows,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Year to date',
                            style: bodyStyle(size: 12, color: kTextMuted),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatMoney(ytdNet),
                            style: displayStyle(size: 28, weight: 600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Net pay · ${DateTime.now().year}',
                            style: bodyStyle(size: 11, color: kTextFaint),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    GlassSectionHeader(
                      'Payslips',
                      trailing: Text(
                        '${payslips.length} available',
                        style: bodyStyle(size: 12, color: kTextMuted),
                      ),
                    ),
                    for (final slip in payslips) ...[
                      _PayslipRow(payslip: slip),
                      const SizedBox(height: 10),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.info, size: 12, color: kTextFaint),
                        const SizedBox(width: 6),
                        Text(
                          'Payslips are available after each payroll run.',
                          style: bodyStyle(size: 11, color: kTextFaint),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayslipRow extends StatefulWidget {
  const _PayslipRow({required this.payslip});

  final Payslip payslip;

  @override
  State<_PayslipRow> createState() => _PayslipRowState();
}

class _PayslipRowState extends State<_PayslipRow> {
  bool _pressed = false;

  void _download() {
    HapticFeedback.lightImpact();
    AppToast.show(
      context,
      message:
          '${widget.payslip.periodLabel} payslip download will be available with payroll integration.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        openPayslipDetail(context, widget.payslip);
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          radius: 16,
          blur: 24,
          child: Row(
            children: [
              RedTintIconTile(icon: LucideIcons.banknote, size: 34),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.payslip.periodLabel,
                      style: bodyStyle(size: 14, weight: 500),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Paid ${formatPayDate(widget.payslip.payDate)}',
                      style: monoStyle(size: 12, color: kTextFaint),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Net ${formatMoney(widget.payslip.netAmount)}',
                      style: bodyStyle(size: 12, color: kTextMuted),
                    ),
                  ],
                ),
              ),
              GlassIconButton(
                icon: LucideIcons.download,
                onPressed: _download,
                size: 40,
                iconSize: 17,
              ),
              const SizedBox(width: 4),
              Icon(LucideIcons.chevronRight, size: 16, color: kTextFaint),
            ],
          ),
        ),
      ),
    );
  }
}
