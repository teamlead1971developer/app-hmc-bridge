import '../models/leave_request.dart';
import '../models/team_absence.dart';

/// Team-wide approved leave for availability views.
/// Separate from [LeaveService], which holds the signed-in user's own requests.
// TODO: replace mock data with HR team calendar API.
class TeamCalendarService {
  TeamCalendarService._();

  static final instance = TeamCalendarService._();

  static const teamSize = 14;

  static final _absences = <TeamAbsence>[
    TeamAbsence(
      id: 'ta-1',
      memberName: 'Natcha Wongsa',
      department: 'Operations',
      initials: 'NW',
      leaveType: LeaveType.annual,
      startDate: DateTime(2026, 7, 7),
      endDate: DateTime(2026, 7, 9),
    ),
    TeamAbsence(
      id: 'ta-2',
      memberName: 'Pimchanok Srisai',
      department: 'Human Resources',
      initials: 'PS',
      leaveType: LeaveType.sick,
      startDate: DateTime(2026, 7, 7),
      endDate: DateTime(2026, 7, 7),
    ),
    TeamAbsence(
      id: 'ta-3',
      memberName: 'Thanawat Meesuk',
      department: 'Human Resources',
      initials: 'TM',
      leaveType: LeaveType.personal,
      startDate: DateTime(2026, 7, 10),
      endDate: DateTime(2026, 7, 11),
    ),
    TeamAbsence(
      id: 'ta-4',
      memberName: 'Kittisak Boonma',
      department: 'Information Technology',
      initials: 'KB',
      leaveType: LeaveType.annual,
      startDate: DateTime(2026, 7, 14),
      endDate: DateTime(2026, 7, 18),
    ),
    TeamAbsence(
      id: 'ta-5',
      memberName: 'Supaporn Lertchai',
      department: 'Information Technology',
      initials: 'SL',
      leaveType: LeaveType.annual,
      startDate: DateTime(2026, 7, 21),
      endDate: DateTime(2026, 7, 22),
    ),
    TeamAbsence(
      id: 'ta-6',
      memberName: 'Training coordinator',
      department: 'Learning & Development',
      initials: 'TC',
      leaveType: LeaveType.unpaid,
      startDate: DateTime(2026, 7, 3),
      endDate: DateTime(2026, 7, 4),
    ),
  ];

  List<TeamAbsence> outOn(DateTime date) {
    return _absences.where((a) => a.coversDate(date)).toList()
      ..sort((a, b) => a.memberName.compareTo(b.memberName));
  }

  int outCountOn(DateTime date) => outOn(date).length;

  int availableCountOn(DateTime date) =>
      (teamSize - outCountOn(date)).clamp(0, teamSize);

  int availabilityPercentOn(DateTime date) =>
      ((availableCountOn(date) / teamSize) * 100).round();

  /// Seven days centered on [anchor] (anchor ± 3).
  List<DateTime> weekAround(DateTime anchor) {
    final day = DateTime(anchor.year, anchor.month, anchor.day);
    return List.generate(7, (i) => day.add(Duration(days: i - 3)));
  }

  /// Approved absences starting within the next [days] days (excluding [from]).
  List<TeamAbsence> upcoming({required DateTime from, int days = 14}) {
    final start = DateTime(from.year, from.month, from.day);
    final end = start.add(Duration(days: days));
    return _absences.where((a) {
      final absenceStart = DateTime(
        a.startDate.year,
        a.startDate.month,
        a.startDate.day,
      );
      return !absenceStart.isBefore(start) && absenceStart.isBefore(end);
    }).toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
  }
}

String formatCalendarDay(DateTime date) {
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return weekdays[date.weekday - 1];
}

String formatCalendarDate(DateTime date) => '${date.day}';

bool isSameCalendarDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
