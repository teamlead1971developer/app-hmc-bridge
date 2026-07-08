import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';
import '../models/team_approval.dart';
import '../services/app_refresh_service.dart';
import '../services/leave_service.dart';
import '../services/manager_approval_service.dart';
import '../services/payslip_service.dart';
import '../widgets/app_toast.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_controls.dart';
import '../widgets/glass_refresh.dart';

class ManagerApprovalsScreen extends StatefulWidget {
  const ManagerApprovalsScreen({super.key});

  @override
  State<ManagerApprovalsScreen> createState() => _ManagerApprovalsScreenState();
}

class _ManagerApprovalsScreenState extends State<ManagerApprovalsScreen> {
  final _approvals = ManagerApprovalService.instance;
  final _rejectReason = TextEditingController();
  String? _actingOnId;

  @override
  void dispose() {
    _rejectReason.dispose();
    super.dispose();
  }

  Future<void> _approve(TeamApproval item) async {
    setState(() => _actingOnId = item.id);
    await Future.delayed(const Duration(milliseconds: 300));
    _approvals.approve(item.id);
    if (!mounted) return;
    setState(() => _actingOnId = null);
    AppToast.success(context, '${item.employeeName} request approved.');
  }

  Future<void> _reject(TeamApproval item) async {
    final reason = _rejectReason.text.trim();
    if (reason.isEmpty) {
      AppToast.error(context, 'A rejection reason is required.');
      return;
    }
    setState(() => _actingOnId = item.id);
    await Future.delayed(const Duration(milliseconds: 300));
    _approvals.reject(item.id, reason: reason);
    if (!mounted) return;
    setState(() => _actingOnId = null);
    _rejectReason.clear();
    Navigator.of(context).pop();
    AppToast.show(context, message: '${item.employeeName} request declined.');
  }

  void _showRejectSheet(TeamApproval item) {
    _rejectReason.clear();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            22,
            0,
            22,
            22 + MediaQuery.paddingOf(context).bottom,
          ),
          child: GlassCard(
            radius: 22,
            blur: 28,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Decline request', style: displayStyle(size: 17, weight: 600)),
                const SizedBox(height: 8),
                Text(
                  item.summary,
                  style: bodyStyle(size: 13, color: kTextMuted),
                ),
                const SizedBox(height: 14),
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  radius: 14,
                  blur: 20,
                  child: TextField(
                    controller: _rejectReason,
                    maxLines: 3,
                    style: bodyStyle(size: 14),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: 'Reason for declining',
                      hintStyle: bodyStyle(size: 14, color: kTextFaint),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                BridgePrimaryButton(
                  label: 'Confirm decline',
                  onPressed: () => _reject(item),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _approvals,
      builder: (context, _) {
        final pending = _approvals.pending;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const GlassPageHeader(title: 'Approvals'),
                Expanded(
                  child: GlassRefreshIndicator(
                    onRefresh: () => AppRefreshService.refresh(
                      AppRefreshScope.managerApprovals,
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
                                'Pending review',
                                style: bodyStyle(size: 12, color: kTextMuted),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${pending.length}',
                                style: displayStyle(size: 28, weight: 600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Leave and expense requests from your team',
                                style: bodyStyle(size: 11, color: kTextFaint),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        if (pending.isEmpty)
                          GlassCard(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'No requests awaiting your approval.',
                              style: bodyStyle(size: 14, color: kTextMuted),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          for (final item in pending) ...[
                            _ApprovalCard(
                              item: item,
                              busy: _actingOnId == item.id,
                              onApprove: () => _approve(item),
                              onReject: () => _showRejectSheet(item),
                            ),
                            const SizedBox(height: 10),
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
      },
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  const _ApprovalCard({
    required this.item,
    required this.busy,
    required this.onApprove,
    required this.onReject,
  });

  final TeamApproval item;
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  static IconData _icon(TeamApproval item) => switch (item.type) {
        TeamApprovalType.leave => LucideIcons.calendarMinus,
        TeamApprovalType.expense => LucideIcons.receipt,
      };

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      radius: 16,
      blur: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RedTintIconTile(icon: _icon(item), size: 34),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.employeeName,
                      style: bodyStyle(size: 14, weight: 600),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${item.department} · ${item.type.label}',
                      style: bodyStyle(size: 12, color: kTextMuted),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.summary,
                      style: bodyStyle(size: 13, weight: 500),
                    ),
                    if (item.amount != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        formatMoney(item.amount!),
                        style: displayStyle(size: 16, weight: 600),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.detail,
            style: bodyStyle(size: 12, color: kTextMuted, height: 1.45),
          ),
          const SizedBox(height: 8),
          Text(
            'Submitted ${formatLeaveDate(item.submittedAt)}',
            style: monoStyle(size: 11, color: kTextFaint),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: BridgeGlassButton(
                  label: 'Decline',
                  onPressed: busy ? null : onReject,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BridgePrimaryButton(
                  label: busy ? 'Saving…' : 'Approve',
                  onPressed: busy ? null : onApprove,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
