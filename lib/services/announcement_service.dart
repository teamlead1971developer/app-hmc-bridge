import 'package:flutter/foundation.dart';

import '../models/announcement.dart';

/// In-memory announcement store for the session.
// TODO: replace mock data with a real API call.
class AnnouncementService extends ChangeNotifier {
  AnnouncementService._();

  static final instance = AnnouncementService._();

  void signalRefresh() => notifyListeners();

  final List<Announcement> _announcements = [
    Announcement(
      id: '1',
      title: 'Annual company outing — Khao Yai, Aug 21–22',
      body:
          'Two days, one night. Transport and rooms covered — '
          'sign up before July 15.',
      publishedAt: DateTime(2026, 7, 1, 9, 0),
      category: AnnouncementCategory.events,
      isUnread: true,
      readMinutes: 2,
      featured: true,
    ),
    Announcement(
      id: '2',
      title: 'Q3 town hall — Friday 10:00',
      body:
          'Join leadership for quarterly updates in the main auditorium. '
          'Remote dial-in available for regional staff.',
      publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
      category: AnnouncementCategory.hr,
      isUnread: true,
      readMinutes: 2,
    ),
    Announcement(
      id: '3',
      title: 'VPN maintenance tonight 22:00 – 24:00',
      body:
          'Internal systems will be unavailable Saturday 5 July, 22:00–02:00. '
          'Plan accordingly and avoid scheduling critical work during the window.',
      publishedAt: DateTime.now().subtract(const Duration(days: 1)),
      category: AnnouncementCategory.it,
      readMinutes: 1,
    ),
    Announcement(
      id: '4',
      title: 'Fire drill — Building A',
      body:
          'A fire drill is scheduled for 10 July at 14:00. '
          'Follow evacuation routes and assemble at the front car park.',
      publishedAt: DateTime(2026, 7, 2, 11, 15),
      category: AnnouncementCategory.facilities,
      readMinutes: 2,
    ),
    Announcement(
      id: '5',
      title: 'New attendance policy effective July',
      body:
          'Starting 1 July, all remote check-ins require a proof photo. '
          'Office check-ins within 150 m of HQ remain unchanged.',
      publishedAt: DateTime(2026, 7, 1, 8, 30),
      category: AnnouncementCategory.hr,
      readMinutes: 3,
    ),
    Announcement(
      id: '6',
      title: 'Welcome new operations hires',
      body:
          'Please welcome the new operations team members joining this week. '
          'Intro sessions run daily at 10:00 in Conference Room B.',
      publishedAt: DateTime(2026, 6, 28, 9, 0),
      category: AnnouncementCategory.hr,
      readMinutes: 2,
    ),
  ];

  /// All announcements, newest first.
  List<Announcement> get all {
    final items = List<Announcement>.from(_announcements);
    items.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return items;
  }

  Announcement? byId(String id) {
    for (final item in _announcements) {
      if (item.id == id) return item;
    }
    return null;
  }

  void markRead(String id) {
    final index = _announcements.indexWhere((a) => a.id == id);
    if (index < 0 || !_announcements[index].isUnread) return;
    _announcements[index] = _announcements[index].copyWith(isUnread: false);
    notifyListeners();
  }

  void markAllRead() {
    var changed = false;
    for (var i = 0; i < _announcements.length; i++) {
      if (_announcements[i].isUnread) {
        _announcements[i] = _announcements[i].copyWith(isUnread: false);
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  Announcement? get featured {
    for (final item in all) {
      if (item.featured) return item;
    }
    return all.isEmpty ? null : all.first;
  }

  List<Announcement> search(String query, {AnnouncementCategory? category}) {
    final q = query.trim().toLowerCase();
    return all.where((item) {
      final cat = category ?? AnnouncementCategory.all;
      if (!cat.matches(item.category)) return false;
      if (q.isEmpty) return true;
      return item.title.toLowerCase().contains(q) ||
          item.body.toLowerCase().contains(q);
    }).toList();
  }

  /// Announcements published on [date], or all when [date] is null.
  List<Announcement> forDate(DateTime? date) {
    final items = all;
    if (date == null) return items;
    return items
        .where(
          (item) =>
              item.publishedAt.year == date.year &&
              item.publishedAt.month == date.month &&
              item.publishedAt.day == date.day,
        )
        .toList();
  }
}

String formatRelativeTime(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);
  if (diff.inMinutes < 60) {
    final m = diff.inMinutes.clamp(1, 59);
    return '$m ${m == 1 ? 'minute' : 'minutes'} ago';
  }
  if (diff.inHours < 24) {
    final h = diff.inHours;
    return '$h ${h == 1 ? 'hour' : 'hours'} ago';
  }
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays} days ago';
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}';
}

String formatAnnouncementMeta(Announcement item) =>
    '${formatShortDate(item.publishedAt)} · ${item.readMinutes} min read';

String formatAnnouncementDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/'
    '${date.year}';

String formatShortDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}';
}
