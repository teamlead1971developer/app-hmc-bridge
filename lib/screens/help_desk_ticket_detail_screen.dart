import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';
import '../models/help_ticket.dart';
import '../services/app_refresh_service.dart';
import '../services/help_desk_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_controls.dart';
import '../widgets/glass_refresh.dart';

void openHelpTicketDetail(BuildContext context, HelpTicket ticket) {
  context.pushNamed(
    'helpTicketDetail',
    pathParameters: {'id': ticket.id},
  );
}

class HelpDeskTicketDetailScreen extends StatelessWidget {
  const HelpDeskTicketDetailScreen({super.key, required this.ticketId});

  final String ticketId;

  static IconData _categoryIcon(TicketCategory category) => switch (category) {
        TicketCategory.it => LucideIcons.monitor,
        TicketCategory.facilities => LucideIcons.building2,
        TicketCategory.hr => LucideIcons.users,
        TicketCategory.other => LucideIcons.circleHelp,
      };

  @override
  Widget build(BuildContext context) {
    final ticket = HelpDeskService.instance.byId(ticketId);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const GlassPageHeader(title: 'Support ticket'),
            Expanded(
              child: GlassRefreshIndicator(
                onRefresh: () => AppRefreshService.refresh(
                  AppRefreshScope.helpDesk,
                ),
                child: SingleChildScrollView(
                  physics: kGlassRefreshPhysics,
                  padding: const EdgeInsets.fromLTRB(22, 14, 22, 32),
                  child: ticket == null
                      ? SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.5,
                          child: Center(
                            child: Text(
                              'Ticket not found.',
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
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RedTintIconTile(
                                  icon: _categoryIcon(ticket.category),
                                  size: 38,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ticket.subject,
                                        style: displayStyle(size: 20, weight: 600),
                                      ),
                                      const SizedBox(height: 8),
                                      CategoryChip(
                                        label: ticket.status.label,
                                        accent: ticket.status != TicketStatus.resolved,
                                        uppercase: false,
                                      ),
                                    ],
                                  ),
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
                                  icon: LucideIcons.tag,
                                  label: 'Category',
                                  value: ticket.category.label,
                                ),
                                const SizedBox(height: 12),
                                _DetailRow(
                                  icon: LucideIcons.calendar,
                                  label: 'Opened',
                                  value: formatTicketDate(ticket.createdAt),
                                ),
                                if (ticket.updatedAt != null) ...[
                                  const SizedBox(height: 12),
                                  _DetailRow(
                                    icon: LucideIcons.clock,
                                    label: 'Last updated',
                                    value: formatTicketDate(ticket.updatedAt!),
                                  ),
                                ],
                                if (ticket.assignee != null) ...[
                                  const SizedBox(height: 12),
                                  _DetailRow(
                                    icon: LucideIcons.user,
                                    label: 'Assigned to',
                                    value: ticket.assignee!,
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
                              ticket.description,
                              style: bodyStyle(size: 14, height: 1.5),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const GlassSectionHeader('Activity'),
                          GlassCard(
                            padding: const EdgeInsets.all(16),
                            radius: 16,
                            blur: 24,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _TimelineRow(
                                  label: 'Ticket opened',
                                  time: formatTicketDate(ticket.createdAt),
                                  active: true,
                                ),
                                if (ticket.status.index >= TicketStatus.inProgress.index) ...[
                                  const SizedBox(height: 12),
                                  _TimelineRow(
                                    label: ticket.assignee != null
                                        ? 'Assigned to ${ticket.assignee}'
                                        : 'In progress',
                                    time: ticket.updatedAt != null
                                        ? formatTicketDate(ticket.updatedAt!)
                                        : '—',
                                    active: ticket.status == TicketStatus.inProgress,
                                  ),
                                ],
                                if (ticket.status == TicketStatus.resolved) ...[
                                  const SizedBox(height: 12),
                                  _TimelineRow(
                                    label: 'Resolved',
                                    time: ticket.updatedAt != null
                                        ? formatTicketDate(ticket.updatedAt!)
                                        : '—',
                                    active: true,
                                  ),
                                ],
                              ],
                            ),
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

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.label,
    required this.time,
    required this.active,
  });

  final String label;
  final String time;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? kRedLight : Colors.white.withValues(alpha: 0.25),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: bodyStyle(size: 13, weight: 500)),
              Text(time, style: monoStyle(size: 11, color: kTextFaint)),
            ],
          ),
        ),
      ],
    );
  }
}
