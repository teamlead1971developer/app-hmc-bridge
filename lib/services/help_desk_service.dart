import 'package:flutter/foundation.dart';

import '../models/help_ticket.dart';

/// In-memory help desk tickets for the session.
// TODO: replace mock data with ITSM / ticketing API integration.
class HelpDeskService extends ChangeNotifier {
  HelpDeskService._();

  static final instance = HelpDeskService._();

  void signalRefresh() => notifyListeners();

  static const allStatuses = 'All';

  final List<HelpTicket> _tickets = [
    HelpTicket(
      id: 'hd-101',
      category: TicketCategory.it,
      subject: 'VPN disconnects on mobile hotspot',
      description:
          'VPN drops every 10–15 minutes when tethering from my phone during site visits.',
      status: TicketStatus.inProgress,
      createdAt: DateTime(2026, 7, 2, 9, 15),
      updatedAt: DateTime(2026, 7, 3, 11, 40),
      assignee: 'IT Service Desk',
    ),
    HelpTicket(
      id: 'hd-098',
      category: TicketCategory.facilities,
      subject: 'Meeting room 12B projector flicker',
      description: 'HDMI output flickers after 20 minutes in room 12B.',
      status: TicketStatus.resolved,
      createdAt: DateTime(2026, 6, 18, 14, 5),
      updatedAt: DateTime(2026, 6, 20, 10, 0),
    ),
    HelpTicket(
      id: 'hd-092',
      category: TicketCategory.it,
      subject: 'New laptop setup',
      description: 'Need corporate apps and MFA enrolled on replacement MacBook.',
      status: TicketStatus.resolved,
      createdAt: DateTime(2026, 5, 6, 8, 30),
      updatedAt: DateTime(2026, 5, 7, 16, 20),
    ),
  ];

  static const faqItems = [
    _FaqItem(
      question: 'How do I reset my password?',
      answer: 'Use the Forgot password link on the sign-in screen, or contact IT if your account is locked.',
    ),
    _FaqItem(
      question: 'Who approves hardware requests?',
      answer: 'Line managers approve requests. IT fulfills approved tickets within 2 business days.',
    ),
    _FaqItem(
      question: 'Where is the employee handbook?',
      answer: 'Contact HR for the latest employee handbook and policy documents.',
    ),
  ];

  List<HelpTicket> get all {
    final items = List<HelpTicket>.from(_tickets)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  int get openCount => _tickets.where((t) => t.status != TicketStatus.resolved).length;

  List<HelpTicket> filtered({TicketStatus? status}) {
    if (status == null) return all;
    return all.where((t) => t.status == status).toList();
  }

  HelpTicket? byId(String id) {
    for (final ticket in _tickets) {
      if (ticket.id == id) return ticket;
    }
    return null;
  }

  HelpTicket submit({
    required TicketCategory category,
    required String subject,
    required String description,
  }) {
    final ticket = HelpTicket(
      id: 'hd-${DateTime.now().millisecondsSinceEpoch}',
      category: category,
      subject: subject,
      description: description,
      status: TicketStatus.open,
      createdAt: DateTime.now(),
    );
    _tickets.add(ticket);
    notifyListeners();
    return ticket;
  }
}

class _FaqItem {
  const _FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;
}

typedef FaqItem = ({String question, String answer});

List<FaqItem> get helpDeskFaq => HelpDeskService.faqItems
    .map((item) => (question: item.question, answer: item.answer))
    .toList();

String formatTicketDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '${months[date.month - 1]} ${date.day}, ${date.year} · $hour:$minute';
}
