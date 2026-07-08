class PayslipLineItem {
  const PayslipLineItem({
    required this.label,
    required this.amount,
  });

  final String label;

  /// Amount in smallest currency unit (e.g. satang). Always positive.
  final int amount;
}

class Payslip {
  const Payslip({
    required this.id,
    required this.periodLabel,
    required this.payDate,
    required this.periodStart,
    required this.periodEnd,
    required this.grossAmount,
    required this.netAmount,
    required this.earnings,
    required this.deductions,
    this.currencyCode = 'THB',
  });

  final String id;
  final String periodLabel;
  final DateTime payDate;
  final DateTime periodStart;
  final DateTime periodEnd;

  /// Amounts in the smallest currency unit (e.g. satang).
  final int grossAmount;
  final int netAmount;
  final String currencyCode;
  final List<PayslipLineItem> earnings;
  final List<PayslipLineItem> deductions;

  int get totalDeductions =>
      deductions.fold<int>(0, (sum, item) => sum + item.amount);
}
