enum TicketCategory {
  it('IT support'),
  facilities('Facilities'),
  hr('HR'),
  other('Other');

  const TicketCategory(this.label);
  final String label;
}

enum TicketStatus {
  open('Open'),
  inProgress('In progress'),
  resolved('Resolved');

  const TicketStatus(this.label);
  final String label;
}

class HelpTicket {
  const HelpTicket({
    required this.id,
    required this.category,
    required this.subject,
    required this.description,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.assignee,
  });

  final String id;
  final TicketCategory category;
  final String subject;
  final String description;
  final TicketStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? assignee;
}
