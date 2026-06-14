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

/// Helper class to hold aggregated metrics
class _ActivityMetrics {
  int totalMinutes = 0;
  int gamingMinutes = 0;
  int educationMinutes = 0;
  int socialMinutes = 0;
  int lateNightMinutes = 0;
  final Set<String> activeDays = {};
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

    // ⚡ BOLT OPTIMIZATION: Consolidate multiple O(N) traversals into single-pass aggregations.
    // This reduces the complexity from ~10 passes to just 2 (one for today, one for history).

    // 1. Aggregate today's data in a single pass
    final todayMetrics = _ActivityMetrics();
    for (final log in todayData) {
      if (log.childId != childId) continue;

      final minutes = log.screenTime;
      todayMetrics.totalMinutes += minutes;

      if (log.category == ActivityCategory.gaming) todayMetrics.gamingMinutes += minutes;
      if (log.category == ActivityCategory.education) todayMetrics.educationMinutes += minutes;
      if (log.category == ActivityCategory.social) todayMetrics.socialMinutes += minutes;

      if (log.timestamp.hour >= 22 || log.timestamp.hour < 6) {
        todayMetrics.lateNightMinutes += minutes;
      }
    }
    
    // 2. Aggregate historical data (last 7 days) in a single pass
    final historicalMetrics = _ActivityMetrics();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    
    for (final log in historicalData) {
      if (log.childId != childId || log.timestamp.isBefore(sevenDaysAgo)) continue;

      final minutes = log.screenTime;
      historicalMetrics.totalMinutes += minutes;

      if (log.category == ActivityCategory.education) historicalMetrics.educationMinutes += minutes;
      if (log.category == ActivityCategory.social) historicalMetrics.socialMinutes += minutes;

      final dayKey = '${log.timestamp.year}-${log.timestamp.month}-${log.timestamp.day}';
      historicalMetrics.activeDays.add(dayKey);
    }
    
    // Calculate averages
    final dayCount = historicalMetrics.activeDays.isEmpty ? 1 : historicalMetrics.activeDays.length;
    final avgDailyScreenTime = historicalMetrics.totalMinutes / dayCount;
    final avgDailyEducation = historicalMetrics.educationMinutes / 7; // Matching original logic of dividing by 7
    final avgDailySocial = historicalMetrics.socialMinutes / 7; // Matching original logic of dividing by 7
    
    // 1. Check for usage anomaly
    if (avgDailyScreenTime > 0) {
      final percentageChange = ((todayMetrics.totalMinutes - avgDailyScreenTime) / avgDailyScreenTime) * 100;
      
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
    
    // 2. Check Gaming vs Education ratio
    final gamingInsight = _checkGamingEducationRatio(childId, childName, todayMetrics);
    if (gamingInsight != null) insights.add(gamingInsight);
    
    // 3. Check for positive education trends
    final educationInsight = _checkEducationProgress(childId, childName, avgDailyEducation, todayMetrics.educationMinutes);
    if (educationInsight != null) insights.add(educationInsight);
    
    // 4. Check for late-night usage
    final lateNightInsight = _checkLateNightUsage(childId, childName, todayMetrics.lateNightMinutes);
    if (lateNightInsight != null) insights.add(lateNightInsight);
    
    // 5. Check social media trends
    final socialInsight = _checkSocialMediaTrends(childId, childName, avgDailySocial, todayMetrics.socialMinutes);
    if (socialInsight != null) insights.add(socialInsight);
    
    return insights;
  }
  
  /// Check if Gaming exceeds Education by 3:1 ratio
  static Insight? _checkGamingEducationRatio(String childId, String childName, _ActivityMetrics metrics) {
    final gamingTime = metrics.gamingMinutes;
    final educationTime = metrics.educationMinutes;
    
    if (educationTime > 0 && gamingTime > educationTime * 3) {
      final ratio = (gamingTime / educationTime).toStringAsFixed(1);
      return Insight(
        id: 'gaming_ratio_${childId}_${DateTime.now().millisecondsSinceEpoch}',
        childId: childId,
        childName: childName,
        type: InsightType.warning,
        title: 'Gaming Imbalance',
        message: '$childName has spent ${ratio}x more time gaming than on educational content today.',
        recommendation: 'Try balancing with some educational apps or reading time.',
        timestamp: DateTime.now(),
      );
    } else if (educationTime > gamingTime * 2 && educationTime > 30) {
      return Insight(
        id: 'education_win_${childId}_${DateTime.now().millisecondsSinceEpoch}',
        childId: childId,
        childName: childName,
        type: InsightType.positive,
        title: 'Learning Champion!',
        message: '$childName prioritized education over gaming today - $educationTime mins of learning!',
        recommendation: 'Great balance! Consider a fun reward.',
        timestamp: DateTime.now(),
      );
    }
    
    return null;
  }
  
  /// Check for positive education progress
  static Insight? _checkEducationProgress(String childId, String childName, double avgDailyEducation, int todayEducation) {
    if (avgDailyEducation > 0 && todayEducation > avgDailyEducation * 1.2) {
      final increase = ((todayEducation - avgDailyEducation) / avgDailyEducation * 100).toStringAsFixed(0);
      return Insight(
        id: 'education_up_${childId}_${DateTime.now().millisecondsSinceEpoch}',
        childId: childId,
        childName: childName,
        type: InsightType.positive,
        title: 'Extra Learning Today!',
        message: '$childName spent $increase% more time on educational apps than usual!',
        recommendation: 'Fantastic focus! Keep encouraging this habit.',
        timestamp: DateTime.now(),
        percentageChange: double.tryParse(increase),
      );
    }
    
    return null;
  }
  
  /// Check for late-night device usage
  static Insight? _checkLateNightUsage(String childId, String childName, int lateNightUsage) {
    if (lateNightUsage > 30) {
      return Insight(
        id: 'late_night_${childId}_${DateTime.now().millisecondsSinceEpoch}',
        childId: childId,
        childName: childName,
        type: InsightType.warning,
        title: 'Late Night Activity',
        message: '$childName used their device for $lateNightUsage minutes during sleep hours.',
        recommendation: 'Consider enabling bedtime mode to ensure healthy sleep.',
        timestamp: DateTime.now(),
      );
    }
    
    return null;
  }
  
  /// Check social media usage trends
  static Insight? _checkSocialMediaTrends(String childId, String childName, double avgDailySocial, int todaySocial) {
    if (avgDailySocial > 0 && todaySocial > avgDailySocial * 1.4) {
      final increase = ((todaySocial - avgDailySocial) / avgDailySocial * 100).toStringAsFixed(0);
      return Insight(
        id: 'social_spike_${childId}_${DateTime.now().millisecondsSinceEpoch}',
        childId: childId,
        childName: childName,
        type: InsightType.warning,
        title: 'Social Media Surge',
        message: '$childName is spending $increase% more time on social media than their weekly average.',
        recommendation: 'Consider a digital detox break!',
        timestamp: DateTime.now(),
        percentageChange: double.tryParse(increase),
      );
    }
    
    return null;
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
