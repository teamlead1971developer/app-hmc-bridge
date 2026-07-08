import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';
import '../services/manager_approval_service.dart';
import '../services/user_service.dart';
import 'glass_card.dart';
import 'glass_controls.dart';

class _QuickAction {
  const _QuickAction({
    required this.icon,
    required this.label,
    this.route,
  });

  final IconData icon;
  final String label;
  final String? route;
}

/// 2-column quick actions grid per design 1d.
class HomeMenuGrid extends StatelessWidget {
  const HomeMenuGrid({super.key});

  static const _quickActions = [
    _QuickAction(
      icon: LucideIcons.idCard,
      label: 'Employee card',
      route: 'employeeCard',
    ),
    _QuickAction(icon: LucideIcons.users, label: 'Directory', route: 'directory'),
    _QuickAction(
      icon: LucideIcons.clipboardList,
      label: 'Check-in log',
      route: 'checkInLog',
    ),
    _QuickAction(
      icon: LucideIcons.headset,
      label: 'Help desk',
      route: 'helpDesk',
    ),
    _QuickAction(
      icon: LucideIcons.gamepad2,
      label: 'Game',
      route: 'game',
    ),
  ];

  static const _meActions = [
    _QuickAction(
      icon: LucideIcons.calendarMinus,
      label: 'Leave request',
      route: 'leaveRequest',
    ),
    _QuickAction(
      icon: LucideIcons.plane,
      label: 'Travel expense',
      route: 'travelExpense',
    ),
    _QuickAction(
      icon: LucideIcons.sparkles,
      label: 'The Joy',
      route: 'theJoy',
    ),
    _QuickAction(
      icon: LucideIcons.banknote,
      label: 'My pay',
      route: 'payslips',
    ),
  ];

  static const _whosOut = _QuickAction(
    icon: LucideIcons.calendarDays,
    label: "Who's out",
    route: 'teamCalendar',
  );

  @override
  Widget build(BuildContext context) {
    final isManager = UserService.instance.currentUser?.isLineManager ?? false;
    final teamActions = [
      _whosOut,
      if (isManager)
        const _QuickAction(
          icon: LucideIcons.clipboardCheck,
          label: 'Approvals',
          route: 'managerApprovals',
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const GlassSectionHeader('Quick actions'),
        _IconActionRow(items: _quickActions),
        const SizedBox(height: 18),
        const GlassSectionHeader('Me'),
        _ActionGrid(items: _meActions),
        const SizedBox(height: 18),
        ListenableBuilder(
          listenable: ManagerApprovalService.instance,
          builder: (context, _) {
            final pending = ManagerApprovalService.instance.pendingCount;
            return GlassSectionHeader(
              'Team management',
              trailing: isManager && pending > 0
                  ? CategoryChip(
                      label: '$pending pending',
                      accent: true,
                      uppercase: false,
                    )
                  : null,
            );
          },
        ),
        _ActionGrid(items: teamActions),
      ],
    );
  }
}

/// Compact icon-first tiles laid out in a single row (icon over label).
class _IconActionRow extends StatelessWidget {
  const _IconActionRow({required this.items});

  final List<_QuickAction> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 10.0;
        final width =
            (constraints.maxWidth - spacing * (items.length - 1)) /
                items.length;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in items)
              SizedBox(
                width: width,
                child: _IconActionTile(
                  icon: item.icon,
                  label: item.label,
                  onTap: item.route == null
                      ? () {}
                      : () => context.pushNamed(item.route!),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _IconActionTile extends StatefulWidget {
  const _IconActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_IconActionTile> createState() => _IconActionTileState();
}

class _IconActionTileState extends State<_IconActionTile> {
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
        child: Tooltip(
          message: widget.label,
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
            radius: 16,
            blur: 24,
            child: Center(
              child: RedTintIconTile(icon: widget.icon, size: 40),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({required this.items});

  final List<_QuickAction> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final item in items)
              SizedBox(
                width: width,
                child: _ActionTile(
                  icon: item.icon,
                  label: item.label,
                  onTap: item.route == null
                      ? () {}
                      : () => context.pushNamed(item.route!),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ActionTile extends StatefulWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile> {
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
          child: Row(
            children: [
              RedTintIconTile(icon: widget.icon, size: 34),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  widget.label,
                  style: bodyStyle(size: 13, weight: 500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
