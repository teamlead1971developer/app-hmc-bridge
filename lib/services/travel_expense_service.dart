import 'package:flutter/foundation.dart';

import '../models/travel_expense.dart';

/// In-memory travel expense claims for the session.
// TODO: replace mock data with finance API integration.
class TravelExpenseService extends ChangeNotifier {
  TravelExpenseService._();

  static final instance = TravelExpenseService._();

  void signalRefresh() => notifyListeners();

  static const allStatuses = 'All';

  final List<TravelExpenseClaim> _claims = [
    TravelExpenseClaim(
      id: 'te-1',
      category: TravelExpenseCategory.transport,
      tripTitle: 'Bangkok client visit',
      expenseDate: DateTime(2026, 6, 18),
      amount: 48500,
      description: 'Grab from HQ to client office and return.',
      status: TravelExpenseStatus.pending,
      submittedAt: DateTime(2026, 6, 19, 9, 15),
      receiptPath: '/mock/receipt-grab.jpg',
    ),
    TravelExpenseClaim(
      id: 'te-2',
      category: TravelExpenseCategory.meals,
      tripTitle: 'Bangkok client visit',
      expenseDate: DateTime(2026, 6, 18),
      amount: 32000,
      description: 'Working lunch with client team.',
      status: TravelExpenseStatus.approved,
      submittedAt: DateTime(2026, 6, 19, 9, 20),
      statusUpdatedAt: DateTime(2026, 6, 20, 14, 0),
      approverName: 'Finance helpdesk',
      receiptPath: '/mock/receipt-lunch.jpg',
    ),
    TravelExpenseClaim(
      id: 'te-3',
      category: TravelExpenseCategory.accommodation,
      tripTitle: 'Chiang Mai offsite',
      expenseDate: DateTime(2026, 5, 8),
      amount: 285000,
      description: 'One night at conference hotel.',
      status: TravelExpenseStatus.paid,
      submittedAt: DateTime(2026, 5, 10, 14, 0),
      statusUpdatedAt: DateTime(2026, 5, 15, 10, 0),
      approverName: 'Finance helpdesk',
      receiptPath: '/mock/receipt-hotel.jpg',
    ),
    TravelExpenseClaim(
      id: 'te-4',
      category: TravelExpenseCategory.fuel,
      tripTitle: 'Provincial site audit',
      expenseDate: DateTime(2026, 4, 22),
      amount: 156000,
      description: 'Fuel for round trip to Rayong site.',
      status: TravelExpenseStatus.rejected,
      submittedAt: DateTime(2026, 4, 23, 11, 30),
      statusUpdatedAt: DateTime(2026, 4, 24, 16, 0),
      approverName: 'Finance helpdesk',
      rejectionReason:
          'Receipt must show vehicle registration matching the company fleet list.',
      receiptPath: '/mock/receipt-fuel.jpg',
    ),
  ];

  List<TravelExpenseClaim> get all {
    final items = List<TravelExpenseClaim>.from(_claims)
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return items;
  }

  int get pendingCount =>
      _claims.where((c) => c.status == TravelExpenseStatus.pending).length;

  int get pendingAmount => _claims
      .where((c) => c.status == TravelExpenseStatus.pending)
      .fold<int>(0, (sum, c) => sum + c.amount);

  int get ytdReimbursed {
    final year = DateTime.now().year;
    return _claims
        .where(
          (c) =>
              c.status == TravelExpenseStatus.paid &&
              c.submittedAt.year == year,
        )
        .fold<int>(0, (sum, c) => sum + c.amount);
  }

  List<TravelExpenseClaim> filtered({TravelExpenseStatus? status}) {
    if (status == null) return all;
    return all.where((c) => c.status == status).toList();
  }

  TravelExpenseClaim? byId(String id) {
    for (final claim in _claims) {
      if (claim.id == id) return claim;
    }
    return null;
  }

  TravelExpenseClaim submit({
    required TravelExpenseCategory category,
    required String tripTitle,
    required DateTime expenseDate,
    required int amount,
    required String description,
    String? receiptPath,
  }) {
    final claim = TravelExpenseClaim(
      id: 'te-${DateTime.now().millisecondsSinceEpoch}',
      category: category,
      tripTitle: tripTitle,
      expenseDate: expenseDate,
      amount: amount,
      description: description,
      status: TravelExpenseStatus.pending,
      submittedAt: DateTime.now(),
      receiptPath: receiptPath,
    );
    _claims.add(claim);
    notifyListeners();
    return claim;
  }

  void applyDecision(
    String id, {
    required TravelExpenseStatus status,
    required String approverName,
    String? rejectionReason,
  }) {
    final index = _claims.indexWhere((claim) => claim.id == id);
    if (index == -1) return;

    final current = _claims[index];
    if (current.status != TravelExpenseStatus.pending) return;

    _claims[index] = current.copyWith(
      status: status,
      statusUpdatedAt: DateTime.now(),
      approverName: approverName,
      rejectionReason: rejectionReason,
    );
    notifyListeners();
  }
}

String formatExpenseDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

/// Parses a user-entered amount string (e.g. "1,250.50") to satang.
int? parseMoneyToSatang(String input) {
  final normalized = input.replaceAll(',', '').trim();
  if (normalized.isEmpty) return null;

  final parts = normalized.split('.');
  if (parts.length > 2) return null;

  final major = int.tryParse(parts[0]);
  if (major == null || major < 0) return null;

  var minor = 0;
  if (parts.length == 2) {
    final fraction = parts[1];
    if (fraction.isEmpty || !RegExp(r'^\d{1,2}$').hasMatch(fraction)) {
      return null;
    }
    minor = int.parse(fraction.padRight(2, '0').substring(0, 2));
  }

  return major * 100 + minor;
}
