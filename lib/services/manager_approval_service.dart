import 'package:flutter/foundation.dart';

import '../models/leave_request.dart';
import '../models/team_approval.dart';
import '../models/travel_expense.dart';
import '../models/user.dart';
import 'leave_service.dart';
import 'travel_expense_service.dart';
import 'user_service.dart';

/// Pending leave and expense items awaiting line-manager action.
// TODO: replace mock data with manager approval API.
class ManagerApprovalService extends ChangeNotifier {
  ManagerApprovalService._();

  static final instance = ManagerApprovalService._();

  void signalRefresh() => notifyListeners();

  final List<TeamApproval> _pending = [
    TeamApproval(
      id: 'ma-leave-1',
      type: TeamApprovalType.leave,
      employeeName: 'Natcha Wongsa',
      department: 'Operations',
      summary: 'Annual leave · Aug 12–14',
      detail: 'Family event in Chiang Mai.',
      submittedAt: DateTime(2026, 7, 5, 11, 20),
      leaveType: LeaveType.annual,
      startDate: DateTime(2026, 8, 12),
      endDate: DateTime(2026, 8, 14),
    ),
    TeamApproval(
      id: 'ma-leave-2',
      type: TeamApprovalType.leave,
      employeeName: 'Thanawat Meesuk',
      department: 'Human Resources',
      summary: 'Sick leave · Jul 9',
      detail: 'Doctor visit and recovery.',
      submittedAt: DateTime(2026, 7, 8, 8, 45),
      leaveType: LeaveType.sick,
      startDate: DateTime(2026, 7, 9),
      endDate: DateTime(2026, 7, 9),
    ),
    TeamApproval(
      id: 'ma-expense-1',
      type: TeamApprovalType.expense,
      employeeName: 'Kittisak Boonma',
      department: 'Information Technology',
      summary: 'Transport · client visit',
      detail: 'Taxi to client site in Bang Na.',
      submittedAt: DateTime(2026, 7, 6, 16, 30),
      expenseCategory: TravelExpenseCategory.transport,
      amount: 42000,
      tripTitle: 'Client site visit',
    ),
  ];

  List<TeamApproval> get pending {
    final items = List<TeamApproval>.from(_pending)
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return items;
  }

  int get pendingCount => _pending.length;

  TeamApproval? byId(String id) {
    for (final item in _pending) {
      if (item.id == id) return item;
    }
    return null;
  }

  void enqueueFromLeave(LeaveRequest request, User employee) {
    if (_pending.any((item) => item.leaveRequestId == request.id)) return;

    _pending.add(
      TeamApproval(
        id: 'ma-${request.id}',
        type: TeamApprovalType.leave,
        employeeName: employee.name,
        department: employee.department,
        summary: _leaveSummary(request),
        detail: request.reason,
        submittedAt: request.submittedAt,
        leaveType: request.type,
        startDate: request.startDate,
        endDate: request.endDate,
        leaveRequestId: request.id,
      ),
    );
    notifyListeners();
  }

  void enqueueFromExpense(TravelExpenseClaim claim, User employee) {
    if (_pending.any((item) => item.expenseClaimId == claim.id)) return;

    _pending.add(
      TeamApproval(
        id: 'ma-${claim.id}',
        type: TeamApprovalType.expense,
        employeeName: employee.name,
        department: employee.department,
        summary: '${claim.category.label} · ${claim.tripTitle}',
        detail: claim.description,
        submittedAt: claim.submittedAt,
        expenseCategory: claim.category,
        amount: claim.amount,
        tripTitle: claim.tripTitle,
        expenseClaimId: claim.id,
      ),
    );
    notifyListeners();
  }

  void approve(String id, {String? note}) {
    final item = byId(id);
    if (item == null) return;

    final approver = _approverName();
    if (item.leaveRequestId != null) {
      LeaveService.instance.applyDecision(
        item.leaveRequestId!,
        status: LeaveStatus.approved,
        approverName: approver,
        decisionNote: note,
      );
    } else if (item.expenseClaimId != null) {
      TravelExpenseService.instance.applyDecision(
        item.expenseClaimId!,
        status: TravelExpenseStatus.approved,
        approverName: approver,
      );
    }

    _pending.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void reject(String id, {required String reason}) {
    if (reason.trim().isEmpty) return;

    final item = byId(id);
    if (item == null) return;

    final approver = _approverName();
    if (item.leaveRequestId != null) {
      LeaveService.instance.applyDecision(
        item.leaveRequestId!,
        status: LeaveStatus.rejected,
        approverName: approver,
        decisionNote: reason.trim(),
      );
    } else if (item.expenseClaimId != null) {
      TravelExpenseService.instance.applyDecision(
        item.expenseClaimId!,
        status: TravelExpenseStatus.rejected,
        approverName: approver,
        rejectionReason: reason.trim(),
      );
    }

    _pending.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  String _approverName() =>
      UserService.instance.currentUser?.name ?? 'Line manager';

  static String _leaveSummary(LeaveRequest request) {
    final range = formatLeaveRange(request.startDate, request.endDate);
    return '${request.type.label} · $range';
  }
}
