import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';
import '../models/leave_request.dart';
import '../models/team_absence.dart';
import '../services/app_refresh_service.dart';
import '../services/leave_service.dart';
import '../services/team_calendar_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_controls.dart';
import '../widgets/glass_refresh.dart';

class TeamCalendarScreen extends StatefulWidget {
  const TeamCalendarScreen({super.key});

  @override
  State<TeamCalendarScreen> createState() => _TeamCalendarScreenState();
}

class _TeamCalendarScreenState extends State<TeamCalendarScreen> {
  final _calendar = TeamCalendarService.instance;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final outToday = _calendar.outOn(_selectedDay);
    final available = _calendar.availableCountOn(_selectedDay);
    final percent = _calendar.availabilityPercentOn(_selectedDay);
    final week = _calendar.weekAround(_selectedDay);
    final upcoming = _calendar.upcoming(from: _selectedDay);
    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const GlassPageHeader(title: "Who's out"),
            Expanded(
              child: GlassRefreshIndicator(
                onRefresh: () => AppRefreshService.refresh(
                  AppRefreshScope.teamCalendar,
                ),
                child: SingleChildScrollView(
                  physics: kGlassRefreshPhysics,
                  padding: const EdgeInsets.fromLTRB(22, 14, 22, 32),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GlassCard(
                      radius: 22,
                      blur: 26,
                      shadows: kHeroCardShadows,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Team availability',
                            style: bodyStyle(size: 12, color: kTextMuted),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$available of ${TeamCalendarService.teamSize} available',
                            style: displayStyle(size: 28, weight: 600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$percent% capacity · ${outToday.length} out',
                            style: bodyStyle(size: 11, color: kTextFaint),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final day in week) ...[
                            _DayChip(
                              day: day,
                              selected: isSameCalendarDay(day, _selectedDay),
                              isToday: isSameCalendarDay(day, todayDay),
                              outCount: _calendar.outCountOn(day),
                              onTap: () => setState(() => _selectedDay = day),
                            ),
                            if (day != week.last) const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    GlassSectionHeader(
                      isSameCalendarDay(_selectedDay, todayDay)
                          ? 'Out today'
                          : 'Out on ${formatLeaveDate(_selectedDay)}',
                      trailing: Text(
                        '${outToday.length} people',
                        style: bodyStyle(size: 12, color: kTextMuted),
                      ),
                    ),
                    if (outToday.isEmpty)
                      GlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Everyone on your team is available this day.',
                          style: bodyStyle(size: 14, color: kTextMuted),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      for (final absence in outToday) ...[
                        _AbsenceRow(absence: absence, selectedDay: _selectedDay),
                        const SizedBox(height: 10),
                      ],
                    if (upcoming.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      GlassSectionHeader(
                        'Coming up',
                        trailing: Text(
                          'Next 14 days',
                          style: bodyStyle(size: 12, color: kTextMuted),
                        ),
                      ),
                      for (final absence in upcoming) ...[
                        _UpcomingRow(absence: absence),
                        const SizedBox(height: 10),
                      ],
                    ],
                    const SizedBox(height: 8),
                    BridgeGlassButton(
                      label: 'Submit leave request',
                      icon: LucideIcons.calendarMinus,
                      onPressed: () => context.pushNamed('leaveRequest'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.info, size: 12, color: kTextFaint),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Shows approved team leave only. Manage your own requests in Leave request.',
                            style: bodyStyle(size: 11, color: kTextFaint),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.day,
    required this.selected,
    required this.isToday,
    required this.outCount,
    required this.onTap,
  });

  final DateTime day;
  final bool selected;
  final bool isToday;
  final int outCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 52,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? kActiveFill : kGlassFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? kActiveBorder : kGlassBorder),
        ),
        child: Column(
          children: [
            Text(
              formatCalendarDay(day),
              style: bodyStyle(
                size: 10,
                weight: 600,
                color: selected ? kText : kTextMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formatCalendarDate(day),
              style: displayStyle(
                size: 16,
                weight: 600,
                color: selected ? kText : kTextMuted,
              ),
            ),
            if (isToday) ...[
              const SizedBox(height: 4),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: kRedLight,
                ),
              ),
            ] else if (outCount > 0) ...[
              const SizedBox(height: 4),
              Text(
                '$outCount',
                style: bodyStyle(size: 10, color: kRedLight, weight: 600),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AbsenceRow extends StatelessWidget {
  const _AbsenceRow({
    required this.absence,
    required this.selectedDay,
  });

  final TeamAbsence absence;
  final DateTime selectedDay;

  static IconData _icon(LeaveType type) => switch (type) {
        LeaveType.annual => LucideIcons.calendarDays,
        LeaveType.sick => LucideIcons.heartPulse,
        LeaveType.personal => LucideIcons.user,
        LeaveType.unpaid => LucideIcons.calendarOff,
      };

  @override
  Widget build(BuildContext context) {
    final endsToday = isSameCalendarDay(absence.endDate, selectedDay);
    final returnsLabel = endsToday
        ? 'Returns tomorrow'
        : 'Until ${formatLeaveDate(absence.endDate)}';

    return GlassCard(
      padding: const EdgeInsets.all(16),
      radius: 16,
      blur: 24,
      child: Row(
        children: [
          AvatarBadge(initials: absence.initials, size: 40, radius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  absence.memberName,
                  style: bodyStyle(size: 14, weight: 500),
                ),
                const SizedBox(height: 3),
                Text(
                  '${absence.department} · ${absence.leaveType.label}',
                  style: bodyStyle(size: 12, color: kTextMuted),
                ),
                const SizedBox(height: 3),
                Text(
                  returnsLabel,
                  style: monoStyle(size: 11, color: kTextFaint),
                ),
              ],
            ),
          ),
          RedTintIconTile(icon: _icon(absence.leaveType), size: 34),
        ],
      ),
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  const _UpcomingRow({required this.absence});

  final TeamAbsence absence;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      radius: 14,
      blur: 20,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  absence.memberName,
                  style: bodyStyle(size: 13, weight: 500),
                ),
                const SizedBox(height: 3),
                Text(
                  formatLeaveRange(absence.startDate, absence.endDate),
                  style: monoStyle(size: 12, color: kTextFaint),
                ),
              ],
            ),
          ),
          CategoryChip(
            label: absence.leaveType.label,
            accent: false,
            uppercase: false,
          ),
        ],
      ),
    );
  }
}
