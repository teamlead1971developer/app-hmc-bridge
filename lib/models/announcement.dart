class AnnouncementCategory {
  const AnnouncementCategory._(this.label);

  final String label;

  static const all = AnnouncementCategory._('All');
  static const hr = AnnouncementCategory._('HR');
  static const it = AnnouncementCategory._('IT');
  static const events = AnnouncementCategory._('Events');
  static const facilities = AnnouncementCategory._('Facilities');

  static const filters = [all, hr, it, events, facilities];

  bool matches(AnnouncementCategory item) =>
      this == all || this == item;
}

class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.publishedAt,
    required this.category,
    this.isUnread = false,
    this.readMinutes = 2,
    this.coverImageUrl,
    this.featured = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime publishedAt;
  final AnnouncementCategory category;
  final bool isUnread;
  final int readMinutes;
  final String? coverImageUrl;
  final bool featured;

  Announcement copyWith({bool? isUnread}) => Announcement(
        id: id,
        title: title,
        body: body,
        publishedAt: publishedAt,
        category: category,
        isUnread: isUnread ?? this.isUnread,
        readMinutes: readMinutes,
        coverImageUrl: coverImageUrl,
        featured: featured,
      );
}
