import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../services/announcement_service.dart';
import 'announcement_preview_card.dart';
import '../screens/announcement_detail_screen.dart';

/// Home screen carousel of announcements, newest first.
class CurrentAnnouncementCard extends StatefulWidget {
  const CurrentAnnouncementCard({super.key});

  @override
  State<CurrentAnnouncementCard> createState() =>
      _CurrentAnnouncementCardState();
}

class _CurrentAnnouncementCardState extends State<CurrentAnnouncementCard> {
  late final PageController _pageController;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int index, int count) {
    if (index < 0 || index >= count) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final announcements = AnnouncementService.instance.all;
    if (announcements.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: _Header()),
            const SizedBox(width: 8),
            const _ViewAllLink(),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 96,
          child: PageView.builder(
            controller: _pageController,
            itemCount: announcements.length,
            onPageChanged: (index) => setState(() => _index = index),
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              return AnnouncementPreviewCard(
                announcement: announcement,
                onTap: () => openAnnouncementDetail(
                  context,
                  announcement,
                ),
              );
            },
          ),
        ),
        if (announcements.length > 1) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.center,
            child: _PageDots(
              count: announcements.length,
              index: _index,
              onDotTap: (i) => _goTo(i, announcements.length),
            ),
          ),
        ],
      ],
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({
    required this.count,
    required this.index,
    required this.onDotTap,
  });

  final int count;
  final int index;
  final ValueChanged<int> onDotTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          GestureDetector(
            onTap: () => onDotTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: i == index ? 8 : 6,
              height: i == index ? 8 : 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == index
                    ? theme.colorScheme.primary
                    : Colors.white.withValues(alpha: 0.35),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Row(
      children: [
        Icon(
          LucideIcons.megaphone,
          size: 22,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Text('Announcements', style: theme.textTheme.h4),
      ],
    );
  }
}

class _ViewAllLink extends StatelessWidget {
  const _ViewAllLink();

  @override
  Widget build(BuildContext context) {
    return ShadButton.link(
      onPressed: () => context.pushNamed('announcements'),
      child: const Text('View all'),
    );
  }
}
