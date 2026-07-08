enum JoyPointTransactionType {
  earn,
  burn;

  String get label => switch (this) {
        JoyPointTransactionType.earn => 'Earn',
        JoyPointTransactionType.burn => 'Burn',
      };
}

class JoyPointTransaction {
  const JoyPointTransaction({
    required this.id,
    required this.type,
    required this.points,
    required this.date,
    required this.description,
  });

  final String id;
  final JoyPointTransactionType type;
  final int points;
  final DateTime date;
  final String description;

  String get signedPoints =>
      type == JoyPointTransactionType.earn ? '+$points' : '-$points';
}
