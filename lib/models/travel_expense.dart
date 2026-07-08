enum TravelExpenseCategory {
  transport('Transport'),
  meals('Meals'),
  accommodation('Accommodation'),
  fuel('Fuel'),
  other('Other');

  const TravelExpenseCategory(this.label);
  final String label;
}

enum TravelExpenseStatus {
  pending('Pending'),
  approved('Approved'),
  rejected('Rejected'),
  paid('Paid');

  const TravelExpenseStatus(this.label);
  final String label;
}

class TravelExpenseClaim {
  const TravelExpenseClaim({
    required this.id,
    required this.category,
    required this.tripTitle,
    required this.expenseDate,
    required this.amount,
    required this.description,
    required this.status,
    required this.submittedAt,
    this.receiptPath,
    this.currencyCode = 'THB',
    DateTime? statusUpdatedAt,
    this.approverName,
    this.rejectionReason,
  }) : statusUpdatedAt = statusUpdatedAt ?? submittedAt;

  final String id;
  final TravelExpenseCategory category;
  final String tripTitle;
  final DateTime expenseDate;

  /// Amount in smallest currency unit (e.g. satang).
  final int amount;
  final String description;
  final TravelExpenseStatus status;
  final DateTime submittedAt;
  final String? receiptPath;
  final String currencyCode;

  /// When [status] last changed (approval, rejection, payment, etc.).
  final DateTime statusUpdatedAt;

  final String? approverName;
  final String? rejectionReason;

  TravelExpenseClaim copyWith({
    TravelExpenseCategory? category,
    String? tripTitle,
    DateTime? expenseDate,
    int? amount,
    String? description,
    TravelExpenseStatus? status,
    DateTime? submittedAt,
    String? receiptPath,
    String? currencyCode,
    DateTime? statusUpdatedAt,
    String? approverName,
    String? rejectionReason,
  }) {
    return TravelExpenseClaim(
      id: id,
      category: category ?? this.category,
      tripTitle: tripTitle ?? this.tripTitle,
      expenseDate: expenseDate ?? this.expenseDate,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      receiptPath: receiptPath ?? this.receiptPath,
      currencyCode: currencyCode ?? this.currencyCode,
      statusUpdatedAt: statusUpdatedAt ?? this.statusUpdatedAt,
      approverName: approverName ?? this.approverName,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}
