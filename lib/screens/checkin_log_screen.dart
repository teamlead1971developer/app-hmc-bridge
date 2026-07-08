import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';
import '../models/attendance_record.dart';
import '../services/app_refresh_service.dart';
import '../services/attendance_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_controls.dart';
import '../widgets/glass_refresh.dart';

enum _LogView { week, month }

class CheckInLogScreen extends StatefulWidget {
  const CheckInLogScreen({super.key});

  @override
  State<CheckInLogScreen> createState() => _CheckInLogScreenState();
}

class _CheckInLogScreenState extends State<CheckInLogScreen> {
  final _attendance = AttendanceService.instance;
  _LogView _view = _LogView.week;
  late DateTime _selectedDay;
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _displayedMonth = DateTime(_selectedDay.year, _selectedDay.month);
  }

  DateTime get _weekStart {
    final d = _selectedDay;
    return DateTime(d.year, d.month, d.day).subtract(Duration(days: d.weekday - 1));
  }

  List<DateTime> get _weekDays =>
      List.generate(7, (i) => _weekStart.add(Duration(days: i)));

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _attendance,
      builder: (context, _) {
        final weekHours = _attendance.hoursWorkedInWeek(_selectedDay);
        final daysLogged = _attendance.daysWithRecordsInWeek(_selectedDay);
        final selectedLog = _attendance.forDate(_selectedDay);
        final dayActivities = selectedLog.activities.reversed.toList();
        final last = _attendance.lastRecord;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const GlassPageHeader(title: 'Check-in log'),
                Expanded(
                  child: GlassRefreshIndicator(
                    onRefresh: () => AppRefreshService.refresh(
                      AppRefreshScope.attendance,
                    ),
                    child: SingleChildScrollView(
                      physics: kGlassRefreshPhysics,
                      padding: const EdgeInsets.fromLTRB(22, 14, 22, 32),
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SummaryHero(
                          daysLogged: daysLogged,
                          weekHours: weekHours,
                          lastRecord: last,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            FilterChipButton(
                              label: 'Week',
                              selected: _view == _LogView.week,
                              onTap: () => setState(() => _view = _LogView.week),
                            ),
                            const SizedBox(width: 8),
                            FilterChipButton(
                              label: 'Month',
                              selected: _view == _LogView.month,
                              onTap: () => setState(() {
                                _view = _LogView.month;
                                _displayedMonth =
                                    DateTime(_selectedDay.year, _selectedDay.month);
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        if (_view == _LogView.week) ...[
                          _WeekStrip(
                            days: _weekDays,
                            selected: _selectedDay,
                            attendance: _attendance,
                            onSelect: (d) => setState(() => _selectedDay = d),
                          ),
                          const SizedBox(height: 14),
                          if (selectedLog.hasRecords)
                            _DayDetailCard(log: selectedLog)
                          else
                            GlassCard(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                'No check-in records for ${_formatDayLabel(_selectedDay)}.',
                                style: bodyStyle(size: 14, color: kTextMuted),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ] else ...[
                          _MonthCalendar(
                            month: _displayedMonth,
                            selected: _selectedDay,
                            attendance: _attendance,
                            onMonthChanged: (m) => setState(() => _displayedMonth = m),
                            onDaySelected: (d) => setState(() => _selectedDay = d),
                          ),
                          const SizedBox(height: 14),
                          if (selectedLog.hasRecords)
                            _DayDetailCard(log: selectedLog)
                          else
                            GlassCard(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                'No check-in records for ${_formatDayLabel(_selectedDay)}.',
                                style: bodyStyle(size: 14, color: kTextMuted),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                        const SizedBox(height: 18),
                        GlassSectionHeader('History · ${_formatDayShort(_selectedDay)}'),
                        if (dayActivities.isEmpty)
                          GlassCard(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'No activity on this date.',
                              style: bodyStyle(size: 14, color: kTextMuted),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          for (final record in dayActivities) ...[
                            _ActivityRow(record: record),
                            const SizedBox(height: 10),
                          ],
                        const SizedBox(height: 8),
                        BridgeGlassButton(
                          label: 'Check in now',
                          icon: LucideIcons.fingerprint,
                          onPressed: () => context.pushNamed('checkin'),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.refreshCw, size: 12, color: kTextFaint),
                            const SizedBox(width: 6),
                            Text(
                              'Synced from attendance system · Updated today',
                              style: bodyStyle(size: 11, color: kTextFaint),
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
      },
    );
  }
}

class _SummaryHero extends StatelessWidget {
  const _SummaryHero({
    required this.daysLogged,
    required this.weekHours,
    this.lastRecord,
  });

  final int daysLogged;
  final double weekHours;
  final AttendanceRecord? lastRecord;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 22,
      blur: 26,
      shadows: kHeroCardShadows,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('This week', style: bodyStyle(size: 12, color: kTextMuted)),
                const SizedBox(height: 4),
                Text(
                  '$daysLogged days logged',
                  style: displayStyle(size: 28, weight: 600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${weekHours.toStringAsFixed(1)} h on site',
                  style: bodyStyle(size: 11, color: kTextFaint),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 44, color: kGlassBorder),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Last record', style: bodyStyle(size: 12, color: kTextMuted)),
                const SizedBox(height: 4),
                if (lastRecord != null) ...[
                  Text(
                    _formatTime(lastRecord!.time),
                    style: monoStyle(size: 15, weight: 600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${AttendanceService.activityLabel(lastRecord!)} · ${_methodLabel(lastRecord!.method)}',
                    style: bodyStyle(size: 11, color: kTextFaint),
                  ),
                ] else
                  Text('—', style: displayStyle(size: 22, weight: 600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
    required this.days,
    required this.selected,
    required this.attendance,
    required this.onSelect,
  });

  final List<DateTime> days;
  final DateTime selected;
  final AttendanceService attendance;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      radius: 16,
      blur: 24,
      child: Row(
        children: [
          for (var i = 0; i < days.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: _DayCell(
                label: labels[i],
                day: days[i].day,
                hasRecord: attendance.hasRecordsOn(days[i]),
                selected: _sameDay(days[i], selected),
                isToday: _sameDay(days[i], DateTime.now()),
                onTap: () => onSelect(days[i]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.label,
    required this.day,
    required this.hasRecord,
    required this.selected,
    required this.isToday,
    required this.onTap,
  });

  final String label;
  final int day;
  final bool hasRecord;
  final bool selected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? kActiveFill : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: selected ? Border.all(color: kActiveBorder) : null,
        ),
        child: Column(
          children: [
            Text(label, style: bodyStyle(size: 10, color: kTextFaint, weight: 600)),
            const SizedBox(height: 4),
            Text(
              '$day',
              style: displayStyle(
                size: 15,
                weight: isToday ? 700 : 600,
                color: selected ? kText : kTextMuted,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasRecord
                    ? (selected ? kRedLight : kBrandColor.withValues(alpha: 0.55))
                    : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayDetailCard extends StatelessWidget {
  const _DayDetailCard({required this.log});

  final DayLog log;

  @override
  Widget build(BuildContext context) {
    final isToday = _sameDay(log.date, DateTime.now());
    final checkIn = log.checkIn;
    final checkOut = log.checkOut;

    return GlassCard(
      radius: 20,
      blur: 24,
      borderColor: isToday ? kGlassBorderHero : kGlassBorder,
      shadows: isToday ? const [kRedGlowShadow] : null,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RedTintIconTile(
                icon: checkIn?.method == AttendanceMethod.remote
                    ? LucideIcons.house
                    : LucideIcons.building2,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isToday ? "Today's log" : _formatDayLabel(log.date),
                      style: bodyStyle(size: 15, weight: 600),
                    ),
                    Text(
                      checkIn?.method == AttendanceMethod.remote
                          ? 'Remote check-in'
                          : 'BRIDGE HQ · Office',
                      style: bodyStyle(size: 12, color: kTextMuted),
                    ),
                  ],
                ),
              ),
              if (isToday)
                const CategoryChip(label: 'Today', accent: true, uppercase: false),
            ],
          ),
          const SizedBox(height: 14),
          _TimeRow(
            icon: LucideIcons.logIn,
            label: 'Check in',
            record: checkIn,
          ),
          const SizedBox(height: 10),
          _TimeRow(
            icon: LucideIcons.logOut,
            label: 'Check out',
            record: checkOut,
          ),
          if (log.hoursWorked != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(LucideIcons.clock, size: 14, color: kTextFaint),
                const SizedBox(width: 6),
                Text(
                  '${log.hoursWorked!.toStringAsFixed(1)} h logged',
                  style: monoStyle(size: 14),
                ),
              ],
            ),
          ],
          for (final note in log.activities.where((r) => r.reason != null)) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kGlassInnerFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kGlassInnerBorder),
              ),
              child: Text(
                'Note: ${note.reason}',
                style: bodyStyle(size: 12, color: kTextMuted, height: 1.45),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.icon,
    required this.label,
    required this.record,
  });

  final IconData icon;
  final String label;
  final AttendanceRecord? record;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: record != null ? kRedLight : kTextFaint,
        ),
        const SizedBox(width: 8),
        Text(label, style: bodyStyle(size: 13, weight: 500)),
        const Spacer(),
        Text(
          record != null ? _formatTime(record!.time) : '—',
          style: monoStyle(size: 13, color: record != null ? kText : kTextFaint),
        ),
        if (record?.method == AttendanceMethod.remote) ...[
          const SizedBox(width: 6),
          Icon(LucideIcons.camera, size: 13, color: kTextFaint),
        ],
      ],
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
    required this.month,
    required this.selected,
    required this.attendance,
    required this.onMonthChanged,
    required this.onDaySelected,
  });

  final DateTime month;
  final DateTime selected;
  final AttendanceService attendance;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final year = month.year;
    final monthIndex = month.month;
    final firstOfMonth = DateTime(year, monthIndex, 1);
    final daysInMonth = DateTime(year, monthIndex + 1, 0).day;
    final leading = firstOfMonth.weekday - 1; // Mon = 0
    final today = DateTime.now();

    return GlassCard(
      radius: 20,
      blur: 24,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              GlassIconButton(
                icon: LucideIcons.chevronLeft,
                size: 32,
                iconSize: 14,
                onPressed: () {
                  final prev = DateTime(year, monthIndex - 1);
                  onMonthChanged(prev);
                },
              ),
              Expanded(
                child: Text(
                  '${_monthName(monthIndex)} $year',
                  style: displayStyle(size: 17, weight: 600),
                  textAlign: TextAlign.center,
                ),
              ),
              GlassIconButton(
                icon: LucideIcons.chevronRight,
                size: 32,
                iconSize: 14,
                onPressed: () {
                  final next = DateTime(year, monthIndex + 1);
                  onMonthChanged(next);
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final label in ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
                Expanded(
                  child: Text(
                    label,
                    style: bodyStyle(size: 10, color: kTextFaint, weight: 600),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 0.82,
            ),
            itemCount: leading + daysInMonth,
            itemBuilder: (context, index) {
              if (index < leading) return const SizedBox.shrink();

              final day = index - leading + 1;
              final date = DateTime(year, monthIndex, day);
              final log = attendance.forDate(date);
              final isSelected = _sameDay(date, selected);
              final isToday = _sameDay(date, today);

              return _CalendarDayCell(
                day: day,
                kind: log.kind,
                selected: isSelected,
                isToday: isToday,
                onTap: () => onDaySelected(date),
              );
            },
          ),
          const SizedBox(height: 14),
          const _CalendarLegend(),
        ],
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.day,
    required this.kind,
    required this.selected,
    required this.isToday,
    required this.onTap,
  });

  final int day;
  final DayLogKind kind;
  final bool selected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected ? kActiveFill : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: selected
              ? Border.all(color: kActiveBorder)
              : isToday
                  ? Border.all(color: kGlassBorderHero)
                  : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: displayStyle(
                size: 14,
                weight: isToday ? 700 : 600,
                color: selected ? kText : kTextMuted,
              ),
            ),
            const SizedBox(height: 5),
            _StatusDot(kind: kind),
          ],
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.kind});

  final DayLogKind kind;

  @override
  Widget build(BuildContext context) {
    if (kind == DayLogKind.none) {
      return const SizedBox(width: 6, height: 6);
    }

    if (kind == DayLogKind.incomplete) {
      return Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: kTextMuted, width: 1.2),
        ),
      );
    }

    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: kind == DayLogKind.remote
            ? kRedLight
            : kBrandColor.withValues(alpha: 0.85),
      ),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(
          dot: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kBrandColor.withValues(alpha: 0.85),
            ),
          ),
          label: 'Office',
        ),
        const SizedBox(width: 14),
        _LegendItem(
          dot: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: kRedLight,
            ),
          ),
          label: 'Remote',
        ),
        const SizedBox(width: 14),
        _LegendItem(
          dot: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: kTextMuted, width: 1.2),
            ),
          ),
          label: 'Incomplete',
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.dot, required this.label});

  final Widget dot;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        dot,
        const SizedBox(width: 6),
        Text(label, style: bodyStyle(size: 11, color: kTextFaint)),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.record});

  final AttendanceRecord record;

  @override
  Widget build(BuildContext context) {
    final label = AttendanceService.activityLabel(record);
    final isCheckOut = AttendanceService.isCheckOutActivity(record.time);

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      radius: 16,
      blur: 24,
      child: Row(
        children: [
          RedTintIconTile(
            icon: isCheckOut ? LucideIcons.logOut : LucideIcons.logIn,
            size: 34,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: bodyStyle(size: 13, weight: 500)),
                const SizedBox(height: 3),
                Text(
                  _activityMeta(record),
                  style: bodyStyle(size: 11, color: kTextFaint),
                ),
              ],
            ),
          ),
          Text(_formatTime(record.time), style: monoStyle(size: 13)),
        ],
      ),
    );
  }

  String _activityMeta(AttendanceRecord record) {
    final parts = <String>[
      _methodLabel(record.method),
      if (record.method == AttendanceMethod.office && !AttendanceService.isCheckOutActivity(record.time))
        'Fingerprint',
      if (record.reason != null) record.reason!,
    ];
    return parts.join(' · ');
  }
}

String _methodLabel(AttendanceMethod method) =>
    method == AttendanceMethod.remote ? 'Remote' : 'Office';

String _formatTime(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _formatDayLabel(DateTime d) {
  const weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
}

String _formatDayShort(DateTime d) {
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${weekdays[d.weekday - 1]} · ${months[d.month - 1]} ${d.day}';
}

String _monthName(int month) {
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  return months[month - 1];
}
