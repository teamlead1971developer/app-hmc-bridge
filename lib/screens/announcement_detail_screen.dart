import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/announcement.dart';
import '../services/announcement_service.dart';
import '../services/app_refresh_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_controls.dart';
import '../widgets/glass_refresh.dart';

void openAnnouncementDetail(BuildContext context, Announcement announcement) {
  AnnouncementService.instance.markRead(announcement.id);
  context.pushNamed(
    'announcementDetail',
    pathParameters: {'id': announcement.id},
  );
}

class AnnouncementDetailScreen extends StatefulWidget {
  const AnnouncementDetailScreen({super.key, required this.announcementId});

  final String announcementId;

  @override
  State<AnnouncementDetailScreen> createState() =>
      _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen> {
  @override
  void initState() {
    super.initState();
    AnnouncementService.instance.markRead(widget.announcementId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final announcement =
        AnnouncementService.instance.byId(widget.announcementId);

    if (announcement == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              const GlassPageHeader(title: 'Detail'),
              Expanded(
                child: GlassRefreshIndicator(
                  onRefresh: () => AppRefreshService.refresh(
                    AppRefreshScope.announcements,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: kGlassRefreshPhysics,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Center(
                            child: Text(
                              'Announcement not found.',
                              style: theme.textTheme.muted,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            const GlassPageHeader(title: 'Detail'),
            Expanded(
              child: GlassRefreshIndicator(
                onRefresh: () => AppRefreshService.refresh(
                  AppRefreshScope.announcements,
                ),
                child: SingleChildScrollView(
                  physics: kGlassRefreshPhysics,
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              announcement.title,
                              style: theme.textTheme.large,
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              formatAnnouncementDate(announcement.publishedAt),
                              style: theme.textTheme.muted,
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              announcement.body,
                              style: theme.textTheme.muted.copyWith(height: 1.5),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
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
