import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';
import '../models/travel_expense.dart';
import '../services/app_refresh_service.dart';
import '../services/approval_workflow.dart';
import '../services/payslip_service.dart';
import '../services/travel_expense_service.dart';
import '../screens/travel_expense_detail_screen.dart';
import '../widgets/app_toast.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_controls.dart';
import '../widgets/glass_refresh.dart';

class TravelExpenseScreen extends StatefulWidget {
  const TravelExpenseScreen({super.key});

  @override
  State<TravelExpenseScreen> createState() => _TravelExpenseScreenState();
}

class _TravelExpenseScreenState extends State<TravelExpenseScreen> {
  final _expenses = TravelExpenseService.instance;
  TravelExpenseStatus? _statusFilter;
  bool _showForm = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _expenses,
      builder: (context, _) {
        final claims = _expenses.filtered(status: _statusFilter);

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const GlassPageHeader(title: 'Travel expense'),
                Expanded(
                  child: GlassRefreshIndicator(
                    onRefresh: () => AppRefreshService.refresh(
                      AppRefreshScope.travelExpense,
                    ),
                    child: SingleChildScrollView(
                      physics: kGlassRefreshPhysics,
                      padding: const EdgeInsets.fromLTRB(22, 14, 22, 32),
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SummaryCard(
                          pendingAmount: _expenses.pendingAmount,
                          ytdReimbursed: _expenses.ytdReimbursed,
                          pendingCount: _expenses.pendingCount,
                        ),
                        const SizedBox(height: 14),
                        if (_showForm) ...[
                          _NewClaimForm(
                            onCancel: () => setState(() => _showForm = false),
                            onSubmitted: () => setState(() => _showForm = false),
                          ),
                          const SizedBox(height: 14),
                        ] else
                          BridgeGlassButton(
                            label: 'New claim',
                            icon: LucideIcons.plus,
                            onPressed: () => setState(() => _showForm = true),
                          ),
                        const SizedBox(height: 18),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              FilterChipButton(
                                label: TravelExpenseService.allStatuses,
                                selected: _statusFilter == null,
                                onTap: () => setState(() => _statusFilter = null),
                              ),
                              const SizedBox(width: 8),
                              for (final status in TravelExpenseStatus.values) ...[
                                FilterChipButton(
                                  label: status.label,
                                  selected: _statusFilter == status,
                                  onTap: () => setState(() => _statusFilter = status),
                                ),
                                if (status != TravelExpenseStatus.values.last)
                                  const SizedBox(width: 8),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        GlassSectionHeader(
                          'Your claims',
                          trailing: Text(
                            '${claims.length} total',
                            style: bodyStyle(size: 12, color: kTextMuted),
                          ),
                        ),
                        if (claims.isEmpty)
                          GlassCard(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'No expense claims in this filter.',
                              style: bodyStyle(size: 14, color: kTextMuted),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          for (final claim in claims) ...[
                            _ClaimRow(claim: claim),
                            const SizedBox(height: 10),
                          ],
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.info, size: 12, color: kTextFaint),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Attach a receipt for each claim. Finance reviews within 5 business days.',
                                style: bodyStyle(size: 11, color: kTextFaint),
                                textAlign: TextAlign.center,
                              ),
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.pendingAmount,
    required this.ytdReimbursed,
    required this.pendingCount,
  });

  final int pendingAmount;
  final int ytdReimbursed;
  final int pendingCount;

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
            'Reimbursement',
            trailing: Text(
              '$pendingCount pending',
              style: bodyStyle(size: 12, color: kTextMuted),
            ),
            bottomSpacing: 14,
          ),
          Row(
            children: [
              Expanded(
                child: _SummaryStat(
                  label: 'Awaiting approval',
                  value: formatMoney(pendingAmount),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryStat(
                  label: 'Paid this year',
                  value: formatMoney(ytdReimbursed),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kGlassInnerFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kGlassInnerBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: bodyStyle(size: 12, color: kTextMuted)),
          const SizedBox(height: 4),
          Text(value, style: displayStyle(size: 18, weight: 600)),
        ],
      ),
    );
  }
}

class _NewClaimForm extends StatefulWidget {
  const _NewClaimForm({
    required this.onCancel,
    required this.onSubmitted,
  });

  final VoidCallback onCancel;
  final VoidCallback onSubmitted;

  @override
  State<_NewClaimForm> createState() => _NewClaimFormState();
}

class _NewClaimFormState extends State<_NewClaimForm> {
  static bool _pickerInUse = false;

  final _tripTitle = TextEditingController();
  final _amount = TextEditingController();
  final _description = TextEditingController();
  final _picker = ImagePicker();

  TravelExpenseCategory _category = TravelExpenseCategory.transport;
  DateTime _expenseDate = DateTime.now();
  String? _receiptPath;
  bool _submitting = false;
  bool _picking = false;

  @override
  void dispose() {
    _tripTitle.dispose();
    _amount.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expenseDate,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
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
    setState(() => _expenseDate = picked);
  }

  Future<void> _pickReceipt(ImageSource source) async {
    if (_picking || _pickerInUse || _submitting) return;

    _picking = true;
    _pickerInUse = true;
    if (mounted) setState(() {});

    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;
      setState(() => _receiptPath = file.path);
    } on PlatformException catch (e) {
      if (!mounted) return;
      if (e.code == 'multiple_request') return;
      AppToast.error(context, 'Could not open camera or gallery.');
    } catch (_) {
      if (!mounted) return;
      AppToast.error(context, 'Could not attach receipt.');
    } finally {
      _pickerInUse = false;
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _submit() async {
    final tripTitle = _tripTitle.text.trim();
    final description = _description.text.trim();
    final amount = parseMoneyToSatang(_amount.text);

    if (tripTitle.isEmpty) {
      AppToast.error(context, 'Trip title is required.');
      return;
    }
    if (amount == null || amount <= 0) {
      AppToast.error(context, 'Enter a valid amount.');
      return;
    }
    if (description.isEmpty) {
      AppToast.error(context, 'Description is required.');
      return;
    }
    if (_receiptPath == null) {
      AppToast.error(context, 'Receipt photo is required.');
      return;
    }

    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 400));
    await ApprovalWorkflow.submitExpense(
      category: _category,
      tripTitle: tripTitle,
      expenseDate: DateTime(
        _expenseDate.year,
        _expenseDate.month,
        _expenseDate.day,
      ),
      amount: amount,
      description: description,
      receiptPath: _receiptPath,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    AppToast.success(context, 'Expense claim submitted.');
    widget.onSubmitted();
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 20,
      blur: 24,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('New claim', style: bodyStyle(size: 15, weight: 600)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in TravelExpenseCategory.values)
                FilterChipButton(
                  label: category.label,
                  selected: _category == category,
                  onTap: () => setState(() => _category = category),
                ),
            ],
          ),
          const SizedBox(height: 14),
          GlassCard(
            padding: const EdgeInsets.all(16),
            radius: 16,
            blur: 20,
            child: TextField(
              controller: _tripTitle,
              style: bodyStyle(size: 14),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                labelText: 'Trip title',
                labelStyle: bodyStyle(size: 11, color: kTextFaint),
                floatingLabelStyle: bodyStyle(size: 11, color: kTextFaint),
                hintText: 'e.g. Bangkok client visit',
                hintStyle: bodyStyle(size: 14, color: kTextFaint),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _DateField(
                  label: 'Expense date',
                  date: _expenseDate,
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  radius: 14,
                  blur: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Amount (THB)', style: bodyStyle(size: 11, color: kTextFaint)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('฿', style: bodyStyle(size: 14, color: kTextMuted)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextField(
                              controller: _amount,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[\d.,]'),
                                ),
                              ],
                              style: bodyStyle(size: 14),
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: '0.00',
                                hintStyle: bodyStyle(size: 14, color: kTextFaint),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.all(16),
            radius: 16,
            blur: 20,
            child: TextField(
              controller: _description,
              maxLines: 3,
              style: bodyStyle(size: 14),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                labelText: 'Description',
                labelStyle: bodyStyle(size: 11, color: kTextFaint),
                floatingLabelStyle: bodyStyle(size: 11, color: kTextFaint),
                hintText: 'What was this expense for?',
                hintStyle: bodyStyle(size: 14, color: kTextFaint),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text('Receipt', style: bodyStyle(size: 11, color: kTextFaint)),
          const SizedBox(height: 8),
          if (_receiptPath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.file(
                File(_receiptPath!),
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 100,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: kGlassInnerFill,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kGlassInnerBorder),
              ),
              child: Text(
                'No receipt attached',
                style: bodyStyle(size: 13, color: kTextMuted),
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: BridgeGlassButton(
                  label: _picking ? 'Opening…' : 'Camera',
                  icon: LucideIcons.camera,
                  onPressed: _picking || _submitting
                      ? null
                      : () => _pickReceipt(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BridgeGlassButton(
                  label: 'Gallery',
                  icon: LucideIcons.image,
                  onPressed: _picking || _submitting
                      ? null
                      : () => _pickReceipt(ImageSource.gallery),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BridgePrimaryButton(
            label: _submitting ? 'Submitting…' : 'Submit claim',
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
                    formatExpenseDate(date),
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

class _ClaimRow extends StatefulWidget {
  const _ClaimRow({required this.claim});

  final TravelExpenseClaim claim;

  @override
  State<_ClaimRow> createState() => _ClaimRowState();
}

class _ClaimRowState extends State<_ClaimRow> {
  bool _pressed = false;

  static IconData _icon(TravelExpenseCategory category) => switch (category) {
        TravelExpenseCategory.transport => LucideIcons.trainFront,
        TravelExpenseCategory.meals => LucideIcons.utensils,
        TravelExpenseCategory.accommodation => LucideIcons.bed,
        TravelExpenseCategory.fuel => LucideIcons.fuel,
        TravelExpenseCategory.other => LucideIcons.receipt,
      };

  @override
  Widget build(BuildContext context) {
    final claim = widget.claim;
    final status = claim.status;
    final accent = status == TravelExpenseStatus.pending ||
        status == TravelExpenseStatus.approved;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        openTravelExpenseDetail(context, claim);
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
                  RedTintIconTile(icon: _icon(claim.category), size: 34),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          claim.tripTitle,
                          style: bodyStyle(size: 13, weight: 500),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${claim.category.label} · ${formatExpenseDate(claim.expenseDate)}',
                          style: monoStyle(size: 12, color: kTextFaint),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatMoney(claim.amount),
                        style: displayStyle(size: 15, weight: 600),
                      ),
                      const SizedBox(height: 4),
                      CategoryChip(
                        label: status.label,
                        accent: accent,
                        uppercase: false,
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Icon(LucideIcons.chevronRight, size: 16, color: kTextFaint),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                claim.description,
                style: bodyStyle(size: 12, color: kTextMuted, height: 1.45),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                'Submitted ${formatExpenseDate(claim.submittedAt)}',
                style: bodyStyle(size: 11, color: kTextFaint),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
