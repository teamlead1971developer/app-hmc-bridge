import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';
import '../models/app_notification.dart';
import '../services/app_refresh_service.dart';
import '../services/notification_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_controls.dart';
import '../widgets/glass_refresh.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _notifications = NotificationService.instance;
  NotificationType? _typeFilter;

  void _openNotification(AppNotification item) {
    _notifications.markRead(item.id);
    final route = item.routeName;
    if (route == null) return;
    final params = item.routePathParameters;
    if (params != null && params.isNotEmpty) {
      context.pushNamed(route, pathParameters: params);
    } else {
      context.pushNamed(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _notifications,
      builder: (context, _) {
        final items = _notifications.filtered(type: _typeFilter);
        final unread = _notifications.unreadCount;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 14),
                  child: Row(
                    children: [
                      GlassIconButton(
                        icon: LucideIcons.chevronLeft,
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.goNamed('home');
                          }
                        },
                        size: 36,
                        circular: true,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Notifications',
                          style: displayStyle(size: 17, weight: 600),
                        ),
                      ),
                      if (unread > 0)
                        GestureDetector(
                          onTap: _notifications.markAllRead,
                          child: Text(
                            'Mark all read',
                            style: bodyStyle(size: 12, color: kRedLight),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: GlassRefreshIndicator(
                    onRefresh: () => AppRefreshService.refresh(
                      AppRefreshScope.notifications,
                    ),
                    child: SingleChildScrollView(
                      physics: kGlassRefreshPhysics,
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (unread > 0)
                          GlassCard(
                            radius: 18,
                            blur: 24,
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                RedTintIconTile(
                                  icon: LucideIcons.bell,
                                  size: 34,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '$unread unread',
                                    style: bodyStyle(size: 14, weight: 500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (unread > 0) const SizedBox(height: 14),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              FilterChipButton(
                                label: NotificationService.allTypes,
                                selected: _typeFilter == null,
                                onTap: () => setState(() => _typeFilter = null),
                              ),
                              const SizedBox(width: 8),
                              for (final type in NotificationType.values) ...[
                                FilterChipButton(
                                  label: type.label,
                                  selected: _typeFilter == type,
                                  onTap: () => setState(() => _typeFilter = type),
                                ),
                                if (type != NotificationType.values.last)
                                  const SizedBox(width: 8),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        GlassSectionHeader(
                          'Inbox',
                          trailing: Text(
                            '${items.length} total',
                            style: bodyStyle(size: 12, color: kTextMuted),
                          ),
                        ),
                        if (items.isEmpty)
                          GlassCard(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'No notifications in this filter.',
                              style: bodyStyle(size: 14, color: kTextMuted),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          for (final item in items) ...[
                            _NotificationRow(
                              item: item,
                              onTap: () => _openNotification(item),
                            ),
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
                                'Approvals, pay, and announcements appear here when published.',
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

class _NotificationRow extends StatefulWidget {
  const _NotificationRow({
    required this.item,
    required this.onTap,
  });

  final AppNotification item;
  final VoidCallback onTap;

  @override
  State<_NotificationRow> createState() => _NotificationRowState();
}

class _NotificationRowState extends State<_NotificationRow> {
  bool _pressed = false;

  static IconData _icon(NotificationType type) => switch (type) {
        NotificationType.approval => LucideIcons.circleCheck,
        NotificationType.announcement => LucideIcons.megaphone,
        NotificationType.payslip => LucideIcons.banknote,
        NotificationType.attendance => LucideIcons.fingerprint,
        NotificationType.system => LucideIcons.server,
      };

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

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
          padding: const EdgeInsets.all(16),
          radius: 16,
          blur: 24,
          borderColor: item.isRead ? kGlassBorder : kGlassBorderHero,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RedTintIconTile(icon: _icon(item.type), size: 34),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: bodyStyle(
                              size: 14,
                              weight: item.isRead ? 500 : 600,
                            ),
                          ),
                        ),
                        if (!item.isRead)
                          Container(
                            width: 7,
                            height: 7,
                            margin: const EdgeInsets.only(left: 8, top: 4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: kRedLight,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.body,
                      style: bodyStyle(
                        size: 12,
                        color: kTextMuted,
                        height: 1.45,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CategoryChip(
                          label: item.type.label,
                          accent: !item.isRead,
                          uppercase: false,
                        ),
                        const Spacer(),
                        Text(
                          formatNotificationTime(item.createdAt),
                          style: bodyStyle(size: 11, color: kTextFaint),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (item.routeName != null) ...[
                const SizedBox(width: 4),
                Icon(LucideIcons.chevronRight, size: 16, color: kTextFaint),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
