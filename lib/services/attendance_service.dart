import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/attendance_record.dart';
import 'debug_session_service.dart';

/// All attendance activity for a single calendar day.
class DayLog {
  const DayLog({
    required this.date,
    required this.activities,
  });

  final DateTime date;

  /// Chronological order (earliest first).
  final List<AttendanceRecord> activities;

  bool get hasRecords => activities.isNotEmpty;

  /// Earliest check-in activity for the day.
  AttendanceRecord? get checkIn {
    final ins = activities
        .where((r) => r.type == AttendanceType.checkIn)
        .toList()
      ..sort((a, b) => a.time.compareTo(b.time));
    return ins.isEmpty ? null : ins.first;
  }

  /// Latest check-out activity for the day.
  AttendanceRecord? get checkOut {
    final outs = activities
        .where((r) => r.type == AttendanceType.checkOut)
        .toList()
      ..sort((a, b) => a.time.compareTo(b.time));
    return outs.isEmpty ? null : outs.last;
  }

  Duration? get duration {
    final in_ = checkIn;
    final out = checkOut;
    if (in_ == null || out == null) return null;
    return out.time.difference(in_.time);
  }

  double? get hoursWorked {
    final d = duration;
    if (d == null) return null;
    return d.inMinutes / 60;
  }

  /// Calendar dot: office complete, remote check-in, or missing check-out.
  DayLogKind get kind {
    if (activities.isEmpty) return DayLogKind.none;
    if (checkOut == null) return DayLogKind.incomplete;
    final first = checkIn;
    if (first?.method == AttendanceMethod.remote) return DayLogKind.remote;
    return DayLogKind.office;
  }
}

enum DayLogKind { none, office, remote, incomplete }

/// In-memory attendance store, shared across screens for the session.
// TODO: replace with a real API and local persistence.
class AttendanceService extends ChangeNotifier {
  AttendanceService._() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final twoDaysAgo = now.subtract(const Duration(days: 2));
    final threeDaysAgo = now.subtract(const Duration(days: 3));
    final fourDaysAgo = now.subtract(const Duration(days: 4));
    final fiveDaysAgo = now.subtract(const Duration(days: 5));

    _records.addAll([
      AttendanceRecord(
        type: AttendanceType.checkIn,
        method: AttendanceMethod.office,
        time: DateTime(threeDaysAgo.year, threeDaysAgo.month, threeDaysAgo.day, 8, 55),
      ),
      AttendanceRecord(
        type: AttendanceType.checkOut,
        method: AttendanceMethod.office,
        time: DateTime(threeDaysAgo.year, threeDaysAgo.month, threeDaysAgo.day, 18, 2),
      ),
      AttendanceRecord(
        type: AttendanceType.checkIn,
        method: AttendanceMethod.office,
        time: DateTime(twoDaysAgo.year, twoDaysAgo.month, twoDaysAgo.day, 9, 8),
      ),
      AttendanceRecord(
        type: AttendanceType.checkOut,
        method: AttendanceMethod.remote,
        photoPath: 'mock/proof.jpg',
        reason: 'Client visit',
        time: DateTime(twoDaysAgo.year, twoDaysAgo.month, twoDaysAgo.day, 16, 30),
      ),
      AttendanceRecord(
        type: AttendanceType.checkIn,
        method: AttendanceMethod.office,
        time: DateTime(yesterday.year, yesterday.month, yesterday.day, 9, 2),
      ),
      AttendanceRecord(
        type: AttendanceType.checkIn,
        method: AttendanceMethod.office,
        time: DateTime(yesterday.year, yesterday.month, yesterday.day, 12, 4),
      ),
      AttendanceRecord(
        type: AttendanceType.checkIn,
        method: AttendanceMethod.office,
        time: DateTime(yesterday.year, yesterday.month, yesterday.day, 13, 15),
      ),
      AttendanceRecord(
        type: AttendanceType.checkOut,
        method: AttendanceMethod.office,
        time: DateTime(yesterday.year, yesterday.month, yesterday.day, 18, 11),
      ),
      AttendanceRecord(
        type: AttendanceType.checkIn,
        method: AttendanceMethod.remote,
        photoPath: 'mock/proof.jpg',
        time: DateTime(fourDaysAgo.year, fourDaysAgo.month, fourDaysAgo.day, 9, 15),
      ),
      AttendanceRecord(
        type: AttendanceType.checkIn,
        method: AttendanceMethod.office,
        time: DateTime(fiveDaysAgo.year, fiveDaysAgo.month, fiveDaysAgo.day, 8, 50),
      ),
      AttendanceRecord(
        type: AttendanceType.checkOut,
        method: AttendanceMethod.office,
        time: DateTime(fiveDaysAgo.year, fiveDaysAgo.month, fiveDaysAgo.day, 18, 5),
      ),
    ]);
    DebugSessionService.instance.addListener(_onEffectiveTimeChanged);
    _scheduleShiftEndTick();
  }

  void _onEffectiveTimeChanged() {
    _scheduleShiftEndTick();
    notifyListeners();
  }

  static final instance = AttendanceService._();

  void signalRefresh() => notifyListeners();

  /// Official end of the working day; checking out earlier requires a reason.
  static const checkOutHour = 17;

  static const defaultShiftStart = '09:00';
  static const defaultShiftEnd = '18:00';

  static const shiftEndHour = 18;
  static const shiftEndMinute = 0;

  final List<AttendanceRecord> _records = [];
  Timer? _shiftEndTimer;

  /// Official shift end for [day] (local time).
  static DateTime shiftEndFor(DateTime day) => DateTime(
        day.year,
        day.month,
        day.day,
        shiftEndHour,
        shiftEndMinute,
      );

  /// Checked in today and the current time is at or after shift end.
  bool get canCheckOutNow =>
      isCheckedIn && isCheckOutActivity(_now);

  /// Checked in today but still before shift end — checkout not yet available.
  bool get isOnShift => isCheckedIn && !canCheckOutNow;

  /// Last activity today was check-out — shift complete for the day.
  bool get isDayClosed {
    if (_records.isEmpty) return false;
    final last = _records.last;
    if (!_sameDay(last.time, _now)) return false;
    return last.type == AttendanceType.checkOut;
  }

  /// Newest first.
  List<AttendanceRecord> get records => _records.reversed.toList();

  bool get isCheckedIn {
    if (_records.isEmpty) return false;
    final last = _records.last;
    if (!_sameDay(last.time, _now)) return false;
    return last.type == AttendanceType.checkIn;
  }

  DateTime get _now => DebugSessionService.instance.effectiveNow;

  /// True when checking out before the official shift end requires a reason.
  static bool requiresCheckoutReason(DateTime time) {
    final end = DateTime(
      time.year,
      time.month,
      time.day,
      shiftEndHour,
      shiftEndMinute,
    );
    return time.isBefore(end);
  }

  /// Before shift end → check in label; at or after → check out label (display).
  static bool isCheckOutActivity(DateTime time) {
    final end = DateTime(
      time.year,
      time.month,
      time.day,
      shiftEndHour,
      shiftEndMinute,
    );
    return !time.isBefore(end);
  }

  static String activityLabel(AttendanceRecord record) =>
      record.type == AttendanceType.checkOut ? 'Check out' : 'Check in';

  AttendanceRecord record({
    required AttendanceType type,
    required AttendanceMethod method,
    String? photoPath,
    String? reason,
  }) {
    final entry = AttendanceRecord(
      type: type,
      method: method,
      time: _now,
      photoPath: photoPath,
      reason: reason,
    );
    _records.add(entry);
    _scheduleShiftEndTick();
    notifyListeners();
    return entry;
  }

  void _scheduleShiftEndTick() {
    _shiftEndTimer?.cancel();
    _shiftEndTimer = null;
    if (!isCheckedIn) return;

    final now = _now;
    final end = shiftEndFor(now);
    if (!now.isBefore(end)) return;

    _shiftEndTimer = Timer(end.difference(now), notifyListeners);
  }

  List<AttendanceRecord> activitiesForDate(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    final items = _records.where((r) => _sameDay(r.time, date)).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
    return items;
  }

  DayLog forDate(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return DayLog(date: date, activities: activitiesForDate(date));
  }

  bool hasRecordsOn(DateTime day) => activitiesForDate(day).isNotEmpty;

  List<DayLog> forWeekContaining(DateTime anchor) {
    final start = _startOfWeek(anchor);
    return List.generate(7, (i) => forDate(start.add(Duration(days: i))));
  }

  List<DayLog> dayLogsForMonth(int year, int month) {
    final logs = <DayLog>[];
    final daysInMonth = DateTime(year, month + 1, 0).day;
    for (var d = 1; d <= daysInMonth; d++) {
      final log = forDate(DateTime(year, month, d));
      if (log.hasRecords) logs.add(log);
    }
    return logs;
  }

  double hoursWorkedInWeek(DateTime anchor) {
    var total = 0.0;
    for (final log in forWeekContaining(anchor)) {
      total += log.hoursWorked ?? 0;
    }
    return total;
  }

  int daysWithRecordsInWeek(DateTime anchor) =>
      forWeekContaining(anchor).where((l) => l.hasRecords).length;

  AttendanceRecord? get lastRecord => records.firstOrNull;

  /// Removes all attendance records for the effective current day (debug).
  void clearTodayRecords() {
    final today = DateTime(_now.year, _now.month, _now.day);
    _records.removeWhere((r) => _sameDay(r.time, today));
    _shiftEndTimer?.cancel();
    _shiftEndTimer = null;
    notifyListeners();
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime _startOfWeek(DateTime d) {
    final base = DateTime(d.year, d.month, d.day);
    return base.subtract(Duration(days: base.weekday - 1));
  }
}
