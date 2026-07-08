import 'leave_request.dart';
import 'travel_expense.dart';

enum TeamApprovalType {
  leave('Leave'),
  expense('Expense');

  const TeamApprovalType(this.label);
  final String label;
}

class TeamApproval {
  const TeamApproval({
    required this.id,
    required this.type,
    required this.employeeName,
    required this.department,
    required this.summary,
    required this.detail,
    required this.submittedAt,
    this.leaveType,
    this.startDate,
    this.endDate,
    this.expenseCategory,
    this.amount,
    this.tripTitle,
    this.leaveRequestId,
    this.expenseClaimId,
  });

  final String id;
  final TeamApprovalType type;
  final String employeeName;
  final String department;
  final String summary;
  final String detail;
  final DateTime submittedAt;
  final LeaveType? leaveType;
  final DateTime? startDate;
  final DateTime? endDate;
  final TravelExpenseCategory? expenseCategory;
  final int? amount;
  final String? tripTitle;

  /// Links to [LeaveRequest.id] when this item mirrors an employee submission.
  final String? leaveRequestId;

  /// Links to [TravelExpenseClaim.id] when this item mirrors an employee submission.
  final String? expenseClaimId;
}
