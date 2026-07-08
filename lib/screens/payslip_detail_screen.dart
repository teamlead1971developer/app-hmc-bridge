import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';
import '../models/payslip.dart';
import '../services/app_refresh_service.dart';
import '../services/notification_service.dart';
import '../services/payslip_service.dart';
import '../widgets/app_toast.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_controls.dart';
import '../widgets/glass_refresh.dart';

void openPayslipDetail(BuildContext context, Payslip payslip) {
  NotificationService.instance.markRead('payslip:${payslip.id}');
  context.pushNamed(
    'payslipDetail',
    pathParameters: {'id': payslip.id},
  );
}

class PayslipDetailScreen extends StatefulWidget {
  const PayslipDetailScreen({super.key, required this.payslipId});

  final String payslipId;

  @override
  State<PayslipDetailScreen> createState() => _PayslipDetailScreenState();
}

class _PayslipDetailScreenState extends State<PayslipDetailScreen> {
  @override
  void initState() {
    super.initState();
    NotificationService.instance.markRead('payslip:${widget.payslipId}');
  }

  void _download(BuildContext context, Payslip payslip) {
    HapticFeedback.lightImpact();
    AppToast.show(
      context,
      message:
          '${payslip.periodLabel} PDF download will be available with payroll integration.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final payslip = PayslipService.instance.byId(widget.payslipId);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassPageHeader(
              title: payslip?.periodLabel ?? 'Payslip',
            ),
            Expanded(
              child: GlassRefreshIndicator(
                onRefresh: () => AppRefreshService.refresh(
                  AppRefreshScope.payslips,
                ),
                child: SingleChildScrollView(
                  physics: kGlassRefreshPhysics,
                  padding: const EdgeInsets.fromLTRB(22, 14, 22, 32),
                  child: payslip == null
                      ? SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.5,
                          child: Center(
                            child: Text(
                              'Payslip not found.',
                              style: bodyStyle(size: 14, color: kTextMuted),
                            ),
                          ),
                        )
                      : Column(
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
                                  'Net pay',
                                  style: bodyStyle(size: 12, color: kTextMuted),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatMoney(payslip.netAmount),
                                  style: displayStyle(size: 32, weight: 600),
                                ),
                                const SizedBox(height: 12),
                                _MetaRow(
                                  icon: LucideIcons.calendar,
                                  label: 'Pay date',
                                  value: formatPayDate(payslip.payDate),
                                ),
                                const SizedBox(height: 8),
                                _MetaRow(
                                  icon: LucideIcons.calendarRange,
                                  label: 'Pay period',
                                  value: formatPayPeriod(
                                    payslip.periodStart,
                                    payslip.periodEnd,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          const GlassSectionHeader('Earnings'),
                          GlassCard(
                            padding: const EdgeInsets.all(16),
                            radius: 16,
                            blur: 24,
                            child: Column(
                              children: [
                                for (var i = 0; i < payslip.earnings.length; i++) ...[
                                  if (i > 0) const SizedBox(height: 12),
                                  _LineItemRow(item: payslip.earnings[i]),
                                ],
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Divider(height: 1, color: kGlassBorder),
                                ),
                                _TotalRow(
                                  label: 'Gross pay',
                                  amount: payslip.grossAmount,
                                  emphasized: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          const GlassSectionHeader('Deductions'),
                          GlassCard(
                            padding: const EdgeInsets.all(16),
                            radius: 16,
                            blur: 24,
                            child: Column(
                              children: [
                                for (var i = 0; i < payslip.deductions.length; i++) ...[
                                  if (i > 0) const SizedBox(height: 12),
                                  _LineItemRow(
                                    item: payslip.deductions[i],
                                    deduction: true,
                                  ),
                                ],
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Divider(height: 1, color: kGlassBorder),
                                ),
                                _TotalRow(
                                  label: 'Total deductions',
                                  amount: payslip.totalDeductions,
                                  deduction: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          GlassCard(
                            padding: const EdgeInsets.all(16),
                            radius: 16,
                            blur: 24,
                            child: _TotalRow(
                              label: 'Net pay',
                              amount: payslip.netAmount,
                              emphasized: true,
                            ),
                          ),
                          const SizedBox(height: 18),
                          BridgeGlassButton(
                            label: 'Download PDF',
                            icon: LucideIcons.download,
                            onPressed: () => _download(context, payslip),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.info, size: 12, color: kTextFaint),
                              const SizedBox(width: 6),
                              Text(
                                'For payroll queries contact HR.',
                                style: bodyStyle(size: 11, color: kTextFaint),
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

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: kTextFaint),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: bodyStyle(size: 11, color: kTextFaint)),
              Text(value, style: monoStyle(size: 13)),
            ],
          ),
        ),
      ],
    );
  }
}

class _LineItemRow extends StatelessWidget {
  const _LineItemRow({
    required this.item,
    this.deduction = false,
  });

  final PayslipLineItem item;
  final bool deduction;

  @override
  Widget build(BuildContext context) {
    final prefix = deduction ? '−' : '';
    return Row(
      children: [
        Expanded(
          child: Text(item.label, style: bodyStyle(size: 14)),
        ),
        Text(
          '$prefix${formatMoney(item.amount)}',
          style: monoStyle(
            size: 13,
            color: deduction ? kTextMuted : kText,
          ),
        ),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.amount,
    this.deduction = false,
    this.emphasized = false,
  });

  final String label;
  final int amount;
  final bool deduction;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final prefix = deduction ? '−' : '';
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: emphasized
                ? bodyStyle(size: 15, weight: 600)
                : bodyStyle(size: 14, weight: 500),
          ),
        ),
        Text(
          '$prefix${formatMoney(amount)}',
          style: emphasized
              ? displayStyle(size: 18, weight: 600)
              : monoStyle(size: 13, color: deduction ? kTextMuted : kText),
        ),
      ],
    );
  }
}
