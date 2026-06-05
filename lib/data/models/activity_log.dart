/// Activity Log Model for AI Insights Engine
class ActivityLog {
  final String id;
  final String childId;
  final int screenTime; // in minutes
  final DateTime timestamp;
  final ActivityCategory category;
  final String? appName;

  ActivityLog({
    required this.id,
    required this.childId,
    required this.screenTime,
    required this.timestamp,
    required this.category,
    this.appName,
  });

  ActivityLog copyWith({
    String? id,
    String? childId,
    int? screenTime,
    DateTime? timestamp,
    ActivityCategory? category,
    String? appName,
  }) {
    return ActivityLog(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      screenTime: screenTime ?? this.screenTime,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      appName: appName ?? this.appName,
    );
  }
}

enum ActivityCategory {
  gaming,
  social,
  education,
  entertainment,
  productivity,
  other,
}

/// Extension to get display names for categories
extension ActivityCategoryExtension on ActivityCategory {
  String get displayName {
    switch (this) {
      case ActivityCategory.gaming:
        return 'Gaming';
      case ActivityCategory.social:
        return 'Social Media';
      case ActivityCategory.education:
        return 'Education';
      case ActivityCategory.entertainment:
        return 'Entertainment';
      case ActivityCategory.productivity:
        return 'Productivity';
      case ActivityCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case ActivityCategory.gaming:
        return '🎮';
      case ActivityCategory.social:
        return '💬';
      case ActivityCategory.education:
        return '📚';
      case ActivityCategory.entertainment:
        return '🎬';
      case ActivityCategory.productivity:
        return '💼';
      case ActivityCategory.other:
        return '📱';
    }
  }
}
