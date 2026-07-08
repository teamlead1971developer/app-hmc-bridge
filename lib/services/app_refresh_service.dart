import '../models/user.dart';
import 'announcement_service.dart';
import 'approval_workflow.dart';
import 'attendance_service.dart';
import 'help_desk_service.dart';
import 'joy_service.dart';
import 'leave_service.dart';
import 'manager_approval_service.dart';
import 'notification_service.dart';
import 'travel_expense_service.dart';
import 'user_service.dart';

/// What to re-sync when the user pulls to refresh.
enum AppRefreshScope {
  home,
  profile,
  announcements,
  leave,
  travelExpense,
  directory,
  employeeCard,
  helpDesk,
  managerApprovals,
  teamCalendar,
  notifications,
  joy,
  attendance,
  payslips,
  general,
}

/// Central pull-to-refresh handler. Mock services re-notify listeners;
/// replace per-scope bodies with real API calls later.
class AppRefreshService {
  AppRefreshService._();

  static const _minDuration = Duration(milliseconds: 550);

  static Future<void> refresh(AppRefreshScope scope) async {
    await Future.wait([
      Future<void>.delayed(_minDuration),
      _runScope(scope),
    ]);
  }

  static Future<User> refreshProfile() async {
    await Future.wait([
      Future<void>.delayed(_minDuration),
      UserService.instance.fetchCurrentUser(forceRefresh: true),
    ]);
    return UserService.instance.currentUser!;
  }

  static Future<User> refreshHomeData() async {
    await Future.wait([
      Future<void>.delayed(_minDuration),
      UserService.instance.fetchCurrentUser(forceRefresh: true),
      ApprovalWorkflow.syncPendingQueue(),
    ]);
    return UserService.instance.currentUser!;
  }

  static Future<void> _runScope(AppRefreshScope scope) async {
    switch (scope) {
      case AppRefreshScope.home:
        await UserService.instance.fetchCurrentUser(forceRefresh: true);
        await ApprovalWorkflow.syncPendingQueue();
      case AppRefreshScope.profile:
      case AppRefreshScope.employeeCard:
        await UserService.instance.fetchCurrentUser(forceRefresh: true);
      case AppRefreshScope.announcements:
        AnnouncementService.instance.signalRefresh();
      case AppRefreshScope.leave:
        LeaveService.instance.signalRefresh();
      case AppRefreshScope.travelExpense:
        TravelExpenseService.instance.signalRefresh();
      case AppRefreshScope.directory:
      case AppRefreshScope.teamCalendar:
      case AppRefreshScope.payslips:
        break;
      case AppRefreshScope.helpDesk:
        HelpDeskService.instance.signalRefresh();
      case AppRefreshScope.managerApprovals:
        await ApprovalWorkflow.syncPendingQueue();
        ManagerApprovalService.instance.signalRefresh();
      case AppRefreshScope.notifications:
        NotificationService.instance.signalRefresh();
      case AppRefreshScope.joy:
        await JoyService.instance.refresh();
      case AppRefreshScope.attendance:
        AttendanceService.instance.signalRefresh();
      case AppRefreshScope.general:
        break;
    }
  }
}
