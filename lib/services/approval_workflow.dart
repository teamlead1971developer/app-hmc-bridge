import '../models/leave_request.dart';
import '../models/travel_expense.dart';
import 'leave_service.dart';
import 'manager_approval_service.dart';
import 'travel_expense_service.dart';
import 'user_service.dart';

/// Coordinates employee submissions with the manager approval queue.
class ApprovalWorkflow {
  ApprovalWorkflow._();

  /// Ensures seeded pending leave/expense items appear in the manager queue.
  static Future<void> syncPendingQueue() async {
    final user = UserService.instance.currentUser ??
        await UserService.instance.fetchCurrentUser();
    final manager = ManagerApprovalService.instance;

    for (final request in LeaveService.instance.all) {
      if (request.status == LeaveStatus.pending) {
        manager.enqueueFromLeave(request, user);
      }
    }
    for (final claim in TravelExpenseService.instance.all) {
      if (claim.status == TravelExpenseStatus.pending) {
        manager.enqueueFromExpense(claim, user);
      }
    }
  }

  static Future<LeaveRequest> submitLeave({
    required LeaveType type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    final user = UserService.instance.currentUser ??
        await UserService.instance.fetchCurrentUser();
    final request = LeaveService.instance.submit(
      type: type,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
    );
    ManagerApprovalService.instance.enqueueFromLeave(request, user);
    return request;
  }

  static Future<TravelExpenseClaim> submitExpense({
    required TravelExpenseCategory category,
    required String tripTitle,
    required DateTime expenseDate,
    required int amount,
    required String description,
    String? receiptPath,
  }) async {
    final user = UserService.instance.currentUser ??
        await UserService.instance.fetchCurrentUser();
    final claim = TravelExpenseService.instance.submit(
      category: category,
      tripTitle: tripTitle,
      expenseDate: expenseDate,
      amount: amount,
      description: description,
      receiptPath: receiptPath,
    );
    ManagerApprovalService.instance.enqueueFromExpense(claim, user);
    return claim;
  }
}
