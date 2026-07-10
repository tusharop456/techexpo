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

/// AI Insights Engine - Analyzes activity patterns and generates insights
class InsightsEngine {
  
  /// Generate daily insights by comparing today's data with historical averages
  /// Optimized with a single-pass aggregation pattern O(N)
  static List<Insight> generateDailyInsights({
    required String childId,
    required String childName,
    required List<ActivityLog> historicalData,
    required List<ActivityLog> todayData,
  }) {
    final insights = <Insight>[];
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    
    // BOLT OPTIMIZATION: Single-pass aggregation for both datasets
    final history = _AggregationStats();
    final dailyTotals = <String, int>{};
    
    for (final log in historicalData) {
      if (log.childId != childId || !log.timestamp.isAfter(sevenDaysAgo)) continue;

      history.totalTime += log.screenTime;
      if (log.category == ActivityCategory.education) history.educationTime += log.screenTime;
      if (log.category == ActivityCategory.social) history.socialTime += log.screenTime;

      final dayKey = '${log.timestamp.year}-${log.timestamp.month}-${log.timestamp.day}';
      dailyTotals[dayKey] = (dailyTotals[dayKey] ?? 0) + log.screenTime;
    }
    
    final today = _AggregationStats();
    for (final log in todayData) {
      if (log.childId != childId) continue;
      
      today.totalTime += log.screenTime;
      if (log.category == ActivityCategory.gaming) today.gamingTime += log.screenTime;
      if (log.category == ActivityCategory.education) today.educationTime += log.screenTime;
      if (log.category == ActivityCategory.social) today.socialTime += log.screenTime;

      if (log.timestamp.hour >= 22 || log.timestamp.hour < 6) {
        today.lateNightTime += log.screenTime;
      }
    }

    final avgDailyTotal = dailyTotals.isEmpty ? 0.0 : history.totalTime / dailyTotals.length;
    final avgDailyEducation = history.educationTime / 7.0;
    final avgDailySocial = history.socialTime / 7.0;

    // 1. Usage Anomaly
    if (avgDailyTotal > 0) {
      final percentageChange = ((today.totalTime - avgDailyTotal) / avgDailyTotal) * 100;
      if (percentageChange > 30) {
        insights.add(Insight(
          id: 'anomaly_${childId}_${now.millisecondsSinceEpoch}',
          childId: childId, childName: childName, type: InsightType.anomaly,
          title: 'Usage Spike Detected',
          message: '$childName is spending ${percentageChange.toStringAsFixed(0)}% more screen time than their weekly average.',
          recommendation: 'Consider setting a screen time limit or encouraging a break.',
          timestamp: now, percentageChange: percentageChange,
        ));
      } else if (percentageChange < -20) {
        insights.add(Insight(
          id: 'positive_${childId}_${now.millisecondsSinceEpoch}',
          childId: childId, childName: childName, type: InsightType.positive,
          title: 'Great Progress!',
          message: '$childName has reduced screen time by ${percentageChange.abs().toStringAsFixed(0)}% compared to their weekly average!',
          recommendation: 'Keep up the healthy digital habits!',
          timestamp: now, percentageChange: percentageChange,
        ));
      }
    }

    // 2. Gaming vs Education ratio
    if (today.educationTime > 0 && today.gamingTime > today.educationTime * 3) {
      final ratio = (today.gamingTime / today.educationTime).toStringAsFixed(1);
      insights.add(Insight(
        id: 'gaming_ratio_${childId}_${now.millisecondsSinceEpoch}',
        childId: childId, childName: childName, type: InsightType.warning,
        title: 'Gaming Imbalance',
        message: '$childName has spent ${ratio}x more time gaming than on educational content today.',
        recommendation: 'Try balancing with some educational apps or reading time.',
        timestamp: now,
      ));
    } else if (today.educationTime > today.gamingTime * 2 && today.educationTime > 30) {
      insights.add(Insight(
        id: 'education_win_${childId}_${now.millisecondsSinceEpoch}',
        childId: childId, childName: childName, type: InsightType.positive,
        title: 'Learning Champion!',
        message: '$childName prioritized education over gaming today - ${today.educationTime} mins of learning!',
        recommendation: 'Great balance! Consider a fun reward.',
        timestamp: now,
      ));
    }

    // 3. Education progress
    if (avgDailyEducation > 0 && today.educationTime > avgDailyEducation * 1.2) {
      final increase = ((today.educationTime - avgDailyEducation) / avgDailyEducation * 100).toStringAsFixed(0);
      insights.add(Insight(
        id: 'education_up_${childId}_${now.millisecondsSinceEpoch}',
        childId: childId, childName: childName, type: InsightType.positive,
        title: 'Extra Learning Today!',
        message: '$childName spent $increase% more time on educational apps than usual!',
        recommendation: 'Fantastic focus! Keep encouraging this habit.',
        timestamp: now, percentageChange: double.tryParse(increase),
      ));
    }

    // 4. Late-night usage
    if (today.lateNightTime > 30) {
      insights.add(Insight(
        id: 'late_night_${childId}_${now.millisecondsSinceEpoch}',
        childId: childId, childName: childName, type: InsightType.warning,
        title: 'Late Night Activity',
        message: '$childName used their device for ${today.lateNightTime} minutes during sleep hours.',
        recommendation: 'Consider enabling bedtime mode to ensure healthy sleep.',
        timestamp: now,
      ));
    }

    // 5. Social media trends
    if (avgDailySocial > 0 && today.socialTime > avgDailySocial * 1.4) {
      final increase = ((today.socialTime - avgDailySocial) / avgDailySocial * 100).toStringAsFixed(0);
      insights.add(Insight(
        id: 'social_spike_${childId}_${now.millisecondsSinceEpoch}',
        childId: childId, childName: childName, type: InsightType.warning,
        title: 'Social Media Surge',
        message: '$childName is spending $increase% more time on social media than their weekly average.',
        recommendation: 'Consider a digital detox break!',
        timestamp: now, percentageChange: double.tryParse(increase),
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

/// BOLT: Private class for efficient aggregation
class _AggregationStats {
  int totalTime = 0;
  int gamingTime = 0;
  int educationTime = 0;
  int socialTime = 0;
  int lateNightTime = 0;
}
