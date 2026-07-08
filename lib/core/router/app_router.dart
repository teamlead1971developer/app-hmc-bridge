import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../screens/announcement_detail_screen.dart';
import '../../screens/announcements_screen.dart';
import '../../screens/auth_screen.dart';
import '../../screens/change_pin_screen.dart';
import '../../screens/checkin_screen.dart';
import '../../screens/employee_card_screen.dart';
import '../../screens/help_desk_ticket_detail_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/leave_request_screen.dart';
import '../../screens/checkin_log_screen.dart';
import '../../screens/debug_menu_screen.dart';
import '../../screens/directory_screen.dart';
import '../../screens/help_desk_screen.dart';
import '../../screens/manager_approvals_screen.dart';
import '../../screens/onboarding_screen.dart';
import '../../screens/payslip_detail_screen.dart';
import '../../screens/payslips_screen.dart';
import '../../screens/pin_setup_screen.dart';
import '../../screens/pin_unlock_screen.dart';
import '../../screens/profile_screen.dart';
import '../../screens/notifications_screen.dart';
import '../../screens/team_calendar_screen.dart';
import '../../screens/leave_request_detail_screen.dart';
import '../../screens/travel_expense_detail_screen.dart';
import '../../screens/travel_expense_screen.dart';
import '../../screens/joy_coupon_detail_screen.dart';
import '../../screens/joy_coupons_screen.dart';
import '../../screens/joy_point_history_screen.dart';
import '../../screens/joy_privilege_detail_screen.dart';
import '../../screens/joy_privileges_screen.dart';
import '../../screens/the_joy_screen.dart';
import '../../screens/security_screen.dart';
import '../../screens/settings_screen.dart';
import '../../services/app_preferences_service.dart';
import '../../services/auth_session_service.dart';

CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeOut).animate(animation),
        child: child,
      );
    },
  );
}

CustomTransitionPage<void> _homePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final enter = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      );
      final pushed = CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.easeInOutCubic,
        reverseCurve: Curves.easeInOutCubic,
      );

      return FadeTransition(
        opacity: enter,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(-1, 0),
          ).animate(pushed),
          child: child,
        ),
      );
    },
  );
}

CustomTransitionPage<void> _slidePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final enter = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
        reverseCurve: Curves.easeInOutCubic,
      );

      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(enter),
        child: child,
      );
    },
  );
}

String? _authRedirect(GoRouterState state) {
  final session = AuthSessionService.instance;
  final prefs = AppPreferencesService.instance;
  if (!session.isInitialized || !prefs.isInitialized) return null;

  final path = state.matchedLocation;
  final onAuth = path == '/';
  final onPinSetup = path == '/pin-setup';
  final onPinUnlock = path == '/pin-unlock';
  final onOnboarding = path == '/onboarding';

  if (!session.isSignedIn) {
    return onAuth ? null : '/';
  }

  if (session.needsPinSetup) {
    return onPinSetup ? null : '/pin-setup';
  }

  if (session.needsPinUnlock) {
    return onPinUnlock ? null : '/pin-unlock';
  }

  if (!prefs.onboardingCompleted) {
    return onOnboarding ? null : '/onboarding';
  }

  if (onAuth || onPinSetup || onPinUnlock || onOnboarding) {
    return '/home';
  }

  return null;
}

final _routerRefresh = Listenable.merge([
  AuthSessionService.instance,
  AppPreferencesService.instance,
]);

final appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: _routerRefresh,
  redirect: (context, state) => _authRedirect(state),
  routes: [
    GoRoute(
      path: '/',
      name: 'auth',
      pageBuilder: (context, state) => _fadePage(state, const AuthScreen()),
    ),
    GoRoute(
      path: '/pin-setup',
      name: 'pinSetup',
      pageBuilder: (context, state) => _fadePage(state, const PinSetupScreen()),
    ),
    GoRoute(
      path: '/pin-unlock',
      name: 'pinUnlock',
      pageBuilder: (context, state) => _fadePage(state, const PinUnlockScreen()),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      pageBuilder: (context, state) => _fadePage(state, const OnboardingScreen()),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      pageBuilder: (context, state) => _homePage(state, const HomeScreen()),
      routes: [
        GoRoute(
          path: 'check-in',
          name: 'checkin',
          pageBuilder: (context, state) =>
              _slidePage(state, const CheckInScreen()),
        ),
        GoRoute(
          path: 'announcements',
          name: 'announcements',
          pageBuilder: (context, state) =>
              _slidePage(state, const AnnouncementsScreen()),
        ),
        GoRoute(
          path: 'announcement/:id',
          name: 'announcementDetail',
          pageBuilder: (context, state) => _slidePage(
            state,
            AnnouncementDetailScreen(
              announcementId: state.pathParameters['id']!,
            ),
          ),
        ),
        GoRoute(
          path: 'settings',
          name: 'settings',
          pageBuilder: (context, state) =>
              _slidePage(state, const SettingsScreen()),
        ),
        GoRoute(
          path: 'security',
          name: 'security',
          pageBuilder: (context, state) =>
              _slidePage(state, const SecurityScreen()),
        ),
        GoRoute(
          path: 'employee-card',
          name: 'employeeCard',
          pageBuilder: (context, state) =>
              _slidePage(state, const EmployeeCardScreen()),
        ),
        GoRoute(
          path: 'check-in-log',
          name: 'checkInLog',
          pageBuilder: (context, state) =>
              _slidePage(state, const CheckInLogScreen()),
        ),
        GoRoute(
          path: 'debug',
          name: 'debug',
          pageBuilder: (context, state) =>
              _slidePage(state, const DebugMenuScreen()),
        ),
        GoRoute(
          path: 'directory',
          name: 'directory',
          pageBuilder: (context, state) =>
              _slidePage(state, const DirectoryScreen()),
        ),
        GoRoute(
          path: 'leave-request',
          name: 'leaveRequest',
          pageBuilder: (context, state) =>
              _slidePage(state, const LeaveRequestScreen()),
        ),
        GoRoute(
          path: 'leave-request/:id',
          name: 'leaveRequestDetail',
          pageBuilder: (context, state) => _slidePage(
            state,
            LeaveRequestDetailScreen(
              requestId: state.pathParameters['id']!,
            ),
          ),
        ),
        GoRoute(
          path: 'team-calendar',
          name: 'teamCalendar',
          pageBuilder: (context, state) =>
              _slidePage(state, const TeamCalendarScreen()),
        ),
        GoRoute(
          path: 'notifications',
          name: 'notifications',
          pageBuilder: (context, state) =>
              _slidePage(state, const NotificationsScreen()),
        ),
        GoRoute(
          path: 'travel-expense',
          name: 'travelExpense',
          pageBuilder: (context, state) =>
              _slidePage(state, const TravelExpenseScreen()),
        ),
        GoRoute(
          path: 'travel-expense/:id',
          name: 'travelExpenseDetail',
          pageBuilder: (context, state) => _slidePage(
            state,
            TravelExpenseDetailScreen(
              claimId: state.pathParameters['id']!,
            ),
          ),
        ),
        GoRoute(
          path: 'payslips',
          name: 'payslips',
          pageBuilder: (context, state) =>
              _slidePage(state, const PayslipsScreen()),
        ),
        GoRoute(
          path: 'payslip/:id',
          name: 'payslipDetail',
          pageBuilder: (context, state) => _slidePage(
            state,
            PayslipDetailScreen(
              payslipId: state.pathParameters['id']!,
            ),
          ),
        ),
        GoRoute(
          path: 'profile',
          name: 'profile',
          pageBuilder: (context, state) =>
              _slidePage(state, const ProfileScreen()),
        ),
        GoRoute(
          path: 'change-pin',
          name: 'changePin',
          pageBuilder: (context, state) =>
              _slidePage(state, const ChangePinScreen()),
        ),
        GoRoute(
          path: 'help-desk',
          name: 'helpDesk',
          pageBuilder: (context, state) =>
              _slidePage(state, const HelpDeskScreen()),
        ),
        GoRoute(
          path: 'help-desk/:id',
          name: 'helpTicketDetail',
          pageBuilder: (context, state) => _slidePage(
            state,
            HelpDeskTicketDetailScreen(
              ticketId: state.pathParameters['id']!,
            ),
          ),
        ),
        GoRoute(
          path: 'manager-approvals',
          name: 'managerApprovals',
          pageBuilder: (context, state) =>
              _slidePage(state, const ManagerApprovalsScreen()),
        ),
        GoRoute(
          path: 'the-joy',
          name: 'theJoy',
          pageBuilder: (context, state) =>
              _slidePage(state, const TheJoyScreen()),
        ),
        GoRoute(
          path: 'the-joy/point-history',
          name: 'joyPointHistory',
          pageBuilder: (context, state) =>
              _slidePage(state, const JoyPointHistoryScreen()),
        ),
        GoRoute(
          path: 'the-joy/privileges',
          name: 'joyPrivileges',
          pageBuilder: (context, state) =>
              _slidePage(state, const JoyPrivilegesScreen()),
        ),
        GoRoute(
          path: 'the-joy/privileges/:id',
          name: 'joyPrivilegeDetail',
          pageBuilder: (context, state) => _slidePage(
            state,
            JoyPrivilegeDetailScreen(
              privilegeId: state.pathParameters['id']!,
            ),
          ),
        ),
        GoRoute(
          path: 'the-joy/coupons',
          name: 'joyCoupons',
          pageBuilder: (context, state) =>
              _slidePage(state, const JoyCouponsScreen()),
        ),
        GoRoute(
          path: 'the-joy/coupons/:id',
          name: 'joyCouponDetail',
          pageBuilder: (context, state) => _slidePage(
            state,
            JoyCouponDetailScreen(
              couponId: state.pathParameters['id']!,
            ),
          ),
        ),
      ],
    ),
  ],
);
