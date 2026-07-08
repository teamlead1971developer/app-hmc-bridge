class User {
  const User({
    required this.name,
    required this.nickname,
    required this.role,
    required this.email,
    required this.employeeId,
    required this.section,
    required this.department,
    this.phone = '',
    this.emergencyContact = '',
    this.photoUrl,
    this.isLineManager = false,
  });

  final String name;
  final String nickname;
  final String role;
  final String email;
  final String employeeId;
  final String section;
  final String department;
  final String phone;
  final String emergencyContact;
  final String? photoUrl;
  final bool isLineManager;

  User copyWith({
    String? name,
    String? nickname,
    String? role,
    String? email,
    String? employeeId,
    String? section,
    String? department,
    String? phone,
    String? emergencyContact,
    String? photoUrl,
    bool? isLineManager,
  }) {
    return User(
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      role: role ?? this.role,
      email: email ?? this.email,
      employeeId: employeeId ?? this.employeeId,
      section: section ?? this.section,
      department: department ?? this.department,
      phone: phone ?? this.phone,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      photoUrl: photoUrl ?? this.photoUrl,
      isLineManager: isLineManager ?? this.isLineManager,
    );
  }

  String get firstName => name.split(' ').first;

  String get initials => name
      .split(' ')
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();
}
