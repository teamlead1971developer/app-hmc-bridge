import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';
import '../models/announcement.dart';
import '../screens/announcement_detail_screen.dart';
import '../services/announcement_service.dart';
import '../services/app_refresh_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_controls.dart';
import '../widgets/glass_refresh.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final _search = TextEditingController();
  AnnouncementCategory _category = AnnouncementCategory.all;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Announcement> get _filtered =>
      AnnouncementService.instance.search(_search.text, category: _category);

  Announcement? get _featured {
    final items = _filtered;
    for (final item in items) {
      if (item.featured) return item;
    }
    return items.isEmpty ? null : items.first;
  }

  List<Announcement> get _compact {
    final featured = _featured;
    return _filtered.where((a) => a.id != featured?.id).toList();
  }

  @override
  Widget build(BuildContext context) {
    final featured = _featured;
    final compact = _compact;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const GlassPageHeader(title: 'Announcements'),
            Expanded(
              child: GlassRefreshIndicator(
                onRefresh: () => AppRefreshService.refresh(
                  AppRefreshScope.announcements,
                ),
                child: SingleChildScrollView(
                  physics: kGlassRefreshPhysics,
                  padding: const EdgeInsets.fromLTRB(22, 14, 22, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      radius: 14,
                      blur: 20,
                      child: Row(
                        children: [
                          Icon(LucideIcons.search, size: 16, color: kTextFaint),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _search,
                              onChanged: (_) => setState(() {}),
                              style: bodyStyle(size: 14),
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: 'Search announcements',
                                hintStyle: bodyStyle(size: 14, color: kTextFaint),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final cat in AnnouncementCategory.filters) ...[
                            FilterChipButton(
                              label: cat.label,
                              selected: _category == cat,
                              onTap: () => setState(() => _category = cat),
                            ),
                            if (cat != AnnouncementCategory.filters.last)
                              const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (featured != null) ...[
                      _FeaturedCard(
                        announcement: featured,
                        onTap: () => openAnnouncementDetail(context, featured),
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (compact.isEmpty && featured == null)
                      GlassCard(
                        child: Text(
                          'No announcements match your search.',
                          style: bodyStyle(size: 14, color: kTextMuted),
                        ),
                      )
                    else
                      for (final item in compact) ...[
                        _CompactRow(
                          announcement: item,
                          onTap: () => openAnnouncementDetail(context, item),
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
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.announcement, required this.onTap});

  final Announcement announcement;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: EdgeInsets.zero,
        radius: 20,
        blur: 24,
        clipChild: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CoverImage(url: announcement.coverImageUrl),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CategoryChip(
                    label: announcement.category.label,
                    accent: announcement.isUnread ||
                        announcement.category == AnnouncementCategory.events,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    announcement.title,
                    style: displayStyle(size: 16, weight: 600, height: 1.35),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    announcement.body,
                    style: bodyStyle(size: 12, color: kTextMuted, height: 1.5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatAnnouncementMeta(announcement),
                    style: bodyStyle(size: 11, color: kTextFaint),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url != null) {
      return Image.network(url!, height: 130, fit: BoxFit.cover);
    }
    return Container(
      height: 130,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFF17171A),
      ),
      child: CustomPaint(
        size: const Size(double.infinity, 130),
        painter: _StripePainter(),
        child: Center(
          child: Text(
            'event cover photo',
            style: monoStyle(size: 10, color: kTextFaint),
          ),
        ),
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const stripe = 10.0;
    final paint1 = Paint()..color = Colors.white.withValues(alpha: 0.07);
    final paint2 = Paint()..color = Colors.white.withValues(alpha: 0.02);
    for (var x = -size.height; x < size.width + size.height; x += stripe * 2) {
      canvas.drawRect(Rect.fromLTWH(x, 0, stripe, size.height), paint1);
      canvas.drawRect(Rect.fromLTWH(x + stripe, 0, stripe, size.height), paint2);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CompactRow extends StatelessWidget {
  const _CompactRow({required this.announcement, required this.onTap});

  final Announcement announcement;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        radius: 16,
        blur: 24,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    announcement.title,
                    style: bodyStyle(size: 13, weight: 500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${announcement.category.label} · ${formatRelativeTime(announcement.publishedAt)}',
                    style: bodyStyle(size: 11, color: kTextFaint),
                  ),
                ],
              ),
            ),
            if (announcement.isUnread)
              Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.only(right: 8),
                decoration: const BoxDecoration(
                  color: kBrandColor,
                  shape: BoxShape.circle,
                ),
              ),
            Icon(LucideIcons.chevronRight, size: 14, color: kTextFaint),
          ],
        ),
      ),
    );
  }
}
