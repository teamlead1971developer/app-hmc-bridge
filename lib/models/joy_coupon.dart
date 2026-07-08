enum JoyCouponStatus {
  available,
  expired,
  used;

  String get label => switch (this) {
        JoyCouponStatus.available => 'Available',
        JoyCouponStatus.expired => 'Expired',
        JoyCouponStatus.used => 'Used',
      };
}

class JoyCouponTag {
  const JoyCouponTag({required this.id, required this.label});

  final String id;
  final String label;
}

class JoyCoupon {
  const JoyCoupon({
    required this.id,
    required this.name,
    required this.code,
    required this.status,
    required this.tagId,
    required this.validFrom,
    required this.validUntil,
    required this.conditions,
    this.usedAt,
    this.summary,
  });

  final String id;
  final String name;
  final String code;
  final JoyCouponStatus status;
  final String tagId;
  final DateTime validFrom;
  final DateTime validUntil;
  final List<String> conditions;
  final DateTime? usedAt;
  final String? summary;
}
