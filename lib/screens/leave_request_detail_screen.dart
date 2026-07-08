import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';
import '../models/leave_request.dart';
import '../services/app_refresh_service.dart';
import '../services/leave_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_controls.dart';
import '../widgets/glass_refresh.dart';

void openLeaveRequestDetail(BuildContext context, LeaveRequest request) {
  context.pushNamed(
    'leaveRequestDetail',
    pathParameters: {'id': request.id},
  );
}

class LeaveRequestDetailScreen extends StatelessWidget {
  const LeaveRequestDetailScreen({super.key, required this.requestId});

  final String requestId;

  @override
  Widget build(BuildContext context) {
    final request = LeaveService.instance.byId(requestId);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassPageHeader(title: request?.type.label ?? 'Leave request'),
            Expanded(
              child: request == null
                  ? Center(
                      child: Text(
                        'Leave request not found.',
                        style: bodyStyle(size: 14, color: kTextMuted),
                      ),
                    )
                  : GlassRefreshIndicator(
                      onRefresh: () => AppRefreshService.refresh(
                        AppRefreshScope.leave,
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
                                    Expanded(
                                      child: Text(
                                        formatLeaveRange(
                                          request.startDate,
                                          request.endDate,
                                        ),
                                        style: displayStyle(size: 22, weight: 600),
                                      ),
                                    ),
                                    CategoryChip(
                                      label: request.status.label,
                                      accent: request.status == LeaveStatus.pending,
                                      uppercase: false,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${request.dayCount} ${request.dayCount == 1 ? 'day' : 'days'} requested',
                                  style: bodyStyle(size: 12, color: kTextMuted),
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
                                  label: 'Submitted',
                                  value: formatLeaveDate(request.submittedAt),
                                ),
                                const SizedBox(height: 12),
                                _DetailRow(
                                  icon: LucideIcons.clock,
                                  label: 'Last updated',
                                  value: formatLeaveDate(request.statusUpdatedAt),
                                ),
                                if (request.approverName != null) ...[
                                  const SizedBox(height: 12),
                                  _DetailRow(
                                    icon: LucideIcons.userCheck,
                                    label: 'Approver',
                                    value: request.approverName!,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          const GlassSectionHeader('Reason'),
                          GlassCard(
                            padding: const EdgeInsets.all(16),
                            radius: 16,
                            blur: 24,
                            child: Text(
                              request.reason,
                              style: bodyStyle(size: 14, height: 1.5),
                            ),
                          ),
                          if (request.decisionNote != null &&
                              request.status != LeaveStatus.pending) ...[
                            const SizedBox(height: 18),
                            GlassSectionHeader(
                              request.status == LeaveStatus.rejected
                                  ? 'Rejection reason'
                                  : 'Approver note',
                            ),
                            GlassCard(
                              padding: const EdgeInsets.all(16),
                              radius: 16,
                              blur: 24,
                              borderColor: request.status == LeaveStatus.rejected
                                  ? kRedTintBorder
                                  : kGlassBorder,
                              child: Text(
                                request.decisionNote!,
                                style: bodyStyle(
                                  size: 14,
                                  color: request.status == LeaveStatus.rejected
                                      ? kRedLight
                                      : kTextMuted,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
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
