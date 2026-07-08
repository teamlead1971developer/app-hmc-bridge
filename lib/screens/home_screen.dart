import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';
import '../models/user.dart';
import '../services/app_refresh_service.dart';
import '../services/approval_workflow.dart';
import '../services/attendance_service.dart';
import '../services/debug_session_service.dart';
import '../services/notification_service.dart';
import '../services/user_service.dart';
import '../widgets/glass_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_controls.dart';
import '../widgets/glass_refresh.dart';
import '../widgets/home_announcements_row.dart';
import '../widgets/home_menu_grid.dart';

enum _Phase { loading, hello, content }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _userService = UserService.instance;
  User? _user;
  _Phase _phase = _Phase.loading;
  double _helloOpacity = 0;
  int _loadingStageIndex = 0;
  double _stageOpacity = 0;

  static const _loadingStages = [
    'Checking auth...',
    'User found.',
  ];

  @override
  void initState() {
    super.initState();
    final cached = _userService.currentUser;
    if (cached != null) {
      _user = cached;
      _phase = _Phase.content;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Home + its sub-routes share the top backdrop — no reposition on push.
        GlassBackground.position.value = GlowPosition.top;
        ApprovalWorkflow.syncPendingQueue();
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        GlassBackground.position.value = GlowPosition.center;
      });
      _runIntro();
    }
  }

  Future<void> _fadeStage(int index) async {
    if (!mounted) return;
    setState(() {
      _loadingStageIndex = index;
      _stageOpacity = 0;
    });
    await Future.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;
    setState(() => _stageOpacity = 1);
    await Future.delayed(const Duration(milliseconds: 750));
    if (!mounted) return;
    setState(() => _stageOpacity = 0);
    await Future.delayed(const Duration(milliseconds: 400));
  }

  Future<void> _runIntro() async {
    final userFuture = _userService.fetchCurrentUser();

    await _fadeStage(0);

    final user = await userFuture;
    if (!mounted) return;

    await _fadeStage(1);

    setState(() {
      _user = user;
      _phase = _Phase.hello;
      _helloOpacity = 0;
    });
    await Future.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;
    setState(() => _helloOpacity = 1);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    setState(() => _helloOpacity = 0);
    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    GlassBackground.position.value = GlowPosition.top;
    setState(() => _phase = _Phase.content);
    ApprovalWorkflow.syncPendingQueue();
  }

  Future<void> _handleRefresh() async {
    final user = await AppRefreshService.refreshHomeData();
    if (!mounted) return;
    setState(() => _user = user);
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  String _dateLine() {
    final now = DateTime.now();
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${weekdays[now.weekday - 1]}, '
        '${months[now.month - 1]} ${now.day} · '
        'Shift 09:00 – 18:00';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        child: switch (_phase) {
          _Phase.loading => Center(
            key: const ValueKey('loading'),
            child: AnimatedOpacity(
              opacity: _stageOpacity,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              child: Text(
                _loadingStages[_loadingStageIndex],
                style: monoStyle(size: 14, color: kTextMuted),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          _Phase.hello => Center(
            key: const ValueKey('hello'),
            child: AnimatedOpacity(
              opacity: _helloOpacity,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              child: Text(
                'Hello, ${_user!.firstName}',
                style: displayStyle(size: 28, weight: 600),
              ),
            ),
          ),
          _Phase.content => _HomeContent(
            key: const ValueKey('content'),
            user: _user!,
            greeting: _greeting(),
            dateLine: _dateLine(),
            onRefresh: _handleRefresh,
          ),
        },
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    super.key,
    required this.user,
    required this.greeting,
    required this.dateLine,
    required this.onRefresh,
  });

  final User user;
  final String greeting;
  final String dateLine;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GlassRefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: kGlassRefreshPhysics,
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(greeting, style: bodyStyle(size: 14, color: kTextMuted)),
                      Text(
                        user.firstName,
                        style: displayStyle(size: 28, weight: 600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ListenableBuilder(
                  listenable: NotificationService.instance,
                  builder: (context, _) {
                    final unread = NotificationService.instance.unreadCount;
                    return _NotificationBell(unreadCount: unread);
                  },
                ),
                const SizedBox(width: 10),
                GlassIconButton(
                  icon: LucideIcons.settings,
                  onPressed: () => context.pushNamed('profile'),
                  size: 40,
                  circular: true,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(dateLine, style: bodyStyle(size: 12, color: kTextFaint)),
            const SizedBox(height: 18),
            const _HeroCheckInCard(),
            const SizedBox(height: 18),
            const HomeAnnouncementsRow(),
            const SizedBox(height: 18),
            const HomeMenuGrid(),
          ],
          ),
        ),
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GlassIconButton(
          icon: LucideIcons.bell,
          onPressed: () => context.pushNamed('notifications'),
          size: 40,
          circular: true,
        ),
        if (unreadCount > 0)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: kRedGradient,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: kBaseColor, width: 2),
              ),
              child: Text(
                unreadCount > 9 ? '9+' : '$unreadCount',
                style: bodyStyle(size: 10, weight: 600, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}

class _HeroCheckInCard extends StatelessWidget {
  const _HeroCheckInCard();

  String? _checkedOutTime(DayLog today) {
    final t = today.checkOut?.time;
    if (t == null) return null;
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        AttendanceService.instance,
        DebugSessionService.instance,
      ]),
      builder: (context, _) {
        final attendance = AttendanceService.instance;
        final checkedIn = attendance.isCheckedIn;
        final canCheckOut = attendance.canCheckOutNow;
        final onShift = attendance.isOnShift;
        final dayClosed = attendance.isDayClosed;
        final today = attendance.forDate(DebugSessionService.instance.effectiveNow);
        final hasCheckInToday = today.checkIn != null;
        final hasCheckOutToday = today.checkOut != null;
        final checkedOut = dayClosed || (hasCheckOutToday && !checkedIn);
        final outTime = _checkedOutTime(today);

        final statusText = switch ((checkedOut, canCheckOut, checkedIn, hasCheckInToday, hasCheckOutToday)) {
          (true, _, _, _, _) when outTime != null => 'Checked out at $outTime',
          (true, _, _, _, true) => 'Checked out',
          (_, true, _, _, _) => 'Ready to check out',
          (_, _, true, _, _) => 'Checked in',
          (_, _, _, true, _) => 'Checked in',
          _ => 'Not checked in yet',
        };

        return GlassCard(
          radius: 22,
          blur: 26,
          borderColor: kGlassBorder,
          shadows: kHeroCardShadows,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      statusText,
                      style: displayStyle(size: 15, weight: 600),
                    ),
                  ),
                  Icon(LucideIcons.mapPin, size: 13, color: kTextFaint),
                  const SizedBox(width: 5),
                  Text(
                    'BRIDGE HQ · 12F',
                    style: bodyStyle(size: 12, color: kTextFaint),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (checkedOut || hasCheckOutToday) ...[
                BridgeGlassButton(
                  label: 'View log',
                  icon: LucideIcons.clipboardList,
                  onPressed: () => context.pushNamed('checkInLog'),
                ),
              ] else if (canCheckOut) ...[
                BridgePrimaryButton(
                  label: 'Check out',
                  icon: LucideIcons.logOut,
                  onPressed: () => context.pushNamed('checkin'),
                ),
                const SizedBox(height: 10),
                BridgeGlassButton(
                  label: 'View log',
                  icon: LucideIcons.clipboardList,
                  onPressed: () => context.pushNamed('checkInLog'),
                ),
              ] else if (onShift) ...[
                BridgeGlassButton(
                  label: 'View check-in',
                  icon: LucideIcons.fingerprint,
                  onPressed: () => context.pushNamed('checkin'),
                ),
                const SizedBox(height: 10),
                BridgeGlassButton(
                  label: 'View log',
                  icon: LucideIcons.clipboardList,
                  onPressed: () => context.pushNamed('checkInLog'),
                ),
              ] else
                BridgePrimaryButton(
                  label: 'Check in',
                  icon: LucideIcons.fingerprint,
                  onPressed: () => context.pushNamed('checkin'),
                ),
            ],
          ),
        );
      },
    );
  }
}
