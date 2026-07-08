enum JoyPrivilegeStatus {
  available,
  expired,
  used;

  String get label => switch (this) {
        JoyPrivilegeStatus.available => 'Available',
        JoyPrivilegeStatus.expired => 'Expired',
        JoyPrivilegeStatus.used => 'Used',
      };

  bool get isAvailable => this == JoyPrivilegeStatus.available;
}

class JoyPrivilege {
  const JoyPrivilege({
    required this.id,
    required this.name,
    required this.code,
    required this.status,
    required this.validFrom,
    required this.validUntil,
    required this.conditions,
    this.usedAt,
    this.summary,
  });

  final String id;
  final String name;
  final String code;
  final JoyPrivilegeStatus status;
  final DateTime validFrom;
  final DateTime validUntil;
  final List<String> conditions;
  final DateTime? usedAt;
  final String? summary;
}
