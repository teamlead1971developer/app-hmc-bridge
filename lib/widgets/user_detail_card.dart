import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/user.dart';
import '../services/attendance_service.dart';
import 'glass_card.dart';

/// Profile summary for the home screen, including today's check-in status.
class UserDetailCard extends StatelessWidget {
  const UserDetailCard({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AttendanceService.instance,
      builder: (context, _) => _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    final theme = ShadTheme.of(context);
    final attendance = AttendanceService.instance;
    final checkedIn = attendance.isCheckedIn;

    return GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      user.initials,
                      style: theme.textTheme.small.copyWith(
                        color: theme.colorScheme.primaryForeground,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${user.nickname}',
                          style: theme.textTheme.h4,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.role,
                          style: theme.textTheme.muted,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _CardActionButton(
                      icon: LucideIcons.idCard,
                      label: 'Employee Card',
                      onTap: () => context.pushNamed('employeeCard'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _CardActionButton(
                    icon: LucideIcons.settings,
                    onTap: () => context.pushNamed('settings'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: checkedIn
                      ? theme.colorScheme.primary.withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: checkedIn
                        ? theme.colorScheme.primary.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      checkedIn ? LucideIcons.circleCheck : LucideIcons.circle,
                      size: 18,
                      color: checkedIn
                          ? theme.colorScheme.primary
                          : theme.colorScheme.mutedForeground,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        checkedIn
                            ? 'Checked in'
                            : 'Not checked in today',
                        style: theme.textTheme.small,
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

class _CardActionButton extends StatelessWidget {
  const _CardActionButton({
    required this.icon,
    required this.onTap,
    this.label,
  });

  final IconData icon;
  final String? label;
  final VoidCallback onTap;

  bool get _iconOnly => label == null;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: _iconOnly
              ? Center(
                  child: Icon(
                    icon,
                    size: 18,
                    color: theme.colorScheme.mutedForeground,
                  ),
                )
              : Row(
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: theme.colorScheme.mutedForeground,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        label!,
                        style: theme.textTheme.small,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
