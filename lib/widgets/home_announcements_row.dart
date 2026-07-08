import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/branding.dart';
import '../models/announcement.dart';
import '../screens/announcement_detail_screen.dart';
import '../services/announcement_service.dart';
import 'glass_card.dart';
import 'glass_controls.dart';

/// Home screen: two side-by-side announcement preview cards.
class HomeAnnouncementsRow extends StatelessWidget {
  const HomeAnnouncementsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AnnouncementService.instance,
      builder: (context, _) {
        final items = AnnouncementService.instance.all.take(2).toList();
        if (items.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassSectionHeader(
              'Announcements',
              trailing: GestureDetector(
                onTap: () => context.pushNamed('announcements'),
                child: Text(
                  'View all',
                  style: bodyStyle(size: 12, color: kTextMuted),
                ),
              ),
            ),
            Row(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(
                    child: _PreviewTile(
                      announcement: items[i],
                      onTap: () => openAnnouncementDetail(context, items[i]),
                    ),
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({required this.announcement, required this.onTap});

  final Announcement announcement;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        radius: 16,
        blur: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategoryChip(
              label: announcement.category.label,
              accent: announcement.isUnread ||
                  announcement.category == AnnouncementCategory.hr,
            ),
            const SizedBox(height: 7),
            Text(
              announcement.title,
              style: bodyStyle(size: 13, weight: 500, height: 1.35),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 7),
            Text(
              formatRelativeTime(announcement.publishedAt),
              style: bodyStyle(size: 11, color: kTextFaint),
            ),
          ],
        ),
      ),
    );
  }
}
