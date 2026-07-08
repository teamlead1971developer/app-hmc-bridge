enum AttendanceType { checkIn, checkOut }

enum AttendanceMethod { office, remote }

class AttendanceRecord {
  const AttendanceRecord({
    required this.type,
    required this.method,
    required this.time,
    this.photoPath,
    this.reason,
  });

  final AttendanceType type;
  final AttendanceMethod method;
  final DateTime time;

  /// Local path of the proof photo; required for remote records.
  final String? photoPath;

  /// Required for early-leave check-outs (before the official end of day).
  final String? reason;
}
