/// Screen Time Rule Models
library;

/// Usage data for a category
class UsageData {
  final String category;
  final int avgDailyMinutes;
  final List<String> peakHours;

  UsageData({
    required this.category,
    required this.avgDailyMinutes,
    this.peakHours = const [],
  });

  Map<String, dynamic> toJson() => {
    'category': category,
    'avg_daily_minutes': avgDailyMinutes,
    'peak_hours': peakHours,
  };
}

/// Suggested screen time rule
class SuggestedRule {
  final String modeName;
  final String description;
  final String startTime;
  final String endTime;
  final List<String> allowedCategories;
  final List<String> blockedCategories;
  final int? dailyLimitMinutes;

  SuggestedRule({
    required this.modeName,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.allowedCategories,
    required this.blockedCategories,
    this.dailyLimitMinutes,
  });

  factory SuggestedRule.fromJson(Map<String, dynamic> json) {
    return SuggestedRule(
      modeName: json['mode_name'] as String,
      description: json['description'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      allowedCategories: List<String>.from(json['allowed_categories'] ?? []),
      blockedCategories: List<String>.from(json['blocked_categories'] ?? []),
      dailyLimitMinutes: json['daily_limit_minutes'] as int?,
    );
  }
}

/// AI-generated screen time suggestion
class ScreenTimeSuggestion {
  final String summary;
  final List<SuggestedRule> suggestedRules;
  final List<String> insights;
  final int recommendedDailyLimit;
  final String recommendedBedtime;

  ScreenTimeSuggestion({
    required this.summary,
    required this.suggestedRules,
    required this.insights,
    required this.recommendedDailyLimit,
    required this.recommendedBedtime,
  });

  factory ScreenTimeSuggestion.fromJson(Map<String, dynamic> json) {
    return ScreenTimeSuggestion(
      summary: json['summary'] as String,
      suggestedRules: (json['suggested_rules'] as List)
          .map((e) => SuggestedRule.fromJson(e as Map<String, dynamic>))
          .toList(),
      insights: List<String>.from(json['insights'] ?? []),
      recommendedDailyLimit: json['recommended_daily_limit'] as int,
      recommendedBedtime: json['recommended_bedtime'] as String,
    );
  }
}

/// Preset screen time modes
enum ScreenTimeMode {
  homework,
  bedtime,
  freeTime,
  school,
  custom,
}

/// Active rule
class ScreenTimeRule {
  final String id;
  final String name;
  final String description;
  final ScreenTimeMode mode;
  final String startTime;
  final String endTime;
  final List<String> allowedCategories;
  final List<String> blockedCategories;
  final int? dailyLimitMinutes;
  final bool isActive;
  final List<int> activeDays; // 0=Mon, 6=Sun

  ScreenTimeRule({
    required this.id,
    required this.name,
    required this.description,
    required this.mode,
    required this.startTime,
    required this.endTime,
    required this.allowedCategories,
    required this.blockedCategories,
    this.dailyLimitMinutes,
    this.isActive = false,
    this.activeDays = const [0, 1, 2, 3, 4, 5, 6],
  });

  ScreenTimeRule copyWith({
    String? id,
    String? name,
    String? description,
    ScreenTimeMode? mode,
    String? startTime,
    String? endTime,
    List<String>? allowedCategories,
    List<String>? blockedCategories,
    int? dailyLimitMinutes,
    bool? isActive,
    List<int>? activeDays,
  }) {
    return ScreenTimeRule(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      mode: mode ?? this.mode,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      allowedCategories: allowedCategories ?? this.allowedCategories,
      blockedCategories: blockedCategories ?? this.blockedCategories,
      dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
      isActive: isActive ?? this.isActive,
      activeDays: activeDays ?? this.activeDays,
    );
  }
}
