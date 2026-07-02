import 'package:child_safety_monitor/data/models/activity_log.dart';

/// Insight types for categorization
enum InsightType {
  warning,    // Yellow - concerning trends
  positive,   // Green - good behavior
  anomaly,    // Red - significant deviation
  neutral,    // Blue - informational
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

/// Internal helper for aggregated activity metrics to avoid multiple O(N) passes
class _ActivityMetrics {
  double avgDailyScreenTime = 0;
  int todayTotal = 0;
  int todayGaming = 0;
  int todayEducation = 0;
  int todaySocial = 0;
  int todayLateNight = 0;
  double avgDailyEducation = 0;
  double avgDailySocial = 0;
}

/// AI Insights Engine - Analyzes activity patterns and generates insights
class InsightsEngine {
  
  /// Generate daily insights by comparing today's data with historical averages
  static List<Insight> generateDailyInsights({
    required String childId,
    required String childName,
    required List<ActivityLog> historicalData,
    required List<ActivityLog> todayData,
  }) {
    final insights = <Insight>[];
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    
    // SINGLE PASS OPTIMIZATION: Aggregate all metrics in one go instead of multiple filter/fold operations
    final metrics = _ActivityMetrics();
    
    // 1. Process historical data (O(N))
    final dailyTotals = <String, int>{};
    int totalHistEducation = 0;
    int totalHistSocial = 0;
    
    for (final log in historicalData) {
      if (log.childId != childId || !log.timestamp.isAfter(sevenDaysAgo)) continue;

      final dayKey = '${log.timestamp.year}-${log.timestamp.month}-${log.timestamp.day}';
      dailyTotals[dayKey] = (dailyTotals[dayKey] ?? 0) + log.screenTime;

      if (log.category == ActivityCategory.education) {
        totalHistEducation += log.screenTime;
      } else if (log.category == ActivityCategory.social) {
        totalHistSocial += log.screenTime;
      }
    }

    if (dailyTotals.isNotEmpty) {
      metrics.avgDailyScreenTime = dailyTotals.values.reduce((a, b) => a + b) / dailyTotals.length;
    }
    metrics.avgDailyEducation = totalHistEducation / 7;
    metrics.avgDailySocial = totalHistSocial / 7;
    
    // 2. Process today's data (O(N))
    for (final log in todayData) {
      if (log.childId != childId) continue;

      metrics.todayTotal += log.screenTime;

      if (log.category == ActivityCategory.gaming) {
        metrics.todayGaming += log.screenTime;
      } else if (log.category == ActivityCategory.education) {
        metrics.todayEducation += log.screenTime;
      } else if (log.category == ActivityCategory.social) {
        metrics.todaySocial += log.screenTime;
      }

      if (log.timestamp.hour >= 22 || log.timestamp.hour < 6) {
        metrics.todayLateNight += log.screenTime;
      }
    }

    // 3. Generate insights using pre-calculated metrics

    // Usage anomaly
    if (metrics.avgDailyScreenTime > 0) {
      final percentageChange = ((metrics.todayTotal - metrics.avgDailyScreenTime) / metrics.avgDailyScreenTime) * 100;
      
      if (percentageChange > 30) {
        insights.add(Insight(
          id: 'anomaly_${childId}_${now.millisecondsSinceEpoch}',
          childId: childId,
          childName: childName,
          type: InsightType.anomaly,
          title: 'Usage Spike Detected',
          message: '$childName is spending ${percentageChange.toStringAsFixed(0)}% more screen time than their weekly average.',
          recommendation: 'Consider setting a screen time limit or encouraging a break.',
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
          message: '$childName has reduced screen time by ${percentageChange.abs().toStringAsFixed(0)}% compared to their weekly average!',
          recommendation: 'Keep up the healthy digital habits!',
          timestamp: now,
          percentageChange: percentageChange,
        ));
      }
    }
    
    // Gaming vs Education ratio
    if (metrics.todayEducation > 0 && metrics.todayGaming > metrics.todayEducation * 3) {
      final ratio = (metrics.todayGaming / metrics.todayEducation).toStringAsFixed(1);
      insights.add(Insight(
        id: 'gaming_ratio_${childId}_${now.millisecondsSinceEpoch}',
        childId: childId,
        childName: childName,
        type: InsightType.warning,
        title: 'Gaming Imbalance',
        message: '$childName has spent ${ratio}x more time gaming than on educational content today.',
        recommendation: 'Try balancing with some educational apps or reading time.',
        timestamp: now,
      ));
    } else if (metrics.todayEducation > metrics.todayGaming * 2 && metrics.todayEducation > 30) {
      insights.add(Insight(
        id: 'education_win_${childId}_${now.millisecondsSinceEpoch}',
        childId: childId,
        childName: childName,
        type: InsightType.positive,
        title: 'Learning Champion!',
        message: '$childName prioritized education over gaming today - ${metrics.todayEducation} mins of learning!',
        recommendation: 'Great balance! Consider a fun reward.',
        timestamp: now,
      ));
    }
    
    // Education progress
    if (metrics.avgDailyEducation > 0 && metrics.todayEducation > metrics.avgDailyEducation * 1.2) {
      final increase = ((metrics.todayEducation - metrics.avgDailyEducation) / metrics.avgDailyEducation * 100).toStringAsFixed(0);
      insights.add(Insight(
        id: 'education_up_${childId}_${now.millisecondsSinceEpoch}',
        childId: childId,
        childName: childName,
        type: InsightType.positive,
        title: 'Extra Learning Today!',
        message: '$childName spent $increase% more time on educational apps than usual!',
        recommendation: 'Fantastic focus! Keep encouraging this habit.',
        timestamp: now,
        percentageChange: double.tryParse(increase),
      ));
    }
    
    // Late-night usage
    if (metrics.todayLateNight > 30) {
      insights.add(Insight(
        id: 'late_night_${childId}_${now.millisecondsSinceEpoch}',
        childId: childId,
        childName: childName,
        type: InsightType.warning,
        title: 'Late Night Activity',
        message: '$childName used their device for ${metrics.todayLateNight} minutes during sleep hours.',
        recommendation: 'Consider enabling bedtime mode to ensure healthy sleep.',
        timestamp: now,
      ));
    }
    
    // Social media trends
    if (metrics.avgDailySocial > 0 && metrics.todaySocial > metrics.avgDailySocial * 1.4) {
      final increase = ((metrics.todaySocial - metrics.avgDailySocial) / metrics.avgDailySocial * 100).toStringAsFixed(0);
      insights.add(Insight(
        id: 'social_spike_${childId}_${now.millisecondsSinceEpoch}',
        childId: childId,
        childName: childName,
        type: InsightType.warning,
        title: 'Social Media Surge',
        message: '$childName is spending $increase% more time on social media than their weekly average.',
        recommendation: 'Consider a digital detox break!',
        timestamp: now,
        percentageChange: double.tryParse(increase),
      ));
    }
    
    return insights;
  }
  
  /// Generate demo insights for testing/presentation
  static List<Insight> generateDemoInsights() {
    final now = DateTime.now();
    return [
      Insight(
        id: 'demo_1',
        childId: '1',
        childName: 'Ananya',
        type: InsightType.warning,
        title: 'Social Media Surge',
        message: 'Ananya is spending 40% more time on Moj than her weekly average.',
        recommendation: 'Consider a break!',
        timestamp: now,
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
        timestamp: now,
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
        timestamp: now,
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
        timestamp: now,
        percentageChange: 100,
      ),
    ];
  }
}
