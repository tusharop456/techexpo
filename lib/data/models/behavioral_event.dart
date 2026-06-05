class BehavioralEvent {
  final String id;
  final String childId;
  final DateTime timestamp;
  final int durationSeconds;
  final int interactionCount;
  final int newKnownContacts;
  final int unknownContacts;
  final String appCategory;
  final String appName;
  final String deviceType;
  final int riskScore;
  final String riskLevel;

  BehavioralEvent({
    required this.id,
    required this.childId,
    required this.timestamp,
    required this.durationSeconds,
    required this.interactionCount,
    required this.newKnownContacts,
    required this.unknownContacts,
    required this.appCategory,
    required this.appName,
    required this.deviceType,
    required this.riskScore,
    required this.riskLevel,
  });
}