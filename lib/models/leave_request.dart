enum LeaveType {
  annual('Annual leave'),
  sick('Sick leave'),
  personal('Personal leave'),
  unpaid('Unpaid leave');

  const LeaveType(this.label);
  final String label;
}

enum LeaveStatus {
  pending('Pending'),
  approved('Approved'),
  rejected('Rejected');

  const LeaveStatus(this.label);
  final String label;
}

class LeaveRequest {
  const LeaveRequest({
    required this.id,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.submittedAt,
    DateTime? statusUpdatedAt,
    this.approverName,
    this.decisionNote,
  }) : statusUpdatedAt = statusUpdatedAt ?? submittedAt;

  final String id;
  final LeaveType type;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final LeaveStatus status;
  final DateTime submittedAt;

  /// When [status] last changed (approval, rejection, etc.).
  final DateTime statusUpdatedAt;

  /// Line manager or HR approver once decided.
  final String? approverName;

  /// Optional note on approval or rejection reason.
  final String? decisionNote;

  int get dayCount => endDate.difference(startDate).inDays + 1;

  LeaveRequest copyWith({
    LeaveType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? reason,
    LeaveStatus? status,
    DateTime? submittedAt,
    DateTime? statusUpdatedAt,
    String? approverName,
    String? decisionNote,
  }) {
    return LeaveRequest(
      id: id,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      statusUpdatedAt: statusUpdatedAt ?? this.statusUpdatedAt,
      approverName: approverName ?? this.approverName,
      decisionNote: decisionNote ?? this.decisionNote,
    );
  }
}
