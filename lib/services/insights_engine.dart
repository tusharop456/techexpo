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
  static List<Insight> generateDailyInsights({
    required String childId,
    required String childName,
    required List<ActivityLog> historicalData,
    required List<ActivityLog> todayData,
  }) {
    final insights = <Insight>[];
    
    // Filter historical data to last 7 days
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final last7DaysData = historicalData.where((log) => 
      log.timestamp.isAfter(sevenDaysAgo) && log.childId == childId
    ).toList();
    
    // Calculate average daily screen time for last 7 days
    final avgDailyScreenTime = _calculateAverageDailyScreenTime(last7DaysData);
    
    // Calculate today's total screen time
    final todayTotal = todayData
      .where((log) => log.childId == childId)
      .fold<int>(0, (sum, log) => sum + log.screenTime);
    
    // 1. Check for usage anomaly (>30% higher than average)
    if (avgDailyScreenTime > 0) {
      final percentageChange = ((todayTotal - avgDailyScreenTime) / avgDailyScreenTime) * 100;
      
      if (percentageChange > 30) {
        insights.add(Insight(
          id: 'anomaly_${childId}_${DateTime.now().millisecondsSinceEpoch}',
          childId: childId,
          childName: childName,
          type: InsightType.anomaly,
          title: 'Usage Spike Detected',
          message: '$childName is spending ${percentageChange.toStringAsFixed(0)}% more screen time than their weekly average.',
          recommendation: 'Consider setting a screen time limit or encouraging a break.',
          timestamp: DateTime.now(),
          percentageChange: percentageChange,
        ));
      } else if (percentageChange < -20) {
        insights.add(Insight(
          id: 'positive_${childId}_${DateTime.now().millisecondsSinceEpoch}',
          childId: childId,
          childName: childName,
          type: InsightType.positive,
          title: 'Great Progress!',
          message: '$childName has reduced screen time by ${percentageChange.abs().toStringAsFixed(0)}% compared to their weekly average!',
          recommendation: 'Keep up the healthy digital habits!',
          timestamp: DateTime.now(),
          percentageChange: percentageChange,
        ));
      }
    }
    
    // 2. Check Gaming vs Education ratio
    final gamingInsight = _checkGamingEducationRatio(childId, childName, todayData);
    if (gamingInsight != null) {
      insights.add(gamingInsight);
    }
    
    // 3. Check for positive education trends
    final educationInsight = _checkEducationProgress(childId, childName, historicalData, todayData);
    if (educationInsight != null) {
      insights.add(educationInsight);
    }
    
    // 4. Check for late-night usage
    final lateNightInsight = _checkLateNightUsage(childId, childName, todayData);
    if (lateNightInsight != null) {
      insights.add(lateNightInsight);
    }
    
    // 5. Check social media trends
    final socialInsight = _checkSocialMediaTrends(childId, childName, historicalData, todayData);
    if (socialInsight != null) {
      insights.add(socialInsight);
    }
    
    return insights;
  }
  
  /// Calculate average daily screen time from historical data
  static double _calculateAverageDailyScreenTime(List<ActivityLog> data) {
    if (data.isEmpty) return 0;
    
    // Group by day and sum
    final dailyTotals = <String, int>{};
    for (final log in data) {
      final dayKey = '${log.timestamp.year}-${log.timestamp.month}-${log.timestamp.day}';
      dailyTotals[dayKey] = (dailyTotals[dayKey] ?? 0) + log.screenTime;
    }
    
    if (dailyTotals.isEmpty) return 0;
    return dailyTotals.values.reduce((a, b) => a + b) / dailyTotals.length;
  }
  
  /// Check if Gaming exceeds Education by 3:1 ratio
  static Insight? _checkGamingEducationRatio(String childId, String childName, List<ActivityLog> todayData) {
    final childData = todayData.where((log) => log.childId == childId);
    
    final gamingTime = childData
      .where((log) => log.category == ActivityCategory.gaming)
      .fold<int>(0, (sum, log) => sum + log.screenTime);
    
    final educationTime = childData
      .where((log) => log.category == ActivityCategory.education)
      .fold<int>(0, (sum, log) => sum + log.screenTime);
    
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
  static Insight? _checkEducationProgress(String childId, String childName, List<ActivityLog> historical, List<ActivityLog> today) {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    
    final historicalEducation = historical
      .where((log) => log.childId == childId && 
                      log.category == ActivityCategory.education &&
                      log.timestamp.isAfter(sevenDaysAgo))
      .fold<int>(0, (sum, log) => sum + log.screenTime);
    
    final avgDailyEducation = historicalEducation / 7;
    
    final todayEducation = today
      .where((log) => log.childId == childId && log.category == ActivityCategory.education)
      .fold<int>(0, (sum, log) => sum + log.screenTime);
    
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
  static Insight? _checkLateNightUsage(String childId, String childName, List<ActivityLog> todayData) {
    final lateNightUsage = todayData.where((log) => 
      log.childId == childId && 
      (log.timestamp.hour >= 22 || log.timestamp.hour < 6)
    ).fold<int>(0, (sum, log) => sum + log.screenTime);
    
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
  static Insight? _checkSocialMediaTrends(String childId, String childName, List<ActivityLog> historical, List<ActivityLog> today) {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    
    final historicalSocial = historical
      .where((log) => log.childId == childId && 
                      log.category == ActivityCategory.social &&
                      log.timestamp.isAfter(sevenDaysAgo))
      .fold<int>(0, (sum, log) => sum + log.screenTime);
    
    final avgDailySocial = historicalSocial / 7;
    
    final todaySocial = today
      .where((log) => log.childId == childId && log.category == ActivityCategory.social)
      .fold<int>(0, (sum, log) => sum + log.screenTime);
    
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
