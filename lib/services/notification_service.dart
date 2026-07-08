import 'package:flutter/foundation.dart';

import '../models/announcement.dart';
import '../models/app_notification.dart';
import '../models/leave_request.dart';
import '../models/travel_expense.dart';
import 'app_preferences_service.dart';
import 'announcement_service.dart';
import 'leave_service.dart';
import 'payslip_service.dart';
import 'session_storage.dart';
import 'travel_expense_service.dart';

/// Inbox derived from announcements, payslips, and leave/expense outcomes.
/// Read state for announcements mirrors [AnnouncementService.isUnread].
class NotificationService extends ChangeNotifier {
  NotificationService._() {
    AnnouncementService.instance.addListener(_onSourcesChanged);
    LeaveService.instance.addListener(_onSourcesChanged);
    TravelExpenseService.instance.addListener(_onSourcesChanged);
    AppPreferencesService.instance.addListener(_onSourcesChanged);
  }

  static final instance = NotificationService._();

  void signalRefresh() => notifyListeners();

  static const allTypes = 'All';
  static const _readIdsKey = 'bridge_notification_read_ids';
  static const _announcementPrefix = 'announcement:';
  static const _payslipPrefix = 'payslip:';
  static const _leavePrefix = 'leave:';
  static const _expensePrefix = 'expense:';

  final Set<String> _readIds = {};
  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;
    try {
      final storage = await SessionStorageProvider.resolve();
      final raw = await storage.read(_readIdsKey);
      if (raw != null && raw.isNotEmpty) {
        _readIds.addAll(
          raw.split(',').where((id) => id.trim().isNotEmpty),
        );
      }
    } catch (e, stack) {
      debugPrint('NotificationService.init failed: $e\n$stack');
    }
    _initialized = true;
    notifyListeners();
  }

  void _onSourcesChanged() => notifyListeners();

  List<AppNotification> get all {
    final prefs = AppPreferencesService.instance;
    final items = <AppNotification>[
      if (prefs.notifyAnnouncements) ..._fromAnnouncements(),
      if (prefs.notifyPayslip) ..._fromPayslips(),
      if (prefs.notifyApprovals) ...[
        ..._fromLeave(),
        ..._fromExpenses(),
      ],
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  int get unreadCount => all.where((n) => !n.isRead).length;

  List<AppNotification> filtered({NotificationType? type}) {
    if (type == null) return all;
    return all.where((n) => n.type == type).toList();
  }

  void markRead(String id) {
    if (id.startsWith(_announcementPrefix)) {
      AnnouncementService.instance.markRead(
        id.substring(_announcementPrefix.length),
      );
      return;
    }
    if (_readIds.add(id)) {
      notifyListeners();
      _persistReadIds();
    }
  }

  void markAllRead() {
    AnnouncementService.instance.markAllRead();
    var changed = false;
    for (final item in all) {
      if (!item.id.startsWith(_announcementPrefix) && _readIds.add(item.id)) {
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
      _persistReadIds();
    }
  }

  Future<void> _persistReadIds() async {
    try {
      final storage = await SessionStorageProvider.resolve();
      await storage.write(_readIdsKey, _readIds.join(','));
    } catch (e, stack) {
      debugPrint('NotificationService._persistReadIds failed: $e\n$stack');
    }
  }

  List<AppNotification> _fromAnnouncements() {
    return AnnouncementService.instance.all.map((announcement) {
      return AppNotification(
        id: '$_announcementPrefix${announcement.id}',
        type: _announcementType(announcement.category),
        title: announcement.title,
        body: announcement.body,
        createdAt: announcement.publishedAt,
        isRead: !announcement.isUnread,
        routeName: 'announcementDetail',
        routePathParameters: {'id': announcement.id},
      );
    }).toList();
  }

  List<AppNotification> _fromPayslips() {
    return PayslipService.instance.all.map((slip) {
      return AppNotification(
        id: '$_payslipPrefix${slip.id}',
        type: NotificationType.payslip,
        title: '${slip.periodLabel} payslip ready',
        body: 'Your ${slip.periodLabel} payslip is available to view and download.',
        createdAt: slip.payDate,
        isRead: _readIds.contains('$_payslipPrefix${slip.id}'),
        routeName: 'payslipDetail',
        routePathParameters: {'id': slip.id},
      );
    }).toList();
  }

  List<AppNotification> _fromLeave() {
    return LeaveService.instance.all
        .where((request) => request.status != LeaveStatus.pending)
        .map((request) {
      final id = '$_leavePrefix${request.id}';
      final (title, body) = _leaveCopy(request);
      return AppNotification(
        id: id,
        type: NotificationType.approval,
        title: title,
        body: body,
        createdAt: request.statusUpdatedAt,
        isRead: _readIds.contains(id),
        routeName: 'leaveRequestDetail',
        routePathParameters: {'id': request.id},
      );
    }).toList();
  }

  List<AppNotification> _fromExpenses() {
    return TravelExpenseService.instance.all
        .where((claim) => claim.status != TravelExpenseStatus.pending)
        .map((claim) {
      final id = '$_expensePrefix${claim.id}';
      final (title, body) = _expenseCopy(claim);
      return AppNotification(
        id: id,
        type: NotificationType.approval,
        title: title,
        body: body,
        createdAt: claim.statusUpdatedAt,
        isRead: _readIds.contains(id),
        routeName: 'travelExpenseDetail',
        routePathParameters: {'id': claim.id},
      );
    }).toList();
  }

  static NotificationType _announcementType(AnnouncementCategory category) {
    return switch (category) {
      AnnouncementCategory.it || AnnouncementCategory.facilities =>
        NotificationType.system,
      _ => NotificationType.announcement,
    };
  }

  static (String, String) _leaveCopy(LeaveRequest request) {
    final range = formatLeaveRange(request.startDate, request.endDate);
    return switch (request.status) {
      LeaveStatus.approved => (
          'Leave request approved',
          'Your ${request.type.label.toLowerCase()} for $range was approved.',
        ),
      LeaveStatus.rejected => (
          'Leave request declined',
          'Your ${request.type.label.toLowerCase()} for $range was not approved.',
        ),
      LeaveStatus.pending => ('Leave request submitted', range),
    };
  }

  static (String, String) _expenseCopy(TravelExpenseClaim claim) {
    final amount = formatMoney(claim.amount);
    return switch (claim.status) {
      TravelExpenseStatus.approved => (
          'Expense claim approved',
          '${claim.tripTitle} · $amount approved for reimbursement.',
        ),
      TravelExpenseStatus.rejected => (
          'Expense claim declined',
          '${claim.tripTitle} · $amount was not approved.',
        ),
      TravelExpenseStatus.paid => (
          'Expense reimbursement paid',
          '${claim.tripTitle} · $amount has been paid out.',
        ),
      TravelExpenseStatus.pending => (
          'Expense claim submitted',
          claim.tripTitle,
        ),
    };
  }
}

String formatNotificationTime(DateTime date) {
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
