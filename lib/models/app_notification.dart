enum NotificationType {
  approval('Approvals'),
  announcement('Announcements'),
  payslip('Pay'),
  attendance('Attendance'),
  system('System');

  const NotificationType(this.label);
  final String label;
}

/// Unified inbox item — may deep-link to another screen.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.routeName,
    this.routePathParameters,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;

  /// GoRouter route name when the notification is tappable.
  final String? routeName;
  final Map<String, String>? routePathParameters;

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        createdAt: createdAt,
        isRead: isRead ?? this.isRead,
        routeName: routeName,
        routePathParameters: routePathParameters,
      );
}
