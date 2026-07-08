import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';
import '../models/travel_expense.dart';
import '../services/app_refresh_service.dart';
import '../services/payslip_service.dart';
import '../services/travel_expense_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_controls.dart';
import '../widgets/glass_refresh.dart';

void openTravelExpenseDetail(BuildContext context, TravelExpenseClaim claim) {
  context.pushNamed(
    'travelExpenseDetail',
    pathParameters: {'id': claim.id},
  );
}

class TravelExpenseDetailScreen extends StatelessWidget {
  const TravelExpenseDetailScreen({super.key, required this.claimId});

  final String claimId;

  static IconData _categoryIcon(TravelExpenseCategory category) =>
      switch (category) {
        TravelExpenseCategory.transport => LucideIcons.trainFront,
        TravelExpenseCategory.meals => LucideIcons.utensils,
        TravelExpenseCategory.accommodation => LucideIcons.bed,
        TravelExpenseCategory.fuel => LucideIcons.fuel,
        TravelExpenseCategory.other => LucideIcons.receipt,
      };

  @override
  Widget build(BuildContext context) {
    final claim = TravelExpenseService.instance.byId(claimId);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassPageHeader(title: claim?.tripTitle ?? 'Expense claim'),
            Expanded(
              child: claim == null
                  ? Center(
                      child: Text(
                        'Expense claim not found.',
                        style: bodyStyle(size: 14, color: kTextMuted),
                      ),
                    )
                  : GlassRefreshIndicator(
                      onRefresh: () => AppRefreshService.refresh(
                        AppRefreshScope.travelExpense,
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
                                Row(
                                  children: [
                                    RedTintIconTile(
                                      icon: _categoryIcon(claim.category),
                                      size: 38,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            claim.category.label,
                                            style: bodyStyle(
                                              size: 12,
                                              color: kTextMuted,
                                            ),
                                          ),
                                          Text(
                                            formatMoney(claim.amount),
                                            style: displayStyle(
                                              size: 28,
                                              weight: 600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    CategoryChip(
                                      label: claim.status.label,
                                      accent: claim.status ==
                                              TravelExpenseStatus.pending ||
                                          claim.status ==
                                              TravelExpenseStatus.approved,
                                      uppercase: false,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          const GlassSectionHeader('Details'),
                          GlassCard(
                            padding: const EdgeInsets.all(16),
                            radius: 16,
                            blur: 24,
                            child: Column(
                              children: [
                                _DetailRow(
                                  icon: LucideIcons.calendar,
                                  label: 'Expense date',
                                  value: formatExpenseDate(claim.expenseDate),
                                ),
                                const SizedBox(height: 12),
                                _DetailRow(
                                  icon: LucideIcons.send,
                                  label: 'Submitted',
                                  value: formatExpenseDate(claim.submittedAt),
                                ),
                                const SizedBox(height: 12),
                                _DetailRow(
                                  icon: LucideIcons.clock,
                                  label: 'Last updated',
                                  value: formatExpenseDate(claim.statusUpdatedAt),
                                ),
                                if (claim.approverName != null) ...[
                                  const SizedBox(height: 12),
                                  _DetailRow(
                                    icon: LucideIcons.userCheck,
                                    label: 'Approver',
                                    value: claim.approverName!,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          const GlassSectionHeader('Description'),
                          GlassCard(
                            padding: const EdgeInsets.all(16),
                            radius: 16,
                            blur: 24,
                            child: Text(
                              claim.description,
                              style: bodyStyle(size: 14, height: 1.5),
                            ),
                          ),
                          if (claim.rejectionReason != null &&
                              claim.status == TravelExpenseStatus.rejected) ...[
                            const SizedBox(height: 18),
                            const GlassSectionHeader('Rejection reason'),
                            GlassCard(
                              padding: const EdgeInsets.all(16),
                              radius: 16,
                              blur: 24,
                              borderColor: kRedTintBorder,
                              child: Text(
                                claim.rejectionReason!,
                                style: bodyStyle(
                                  size: 14,
                                  color: kRedLight,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 18),
                          const GlassSectionHeader('Receipt'),
                          _ReceiptSection(receiptPath: claim.receiptPath),
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

class _ReceiptSection extends StatelessWidget {
  const _ReceiptSection({this.receiptPath});

  final String? receiptPath;

  @override
  Widget build(BuildContext context) {
    final path = receiptPath;
    final fileExists = path != null &&
        !path.startsWith('/mock/') &&
        File(path).existsSync();

    if (fileExists) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.file(
          File(path),
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    return GlassCard(
      padding: const EdgeInsets.all(24),
      radius: 16,
      blur: 24,
      child: Column(
        children: [
          RedTintIconTile(icon: LucideIcons.receipt, size: 38),
          const SizedBox(height: 12),
          Text(
            path != null ? 'Receipt on file' : 'No receipt attached',
            style: bodyStyle(size: 14, weight: 500),
          ),
          if (path != null) ...[
            const SizedBox(height: 4),
            Text(
              'Receipt preview will be available with finance integration.',
              style: bodyStyle(size: 12, color: kTextMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
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
              Text(value, style: bodyStyle(size: 14)),
            ],
          ),
        ),
      ],
    );
  }
}
