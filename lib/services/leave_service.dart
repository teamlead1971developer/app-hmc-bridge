import 'package:flutter/foundation.dart';

import '../models/leave_request.dart';

/// In-memory leave requests for the session.
// TODO: replace mock data with HR API integration.
class LeaveService extends ChangeNotifier {
  LeaveService._();

  static final instance = LeaveService._();

  void signalRefresh() => notifyListeners();

  static const allStatuses = 'All';

  final Map<LeaveType, int> _daysRemaining = {
    LeaveType.annual: 12,
    LeaveType.sick: 8,
    LeaveType.personal: 3,
    LeaveType.unpaid: 5,
  };

  int daysRemaining(LeaveType type) => _daysRemaining[type] ?? 0;

  Map<LeaveType, int> get daysRemainingByType => Map.unmodifiable(_daysRemaining);

  final List<LeaveRequest> _requests = [
    LeaveRequest(
      id: 'lr-1',
      type: LeaveType.annual,
      startDate: DateTime(2026, 8, 4),
      endDate: DateTime(2026, 8, 6),
      reason: 'Family trip upcountry.',
      status: LeaveStatus.pending,
      submittedAt: DateTime(2026, 7, 1, 10, 30),
    ),
    LeaveRequest(
      id: 'lr-2',
      type: LeaveType.sick,
      startDate: DateTime(2026, 5, 12),
      endDate: DateTime(2026, 5, 12),
      reason: 'Medical appointment.',
      status: LeaveStatus.approved,
      submittedAt: DateTime(2026, 5, 10, 14, 0),
      statusUpdatedAt: DateTime(2026, 5, 11, 9, 30),
      approverName: 'Pimchanok Srisai',
      decisionNote: 'Approved for medical appointment.',
    ),
    LeaveRequest(
      id: 'lr-3',
      type: LeaveType.personal,
      startDate: DateTime(2026, 3, 20),
      endDate: DateTime(2026, 3, 21),
      reason: 'Personal errands.',
      status: LeaveStatus.rejected,
      submittedAt: DateTime(2026, 3, 15, 9, 15),
      statusUpdatedAt: DateTime(2026, 3, 16, 11, 0),
      approverName: 'Pimchanok Srisai',
      decisionNote: 'Insufficient notice for personal leave on these dates.',
    ),
  ];

  List<LeaveRequest> get all {
    final items = List<LeaveRequest>.from(_requests)
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return items;
  }

  int get pendingCount => _requests.where((r) => r.status == LeaveStatus.pending).length;

  List<LeaveRequest> filtered({LeaveStatus? status}) {
    if (status == null) return all;
    return all.where((r) => r.status == status).toList();
  }

  LeaveRequest? byId(String id) {
    for (final request in _requests) {
      if (request.id == id) return request;
    }
    return null;
  }

  LeaveRequest submit({
    required LeaveType type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) {
    final days = endDate.difference(startDate).inDays + 1;
    _daysRemaining[type] = (daysRemaining(type) - days).clamp(0, 999);

    final request = LeaveRequest(
      id: 'lr-${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
      status: LeaveStatus.pending,
      submittedAt: DateTime.now(),
    );
    _requests.add(request);
    notifyListeners();
    return request;
  }

  void applyDecision(
    String id, {
    required LeaveStatus status,
    required String approverName,
    String? decisionNote,
  }) {
    final index = _requests.indexWhere((request) => request.id == id);
    if (index == -1) return;

    final current = _requests[index];
    if (current.status != LeaveStatus.pending) return;

    _requests[index] = current.copyWith(
      status: status,
      statusUpdatedAt: DateTime.now(),
      approverName: approverName,
      decisionNote: decisionNote,
    );
    notifyListeners();
  }
}

String formatLeaveDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

String formatLeaveRange(DateTime start, DateTime end) {
  if (_sameDay(start, end)) return formatLeaveDate(start);
  return '${formatLeaveDate(start)} – ${formatLeaveDate(end)}';
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
