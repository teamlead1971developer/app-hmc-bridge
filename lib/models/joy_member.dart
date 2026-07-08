/// Staff loyalty tier for The Joy programme (levels 1–6).
enum JoyStaffTier {
  staff1,
  staff2,
  staff3,
  staff4,
  staff5,
  staff6;

  String get label => switch (this) {
        JoyStaffTier.staff1 => 'Staff 1',
        JoyStaffTier.staff2 => 'Staff 2',
        JoyStaffTier.staff3 => 'Staff 3',
        JoyStaffTier.staff4 => 'Staff 4',
        JoyStaffTier.staff5 => 'Staff 5',
        JoyStaffTier.staff6 => 'Staff 6',
      };
}

class JoyMember {
  const JoyMember({
    required this.memberId,
    required this.name,
    required this.nickname,
    required this.tel,
    required this.email,
    required this.birthday,
    required this.tier,
    required this.pointBalance,
    required this.expiringPoints,
    required this.expiringPointsDate,
    required this.memberCode,
    required this.since,
  });

  final String memberId;
  final String name;
  final String nickname;
  final String tel;
  final String email;
  final DateTime birthday;
  final JoyStaffTier tier;
  final int pointBalance;
  final int expiringPoints;
  final DateTime expiringPointsDate;
  final String memberCode;
  final DateTime since;

  String get firstName => name.split(' ').first;

  String get surname {
    final parts = name.split(' ').where((part) => part.isNotEmpty).toList();
    if (parts.length <= 1) return '';
    return parts.sublist(1).join(' ');
  }

  String get fullName => surname.isEmpty ? firstName : '$firstName $surname';
}
