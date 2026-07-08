import '../models/payslip.dart';

/// In-memory payslips for the session.
// TODO: replace mock data with payroll API integration.
class PayslipService {
  PayslipService._();

  static final instance = PayslipService._();

  static final _payslips = <Payslip>[
    _slip(
      id: 'ps-2026-06',
      periodLabel: 'June 2026',
      payDate: DateTime(2026, 6, 28),
      periodStart: DateTime(2026, 6, 1),
      periodEnd: DateTime(2026, 6, 30),
      netAmount: 3850000,
      tax: 300000,
      social: 225000,
      provident: 125000,
    ),
    _slip(
      id: 'ps-2026-05',
      periodLabel: 'May 2026',
      payDate: DateTime(2026, 5, 28),
      periodStart: DateTime(2026, 5, 1),
      periodEnd: DateTime(2026, 5, 31),
      netAmount: 3825000,
      tax: 300000,
      social: 225000,
      provident: 150000,
    ),
    _slip(
      id: 'ps-2026-04',
      periodLabel: 'April 2026',
      payDate: DateTime(2026, 4, 28),
      periodStart: DateTime(2026, 4, 1),
      periodEnd: DateTime(2026, 4, 30),
      netAmount: 3900000,
      tax: 275000,
      social: 225000,
      provident: 100000,
    ),
    _slip(
      id: 'ps-2026-03',
      periodLabel: 'March 2026',
      payDate: DateTime(2026, 3, 28),
      periodStart: DateTime(2026, 3, 1),
      periodEnd: DateTime(2026, 3, 31),
      netAmount: 3875000,
      tax: 287500,
      social: 225000,
      provident: 112500,
    ),
    _slip(
      id: 'ps-2026-02',
      periodLabel: 'February 2026',
      payDate: DateTime(2026, 2, 28),
      periodStart: DateTime(2026, 2, 1),
      periodEnd: DateTime(2026, 2, 28),
      netAmount: 3840000,
      tax: 300000,
      social: 225000,
      provident: 135000,
    ),
    _slip(
      id: 'ps-2026-01',
      periodLabel: 'January 2026',
      payDate: DateTime(2026, 1, 28),
      periodStart: DateTime(2026, 1, 1),
      periodEnd: DateTime(2026, 1, 31),
      netAmount: 3860000,
      tax: 287500,
      social: 225000,
      provident: 127500,
    ),
  ];

  static const _grossAmount = 4500000;
  static const _baseSalary = 4200000;
  static const _transportAllowance = 300000;

  static Payslip _slip({
    required String id,
    required String periodLabel,
    required DateTime payDate,
    required DateTime periodStart,
    required DateTime periodEnd,
    required int netAmount,
    required int tax,
    required int social,
    required int provident,
  }) {
    return Payslip(
      id: id,
      periodLabel: periodLabel,
      payDate: payDate,
      periodStart: periodStart,
      periodEnd: periodEnd,
      grossAmount: _grossAmount,
      netAmount: netAmount,
      earnings: const [
        PayslipLineItem(label: 'Base salary', amount: _baseSalary),
        PayslipLineItem(label: 'Transport allowance', amount: _transportAllowance),
      ],
      deductions: [
        PayslipLineItem(label: 'Income tax', amount: tax),
        PayslipLineItem(label: 'Social security', amount: social),
        PayslipLineItem(label: 'Provident fund', amount: provident),
      ],
    );
  }

  List<Payslip> get all => List.unmodifiable(_payslips);

  int get ytdNetAmount =>
      _payslips.fold<int>(0, (sum, slip) => sum + slip.netAmount);

  Payslip? byId(String id) {
    for (final slip in _payslips) {
      if (slip.id == id) return slip;
    }
    return null;
  }
}

String formatPayDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

String formatPayPeriod(DateTime start, DateTime end) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  if (start.year == end.year && start.month == end.month) {
    return '${months[start.month - 1]} ${start.day} – ${end.day}, ${end.year}';
  }
  return '${months[start.month - 1]} ${start.day}, ${start.year} – '
      '${months[end.month - 1]} ${end.day}, ${end.year}';
}

/// Formats [amount] in smallest currency unit (e.g. satang) for display.
String formatMoney(int amount, {String symbol = '฿'}) {
  final major = amount ~/ 100;
  final minor = (amount % 100).abs();
  final grouped = _groupDigits(major);
  if (minor == 0) return '$symbol$grouped';
  return '$symbol$grouped.${minor.toString().padLeft(2, '0')}';
}

String _groupDigits(int value) {
  final negative = value < 0;
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return negative ? '-${buffer.toString()}' : buffer.toString();
}
