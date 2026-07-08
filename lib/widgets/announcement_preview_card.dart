import 'package:flutter/material.dart';

import '../models/announcement.dart';
import '../services/announcement_service.dart';
import 'glass_card.dart';
import '../core/branding.dart';

/// Tappable announcement title and body preview.
class AnnouncementPreviewCard extends StatelessWidget {
  const AnnouncementPreviewCard({
    super.key,
    required this.announcement,
    required this.onTap,
    this.titleMaxLines = 1,
    this.bodyMaxLines = 2,
  });

  final Announcement announcement;
  final VoidCallback onTap;
  final int titleMaxLines;
  final int bodyMaxLines;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: GlassCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      announcement.title,
                      style: bodyStyle(size: 13, weight: 500),
                      maxLines: titleMaxLines,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatShortDate(announcement.publishedAt),
                    style: bodyStyle(size: 11, color: kTextFaint),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                announcement.body,
                style: bodyStyle(size: 13, color: kTextMuted),
                maxLines: bodyMaxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
