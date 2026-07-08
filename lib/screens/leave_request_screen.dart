import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';
import '../models/leave_request.dart';
import '../services/app_refresh_service.dart';
import '../services/approval_workflow.dart';
import '../services/leave_service.dart';
import '../screens/leave_request_detail_screen.dart';
import '../widgets/app_toast.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_controls.dart';
import '../widgets/glass_refresh.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final _leave = LeaveService.instance;
  LeaveStatus? _statusFilter;
  bool _showForm = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _leave,
      builder: (context, _) {
        final requests = _leave.filtered(status: _statusFilter);

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const GlassPageHeader(title: 'Leave request'),
                Expanded(
                  child: GlassRefreshIndicator(
                    onRefresh: () => AppRefreshService.refresh(
                      AppRefreshScope.leave,
                    ),
                    child: SingleChildScrollView(
                      physics: kGlassRefreshPhysics,
                      padding: const EdgeInsets.fromLTRB(22, 14, 22, 32),
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _LeaveBalanceCard(
                          balances: _leave.daysRemainingByType,
                          pendingCount: _leave.pendingCount,
                        ),
                        const SizedBox(height: 14),
                        if (_showForm) ...[
                          _NewLeaveForm(
                            onCancel: () => setState(() => _showForm = false),
                            onSubmitted: () => setState(() => _showForm = false),
                          ),
                          const SizedBox(height: 14),
                        ] else
                          BridgeGlassButton(
                            label: 'New request',
                            icon: LucideIcons.plus,
                            onPressed: () => setState(() => _showForm = true),
                          ),
                        const SizedBox(height: 18),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              FilterChipButton(
                                label: LeaveService.allStatuses,
                                selected: _statusFilter == null,
                                onTap: () => setState(() => _statusFilter = null),
                              ),
                              const SizedBox(width: 8),
                              for (final status in LeaveStatus.values) ...[
                                FilterChipButton(
                                  label: status.label,
                                  selected: _statusFilter == status,
                                  onTap: () => setState(() => _statusFilter = status),
                                ),
                                if (status != LeaveStatus.values.last)
                                  const SizedBox(width: 8),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        GlassSectionHeader(
                          'Your requests',
                          trailing: Text(
                            '${requests.length} total',
                            style: bodyStyle(size: 12, color: kTextMuted),
                          ),
                        ),
                        if (requests.isEmpty)
                          GlassCard(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'No leave requests in this filter.',
                              style: bodyStyle(size: 14, color: kTextMuted),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          for (final request in requests) ...[
                            _LeaveRequestRow(request: request),
                            const SizedBox(height: 10),
                          ],
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.info, size: 12, color: kTextFaint),
                            const SizedBox(width: 6),
                            Text(
                              'Requests route to your line manager for approval.',
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
      },
    );
  }
}

class _LeaveBalanceCard extends StatelessWidget {
  const _LeaveBalanceCard({
    required this.balances,
    required this.pendingCount,
  });

  final Map<LeaveType, int> balances;
  final int pendingCount;

  static String _shortLabel(LeaveType type) => switch (type) {
        LeaveType.annual => 'Annual',
        LeaveType.sick => 'Sick',
        LeaveType.personal => 'Personal',
        LeaveType.unpaid => 'Unpaid',
      };

  static IconData _icon(LeaveType type) => switch (type) {
        LeaveType.annual => LucideIcons.calendarDays,
        LeaveType.sick => LucideIcons.heartPulse,
        LeaveType.personal => LucideIcons.user,
        LeaveType.unpaid => LucideIcons.calendarOff,
      };

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 22,
      blur: 26,
      shadows: kHeroCardShadows,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassSectionHeader(
            'Days remaining',
            trailing: Text(
              '$pendingCount pending',
              style: bodyStyle(size: 12, color: kTextMuted),
            ),
            bottomSpacing: 14,
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = (constraints.maxWidth - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final type in LeaveType.values)
                    SizedBox(
                      width: width,
                      child: _BalanceTile(
                        icon: _icon(type),
                        label: _shortLabel(type),
                        days: balances[type] ?? 0,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BalanceTile extends StatelessWidget {
  const _BalanceTile({
    required this.icon,
    required this.label,
    required this.days,
  });

  final IconData icon;
  final String label;
  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kGlassInnerFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kGlassInnerBorder),
      ),
      child: Row(
        children: [
          RedTintIconTile(icon: icon, size: 34),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: bodyStyle(size: 12, color: kTextMuted)),
                Text(
                  '$days ${days == 1 ? 'day' : 'days'}',
                  style: displayStyle(size: 18, weight: 600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NewLeaveForm extends StatefulWidget {
  const _NewLeaveForm({
    required this.onCancel,
    required this.onSubmitted,
  });

  final VoidCallback onCancel;
  final VoidCallback onSubmitted;

  @override
  State<_NewLeaveForm> createState() => _NewLeaveFormState();
}

class _NewLeaveFormState extends State<_NewLeaveForm> {
  final _reason = TextEditingController();
  LeaveType _type = LeaveType.annual;
  DateTime _start = DateTime.now().add(const Duration(days: 7));
  DateTime _end = DateTime.now().add(const Duration(days: 7));
  bool _submitting = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool start}) async {
    final initial = start ? _start : _end;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: kBrandColor,
              surface: kBaseColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (start) {
        _start = picked;
        if (_end.isBefore(_start)) _end = _start;
      } else {
        _end = picked;
        if (_end.isBefore(_start)) _start = _end;
      }
    });
  }

  Future<void> _submit() async {
    final reason = _reason.text.trim();
    if (reason.isEmpty) {
      AppToast.error(context, 'Reason is required.');
      return;
    }

    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 400));
    await ApprovalWorkflow.submitLeave(
      type: _type,
      startDate: DateTime(_start.year, _start.month, _start.day),
      endDate: DateTime(_end.year, _end.month, _end.day),
      reason: reason,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    AppToast.success(context, 'Leave request submitted.');
    widget.onSubmitted();
  }

  @override
  Widget build(BuildContext context) {
    final days = _end.difference(_start).inDays + 1;

    return GlassCard(
      radius: 20,
      blur: 24,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('New request', style: bodyStyle(size: 15, weight: 600)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final type in LeaveType.values)
                FilterChipButton(
                  label: type.label,
                  selected: _type == type,
                  onTap: () => setState(() => _type = type),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _DateField(
                  label: 'Start date',
                  date: _start,
                  onTap: () => _pickDate(start: true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DateField(
                  label: 'End date',
                  date: _end,
                  onTap: () => _pickDate(start: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$days ${days == 1 ? 'day' : 'days'} requested',
            style: bodyStyle(size: 11, color: kTextFaint),
          ),
          const SizedBox(height: 14),
          GlassCard(
            padding: const EdgeInsets.all(16),
            radius: 16,
            blur: 20,
            child: TextField(
              controller: _reason,
              maxLines: 3,
              style: bodyStyle(size: 14),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                labelText: 'Reason',
                labelStyle: bodyStyle(size: 11, color: kTextFaint),
                floatingLabelStyle: bodyStyle(size: 11, color: kTextFaint),
                hintText: 'Brief reason for your manager',
                hintStyle: bodyStyle(size: 14, color: kTextFaint),
              ),
            ),
          ),
          const SizedBox(height: 16),
          BridgePrimaryButton(
            label: _submitting ? 'Submitting…' : 'Submit request',
            onPressed: _submitting ? null : _submit,
          ),
          const SizedBox(height: 8),
          BridgeGlassButton(
            label: 'Cancel',
            onPressed: widget.onCancel,
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        radius: 14,
        blur: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: bodyStyle(size: 11, color: kTextFaint)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(LucideIcons.calendar, size: 14, color: kTextFaint),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    formatLeaveDate(date),
                    style: bodyStyle(size: 13),
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

class _LeaveRequestRow extends StatefulWidget {
  const _LeaveRequestRow({required this.request});

  final LeaveRequest request;

  @override
  State<_LeaveRequestRow> createState() => _LeaveRequestRowState();
}

class _LeaveRequestRowState extends State<_LeaveRequestRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final status = request.status;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        openLeaveRequestDetail(context, request);
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  RedTintIconTile(
                    icon: switch (request.type) {
                      LeaveType.annual => LucideIcons.calendarDays,
                      LeaveType.sick => LucideIcons.heartPulse,
                      LeaveType.personal => LucideIcons.user,
                      LeaveType.unpaid => LucideIcons.calendarOff,
                    },
                    size: 34,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.type.label,
                          style: bodyStyle(size: 13, weight: 500),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          formatLeaveRange(request.startDate, request.endDate),
                          style: monoStyle(size: 12, color: kTextFaint),
                        ),
                      ],
                    ),
                  ),
                  _StatusChip(status: status),
                  const SizedBox(width: 4),
                  Icon(LucideIcons.chevronRight, size: 16, color: kTextFaint),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                request.reason,
                style: bodyStyle(size: 12, color: kTextMuted, height: 1.45),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                '${request.dayCount} ${request.dayCount == 1 ? 'day' : 'days'} · Submitted ${formatLeaveDate(request.submittedAt)}',
                style: bodyStyle(size: 11, color: kTextFaint),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final LeaveStatus status;

  @override
  Widget build(BuildContext context) {
    final accent = status == LeaveStatus.pending;
    return CategoryChip(
      label: status.label,
      accent: accent,
      uppercase: false,
    );
  }
}
