import 'package:child_safety_monitor/data/models/activity_log.dart';

/// Insight types for categorization
enum InsightType {
  warning, // Yellow - concerning trends
  positive, // Green - good behavior
  anomaly, // Red - significant deviation
  neutral, // Blue - informational
}

/// Represents a single AI-generated insight
class Insight {
  final String id;
  final String childId;
  final String childName;
  final InsightType type;
  final String title;
  final String message;
  final String? recommendation;
  final DateTime timestamp;
  final double? percentageChange;

  Insight({
    required this.id,
    required this.childId,
    required this.childName,
    required this.type,
    required this.title,
    required this.message,
    this.recommendation,
    required this.timestamp,
    this.percentageChange,
  });
}

/// Internal helper to aggregate activity metrics in a single pass
/// BOLT OPTIMIZATION: Reduces multiple O(N) traversals to a single pass
class _ActivityMetrics {
  int totalScreenTime = 0;
  int gamingTime = 0;
  int educationTime = 0;
  int socialTime = 0;
  int lateNightTime = 0;
  final Map<String, int> dailyTotals = {};

  void addLog(ActivityLog log) {
    totalScreenTime += log.screenTime;
    if (log.category == ActivityCategory.gaming) gamingTime += log.screenTime;
    if (log.category == ActivityCategory.education) educationTime += log.screenTime;
    if (log.category == ActivityCategory.social) socialTime += log.screenTime;

    if (log.timestamp.hour >= 22 || log.timestamp.hour < 6) {
      lateNightTime += log.screenTime;
    }

    final dayKey =
        '${log.timestamp.year}-${log.timestamp.month}-${log.timestamp.day}';
    dailyTotals[dayKey] = (dailyTotals[dayKey] ?? 0) + log.screenTime;
  }

  double get averageDailyScreenTime =>
      dailyTotals.isEmpty ? 0 : totalScreenTime / dailyTotals.length;

  // For weekly averages where we divide by a fixed 7 days
  double get averageWeeklyEducation => educationTime / 7;
  double get averageWeeklySocial => socialTime / 7;
}

/// AI Insights Engine - Analyzes activity patterns and generates insights
class InsightsEngine {
  /// Generate daily insights by comparing today's data with historical averages
  /// BOLT OPTIMIZATION: Refactored to use single-pass aggregation for performance
  static List<Insight> generateDailyInsights({
    required String childId,
    required String childName,
    required List<ActivityLog> historicalData,
    required List<ActivityLog> todayData,
  }) {
    final insights = <Insight>[];
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    // 1. Aggregate Historical Data (Single Pass)
    final historicalMetrics = _ActivityMetrics();
    for (final log in historicalData) {
      if (log.childId == childId && log.timestamp.isAfter(sevenDaysAgo)) {
        historicalMetrics.addLog(log);
      }
    }

    // 2. Aggregate Today's Data (Single Pass)
    final todayMetrics = _ActivityMetrics();
    for (final log in todayData) {
      if (log.childId == childId) {
        todayMetrics.addLog(log);
      }
    }

    // --- Insight Generation Logic (Using Pre-Aggregated Metrics) ---

    // 1. Usage Anomaly
    final avgDailyHistorical = historicalMetrics.averageDailyScreenTime;
    if (avgDailyHistorical > 0) {
      final percentageChange =
          ((todayMetrics.totalScreenTime - avgDailyHistorical) /
                  avgDailyHistorical) *
              100;

      if (percentageChange > 30) {
        insights.add(Insight(
          id: 'anomaly_${childId}_${now.millisecondsSinceEpoch}',
          childId: childId,
          childName: childName,
          type: InsightType.anomaly,
          title: 'Usage Spike Detected',
          message:
              '$childName is spending ${percentageChange.toStringAsFixed(0)}% more screen time than their weekly average.',
          recommendation:
              'Consider setting a screen time limit or encouraging a break.',
          timestamp: now,
          percentageChange: percentageChange,
        ));
      } else if (percentageChange < -20) {
        insights.add(Insight(
          id: 'positive_${childId}_${now.millisecondsSinceEpoch}',
          childId: childId,
          childName: childName,
          type: InsightType.positive,
          title: 'Great Progress!',
          message:
              '$childName has reduced screen time by ${percentageChange.abs().toStringAsFixed(0)}% compared to their weekly average!',
          recommendation: 'Keep up the healthy digital habits!',
          timestamp: now,
          percentageChange: percentageChange,
        ));
      }
    }

    // 2. Gaming vs Education ratio
    if (todayMetrics.educationTime > 0 &&
        todayMetrics.gamingTime > todayMetrics.educationTime * 3) {
      final ratio =
          (todayMetrics.gamingTime / todayMetrics.educationTime).toStringAsFixed(1);
      insights.add(Insight(
        id: 'gaming_ratio_${childId}_${now.millisecondsSinceEpoch}',
        childId: childId,
        childName: childName,
        type: InsightType.warning,
        title: 'Gaming Imbalance',
        message:
            '$childName has spent ${ratio}x more time gaming than on educational content today.',
        recommendation:
            'Try balancing with some educational apps or reading time.',
        timestamp: now,
      ));
    } else if (todayMetrics.educationTime > todayMetrics.gamingTime * 2 &&
        todayMetrics.educationTime > 30) {
      insights.add(Insight(
        id: 'education_win_${childId}_${now.millisecondsSinceEpoch}',
        childId: childId,
        childName: childName,
        type: InsightType.positive,
        title: 'Learning Champion!',
        message:
            '$childName prioritized education over gaming today - ${todayMetrics.educationTime} mins of learning!',
        recommendation: 'Great balance! Consider a fun reward.',
        timestamp: now,
      ));
    }

    // 3. Education Progress
    final avgDailyEducation = historicalMetrics.averageWeeklyEducation;
    if (avgDailyEducation > 0 &&
        todayMetrics.educationTime > avgDailyEducation * 1.2) {
      final increase =
          ((todayMetrics.educationTime - avgDailyEducation) /
                  avgDailyEducation *
                  100)
              .toStringAsFixed(0);
      insights.add(Insight(
        id: 'education_up_${childId}_${now.millisecondsSinceEpoch}',
        childId: childId,
        childName: childName,
        type: InsightType.positive,
        title: 'Extra Learning Today!',
        message:
            '$childName spent $increase% more time on educational apps than usual!',
        recommendation: 'Fantastic focus! Keep encouraging this habit.',
        timestamp: now,
        percentageChange: double.tryParse(increase),
      ));
    }

    // 4. Late-night usage
    if (todayMetrics.lateNightTime > 30) {
      insights.add(Insight(
        id: 'late_night_${childId}_${now.millisecondsSinceEpoch}',
        childId: childId,
        childName: childName,
        type: InsightType.warning,
        title: 'Late Night Activity',
        message:
            '$childName used their device for ${todayMetrics.lateNightTime} minutes during sleep hours.',
        recommendation: 'Consider enabling bedtime mode to ensure healthy sleep.',
        timestamp: now,
      ));
    }

    // 5. Social media trends
    final avgDailySocial = historicalMetrics.averageWeeklySocial;
    if (avgDailySocial > 0 && todayMetrics.socialTime > avgDailySocial * 1.4) {
      final increase =
          ((todayMetrics.socialTime - avgDailySocial) / avgDailySocial * 100)
              .toStringAsFixed(0);
      insights.add(Insight(
        id: 'social_spike_${childId}_${now.millisecondsSinceEpoch}',
        childId: childId,
        childName: childName,
        type: InsightType.warning,
        title: 'Social Media Surge',
        message:
            '$childName is spending $increase% more time on social media than their weekly average.',
        recommendation: 'Consider a digital detox break!',
        timestamp: now,
        percentageChange: double.tryParse(increase),
      ));
    }

    return insights;
  }

  /// Generate demo insights for testing/presentation
  static List<Insight> generateDemoInsights() {
    return [
      Insight(
        id: 'demo_1',
        childId: '1',
        childName: 'Ananya',
        type: InsightType.warning,
        title: 'Social Media Surge',
        message: 'Ananya is spending 40% more time on Moj than her weekly average.',
        recommendation: 'Consider a break!',
        timestamp: DateTime.now(),
        percentageChange: 40,
      ),
      Insight(
        id: 'demo_2',
        childId: '2',
        childName: 'Arjun',
        type: InsightType.positive,
        title: 'Homework Hero!',
        message: 'Arjun finished his homework 20% faster today compared to last week!',
        recommendation: 'Great focus! Maybe reward with some game time.',
        timestamp: DateTime.now(),
        percentageChange: -20,
      ),
      Insight(
        id: 'demo_3',
        childId: '3',
        childName: 'Priya',
        type: InsightType.anomaly,
        title: 'Usage Spike Detected',
        message: 'Priya\'s screen time is 45% higher than usual today.',
        recommendation: 'Check in and see what\'s keeping her engaged.',
        timestamp: DateTime.now(),
        percentageChange: 45,
      ),
      Insight(
        id: 'demo_4',
        childId: '1',
        childName: 'Ananya',
        type: InsightType.positive,
        title: 'Learning Champion!',
        message: 'Ananya spent 2 hours on Khan Academy - double her weekly average!',
        recommendation: '🌟 Fantastic! Consider unlocking a new educational game.',
        timestamp: DateTime.now(),
        percentageChange: 100,
      ),
    ];
  }
}
