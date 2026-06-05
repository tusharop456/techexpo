// Simple data models for the app (no database needed)

class ChildModel {
  final String id;
  final String name;
  final int riskLevel;
  final DateTime lastActive;
  final String deviceName;

  ChildModel({
    required this.id,
    required this.name,
    this.riskLevel = 0,
    DateTime? lastActive,
    this.deviceName = 'Unknown Device',
  }) : lastActive = lastActive ?? DateTime.now();

  ChildModel copyWith({
    String? id,
    String? name,
    int? riskLevel,
    DateTime? lastActive,
    String? deviceName,
  }) {
    return ChildModel(
      id: id ?? this.id,
      name: name ?? this.name,
      riskLevel: riskLevel ?? this.riskLevel,
      lastActive: lastActive ?? this.lastActive,
      deviceName: deviceName ?? this.deviceName,
    );
  }
}

class AlertModel {
  final String id;
  final String childId;
  final String childName;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final int severity; // 0: low, 1: medium, 2: high
  final String category;

  AlertModel({
    required this.id,
    required this.childId,
    required this.childName,
    required this.title,
    required this.message,
    DateTime? timestamp,
    this.isRead = false,
    this.severity = 1,
    this.category = 'general',
  }) : timestamp = timestamp ?? DateTime.now();

  AlertModel copyWith({bool? isRead}) {
    return AlertModel(
      id: id,
      childId: childId,
      childName: childName,
      title: title,
      message: message,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      severity: severity,
      category: category,
    );
  }
}

class ActivityModel {
  final String id;
  final String childName;
  final String description;
  final DateTime timestamp;
  final String iconType;
  final String colorType;

  ActivityModel({
    required this.id,
    required this.childName,
    required this.description,
    DateTime? timestamp,
    this.iconType = 'info',
    this.colorType = 'primary',
  }) : timestamp = timestamp ?? DateTime.now();
}
