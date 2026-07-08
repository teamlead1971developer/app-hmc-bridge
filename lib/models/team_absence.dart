import 'leave_request.dart';

/// A teammate's approved absence shown on the team calendar.
class TeamAbsence {
  const TeamAbsence({
    required this.id,
    required this.memberName,
    required this.department,
    required this.initials,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
  });

  final String id;
  final String memberName;
  final String department;
  final String initials;
  final LeaveType leaveType;
  final DateTime startDate;
  final DateTime endDate;

  bool coversDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    return !day.isBefore(start) && !day.isAfter(end);
  }

  int get dayCount => endDate.difference(startDate).inDays + 1;
}
