/// Data models for Weekly AI Reports
/// Matches the backend API response structure
library;

/// Category statistics from the report
class CategoryStat {
  final String name;
  final int totalMinutes;
  final double percentage;
  final String trend; // "up", "down", "stable"

  CategoryStat({
    required this.name,
    required this.totalMinutes,
    required this.percentage,
    required this.trend,
  });

  factory CategoryStat.fromJson(Map<String, dynamic> json) {
    return CategoryStat(
      name: json['name'] as String,
      totalMinutes: json['total_minutes'] as int,
      percentage: (json['percentage'] as num).toDouble(),
      trend: json['trend'] as String,
    );
  }
}

/// Top app usage data
class TopApp {
  final String appName;
  final String category;
  final int totalMinutes;
  final double percentage;

  TopApp({
    required this.appName,
    required this.category,
    required this.totalMinutes,
    required this.percentage,
  });

  factory TopApp.fromJson(Map<String, dynamic> json) {
    return TopApp(
      appName: json['app_name'] as String,
      category: json['category'] as String,
      totalMinutes: json['total_minutes'] as int,
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}

/// Daily statistics
class DailyStats {
  final String date;
  final int totalMinutes;
  final Map<String, int> categoryBreakdown;

  DailyStats({
    required this.date,
    required this.totalMinutes,
    required this.categoryBreakdown,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      date: json['date'] as String,
      totalMinutes: json['total_minutes'] as int,
      categoryBreakdown: Map<String, int>.from(json['category_breakdown'] as Map),
    );
  }
}

/// Complete weekly report response
class WeeklyReport {
  // Basic info
  final String childName;
  final String weekStart;
  final String weekEnd;
  final String generatedAt;

  // Stats
  final int totalScreenTimeMinutes;
  final int dailyAverageMinutes;
  final int safetyScore; // 1-100

  // Breakdowns
  final List<DailyStats> dailyStats;
  final List<TopApp> topApps;
  final List<CategoryStat> categoryStats;

  // AI-generated content
  final String executiveSummary;
  final List<String> keyObservations;
  final List<String> concerns;
  final List<String> positiveHighlights;
  final List<String> recommendations;

  WeeklyReport({
    required this.childName,
    required this.weekStart,
    required this.weekEnd,
    required this.generatedAt,
    required this.totalScreenTimeMinutes,
    required this.dailyAverageMinutes,
    required this.safetyScore,
    required this.dailyStats,
    required this.topApps,
    required this.categoryStats,
    required this.executiveSummary,
    required this.keyObservations,
    required this.concerns,
    required this.positiveHighlights,
    required this.recommendations,
  });

  factory WeeklyReport.fromJson(Map<String, dynamic> json) {
    return WeeklyReport(
      childName: json['child_name'] as String,
      weekStart: json['week_start'] as String,
      weekEnd: json['week_end'] as String,
      generatedAt: json['generated_at'] as String,
      totalScreenTimeMinutes: json['total_screen_time_minutes'] as int,
      dailyAverageMinutes: json['daily_average_minutes'] as int,
      safetyScore: json['safety_score'] as int,
      dailyStats: (json['daily_stats'] as List)
          .map((e) => DailyStats.fromJson(e as Map<String, dynamic>))
          .toList(),
      topApps: (json['top_apps'] as List)
          .map((e) => TopApp.fromJson(e as Map<String, dynamic>))
          .toList(),
      categoryStats: (json['category_stats'] as List)
          .map((e) => CategoryStat.fromJson(e as Map<String, dynamic>))
          .toList(),
      executiveSummary: json['executive_summary'] as String,
      keyObservations: List<String>.from(json['key_observations'] as List),
      concerns: List<String>.from(json['concerns'] as List),
      positiveHighlights: List<String>.from(json['positive_highlights'] as List),
      recommendations: List<String>.from(json['recommendations'] as List),
    );
  }

  /// Get formatted total screen time (e.g., "12h 30m")
  String get formattedTotalTime {
    final hours = totalScreenTimeMinutes ~/ 60;
    final minutes = totalScreenTimeMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Get formatted daily average (e.g., "1h 45m/day")
  String get formattedDailyAverage {
    final hours = dailyAverageMinutes ~/ 60;
    final minutes = dailyAverageMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m/day';
    }
    return '${minutes}m/day';
  }

  /// Get safety score color based on value
  String get safetyScoreGrade {
    if (safetyScore >= 80) return 'Excellent';
    if (safetyScore >= 60) return 'Good';
    if (safetyScore >= 40) return 'Fair';
    return 'Needs Attention';
  }
}
