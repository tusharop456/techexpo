class Alert {
  final String id;
  final String childId;
  final String? eventId;
  final String severity; // info, warning, critical
  final String type;
  final String message;
  final bool acknowledged;
  final DateTime createdAt;
  final DateTime? acknowledgedAt;

  Alert({
    required this.id,
    required this.childId,
    this.eventId,
    required this.severity,
    required this.type,
    required this.message,
    required this.acknowledged,
    required this.createdAt,
    this.acknowledgedAt,
  });
}