import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';
import '../models/help_ticket.dart';
import '../screens/help_desk_ticket_detail_screen.dart';
import '../services/app_refresh_service.dart';
import '../services/help_desk_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_controls.dart';
import '../widgets/glass_refresh.dart';

class HelpDeskScreen extends StatefulWidget {
  const HelpDeskScreen({super.key});

  @override
  State<HelpDeskScreen> createState() => _HelpDeskScreenState();
}

class _HelpDeskScreenState extends State<HelpDeskScreen> {
  final _helpDesk = HelpDeskService.instance;
  TicketStatus? _statusFilter;
  bool _showForm = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _helpDesk,
      builder: (context, _) {
        final tickets = _helpDesk.filtered(status: _statusFilter);

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const GlassPageHeader(title: 'Help desk'),
                Expanded(
                  child: GlassRefreshIndicator(
                    onRefresh: () => AppRefreshService.refresh(
                      AppRefreshScope.helpDesk,
                    ),
                    child: SingleChildScrollView(
                      physics: kGlassRefreshPhysics,
                      padding: const EdgeInsets.fromLTRB(22, 14, 22, 32),
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SummaryHero(openCount: _helpDesk.openCount),
                        const SizedBox(height: 14),
                        if (_showForm) ...[
                          _NewTicketForm(
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
                        const GlassSectionHeader('Common questions'),
                        for (final item in helpDeskFaq) ...[
                          _FaqRow(question: item.question, answer: item.answer),
                          const SizedBox(height: 8),
                        ],
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              FilterChipButton(
                                label: HelpDeskService.allStatuses,
                                selected: _statusFilter == null,
                                onTap: () => setState(() => _statusFilter = null),
                              ),
                              const SizedBox(width: 8),
                              for (final status in TicketStatus.values) ...[
                                FilterChipButton(
                                  label: status.label,
                                  selected: _statusFilter == status,
                                  onTap: () => setState(() => _statusFilter = status),
                                ),
                                if (status != TicketStatus.values.last)
                                  const SizedBox(width: 8),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        GlassSectionHeader(
                          'My tickets',
                          trailing: Text(
                            '${tickets.length} total',
                            style: bodyStyle(size: 12, color: kTextMuted),
                          ),
                        ),
                        if (tickets.isEmpty)
                          GlassCard(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'No tickets in this filter.',
                              style: bodyStyle(size: 14, color: kTextMuted),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          for (final ticket in tickets) ...[
                            _TicketRow(ticket: ticket),
                            const SizedBox(height: 10),
                          ],
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.headset, size: 12, color: kTextFaint),
                            const SizedBox(width: 6),
                            Text(
                              'IT support · ext. 301 · helpdesk@company.com',
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

class _SummaryHero extends StatelessWidget {
  const _SummaryHero({required this.openCount});

  final int openCount;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 22,
      blur: 26,
      shadows: kHeroCardShadows,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          RedTintIconTile(icon: LucideIcons.headset, size: 38),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IT support',
                  style: bodyStyle(size: 12, color: kTextMuted),
                ),
                const SizedBox(height: 4),
                Text(
                  openCount == 0
                      ? 'No open tickets'
                      : '$openCount open ${openCount == 1 ? 'ticket' : 'tickets'}',
                  style: displayStyle(size: 22, weight: 600),
                ),
                const SizedBox(height: 2),
                Text(
                  'Typical response within 1 business day',
                  style: bodyStyle(size: 11, color: kTextFaint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqRow extends StatefulWidget {
  const _FaqRow({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  State<_FaqRow> createState() => _FaqRowState();
}

class _FaqRowState extends State<_FaqRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        radius: 14,
        blur: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: bodyStyle(size: 13, weight: 500),
                  ),
                ),
                Icon(
                  _expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                  size: 16,
                  color: kTextFaint,
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 8),
              Text(
                widget.answer,
                style: bodyStyle(size: 12, color: kTextMuted, height: 1.45),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NewTicketForm extends StatefulWidget {
  const _NewTicketForm({
    required this.onCancel,
    required this.onSubmitted,
  });

  final VoidCallback onCancel;
  final VoidCallback onSubmitted;

  @override
  State<_NewTicketForm> createState() => _NewTicketFormState();
}

class _NewTicketFormState extends State<_NewTicketForm> {
  final _subject = TextEditingController();
  final _description = TextEditingController();
  TicketCategory _category = TicketCategory.it;
  bool _submitting = false;

  @override
  void dispose() {
    _subject.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final subject = _subject.text.trim();
    final description = _description.text.trim();
    if (subject.isEmpty || description.isEmpty) return;

    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 350));
    HelpDeskService.instance.submit(
      category: _category,
      subject: subject,
      description: description,
    );
    if (!mounted) return;
    widget.onSubmitted();
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 20,
      blur: 26,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('New support request', style: bodyStyle(size: 15, weight: 600)),
          const SizedBox(height: 14),
          Text('Category', style: bodyStyle(size: 12, color: kTextMuted)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in TicketCategory.values)
                FilterChipButton(
                  label: category.label,
                  selected: _category == category,
                  onTap: () => setState(() => _category = category),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _FormField(
            label: 'Subject',
            controller: _subject,
            icon: LucideIcons.messageSquare,
          ),
          const SizedBox(height: 10),
          _FormField(
            label: 'Description',
            controller: _description,
            icon: LucideIcons.alignLeft,
            maxLines: 4,
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

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.controller,
    required this.icon,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      radius: 14,
      blur: 20,
      child: Row(
        crossAxisAlignment:
            maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: maxLines > 1 ? 2 : 0),
            child: Icon(icon, size: 17, color: kTextFaint),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: bodyStyle(size: 11, color: kTextFaint)),
                TextField(
                  controller: controller,
                  maxLines: maxLines,
                  style: bodyStyle(size: 14),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketRow extends StatelessWidget {
  const _TicketRow({required this.ticket});

  final HelpTicket ticket;

  IconData get _categoryIcon => switch (ticket.category) {
        TicketCategory.it => LucideIcons.monitor,
        TicketCategory.facilities => LucideIcons.building2,
        TicketCategory.hr => LucideIcons.users,
        TicketCategory.other => LucideIcons.circleHelp,
      };

  @override
  Widget build(BuildContext context) {
    final accent = ticket.status != TicketStatus.resolved;

    return GestureDetector(
      onTap: () => openHelpTicketDetail(context, ticket),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        radius: 16,
        blur: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                RedTintIconTile(icon: _categoryIcon, size: 34),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.subject,
                        style: bodyStyle(size: 13, weight: 500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        ticket.category.label,
                        style: monoStyle(size: 12, color: kTextFaint),
                      ),
                    ],
                  ),
                ),
                CategoryChip(
                  label: ticket.status.label,
                  accent: accent,
                  uppercase: false,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              ticket.description,
              style: bodyStyle(size: 12, color: kTextMuted, height: 1.45),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              'Opened ${formatTicketDate(ticket.createdAt)}',
              style: bodyStyle(size: 11, color: kTextFaint),
            ),
          ],
        ),
      ),
    );
  }
}
