import 'package:flutter_test/flutter_test.dart';
import 'package:child_safety_monitor/services/insights_engine.dart';
import 'package:child_safety_monitor/data/models/activity_log.dart';

void main() {
  group('InsightsEngine Tests', () {
    final now = DateTime.now();
    const childId = 'child_1';
    const childName = 'Test Child';

    test('generateDailyInsights detects usage spike (anomaly)', () {
      // Average is 60 mins/day
      final historicalData = List.generate(7, (index) => ActivityLog(
        id: 'h_$index',
        childId: childId,
        screenTime: 60,
        timestamp: now.subtract(Duration(days: index + 1)),
        category: ActivityCategory.other,
      ));

      final todayData = [
        ActivityLog(
          id: 't_1',
          childId: childId,
          screenTime: 100, // > 30% increase (60 * 1.3 = 78)
          timestamp: now,
          category: ActivityCategory.other,
        ),
      ];

      final insights = InsightsEngine.generateDailyInsights(
        childId: childId,
        childName: childName,
        historicalData: historicalData,
        todayData: todayData,
      );

      final hasSpike = insights.any((i) => i.type == InsightType.anomaly && i.title.contains('Usage Spike'));
      expect(hasSpike, isTrue);
    });

    test('generateDailyInsights detects great progress (positive)', () {
      // Average is 100 mins/day
      final historicalData = List.generate(7, (index) => ActivityLog(
        id: 'h_$index',
        childId: childId,
        screenTime: 100,
        timestamp: now.subtract(Duration(days: index + 1)),
        category: ActivityCategory.other,
      ));

      final todayData = [
        ActivityLog(
          id: 't_1',
          childId: childId,
          screenTime: 50, // 50% decrease
          timestamp: now,
          category: ActivityCategory.other,
        ),
      ];

      final insights = InsightsEngine.generateDailyInsights(
        childId: childId,
        childName: childName,
        historicalData: historicalData,
        todayData: todayData,
      );

      final hasProgress = insights.any((i) => i.type == InsightType.positive && i.title == 'Great Progress!');
      expect(hasProgress, isTrue);
    });

    test('generateDailyInsights detects gaming imbalance', () {
      final historicalData = <ActivityLog>[];
      final todayData = [
        ActivityLog(
          id: 't_g',
          childId: childId,
          screenTime: 120,
          timestamp: now,
          category: ActivityCategory.gaming,
        ),
        ActivityLog(
          id: 't_e',
          childId: childId,
          screenTime: 30, // 120 > 30 * 3
          timestamp: now,
          category: ActivityCategory.education,
        ),
      ];

      final insights = InsightsEngine.generateDailyInsights(
        childId: childId,
        childName: childName,
        historicalData: historicalData,
        todayData: todayData,
      );

      final hasImbalance = insights.any((i) => i.title == 'Gaming Imbalance');
      expect(hasImbalance, isTrue);
    });

    test('generateDailyInsights detects extra learning (positive education)', () {
      // Average education is 30 mins/day
      final historicalData = List.generate(7, (index) => ActivityLog(
        id: 'h_$index',
        childId: childId,
        screenTime: 30,
        timestamp: now.subtract(Duration(days: index + 1)),
        category: ActivityCategory.education,
      ));

      final todayData = [
        ActivityLog(
          id: 't_1',
          childId: childId,
          screenTime: 50, // > 30 * 1.2 = 36
          timestamp: now,
          category: ActivityCategory.education,
        ),
      ];

      final insights = InsightsEngine.generateDailyInsights(
        childId: childId,
        childName: childName,
        historicalData: historicalData,
        todayData: todayData,
      );

      final hasLearning = insights.any((i) => i.title == 'Extra Learning Today!');
      expect(hasLearning, isTrue);
    });

    test('generateDailyInsights detects late night activity', () {
      final historicalData = <ActivityLog>[];
      final todayData = [
        ActivityLog(
          id: 't_ln',
          childId: childId,
          screenTime: 40, // > 30 mins
          timestamp: DateTime(now.year, now.month, now.day, 23, 0),
          category: ActivityCategory.social,
        ),
      ];

      final insights = InsightsEngine.generateDailyInsights(
        childId: childId,
        childName: childName,
        historicalData: historicalData,
        todayData: todayData,
      );

      final hasLateNight = insights.any((i) => i.title == 'Late Night Activity');
      expect(hasLateNight, isTrue);
    });

    test('generateDailyInsights detects social media surge', () {
      // Average social is 30 mins/day
      final historicalData = List.generate(7, (index) => ActivityLog(
        id: 'h_$index',
        childId: childId,
        screenTime: 30,
        timestamp: now.subtract(Duration(days: index + 1)),
        category: ActivityCategory.social,
      ));

      final todayData = [
        ActivityLog(
          id: 't_1',
          childId: childId,
          screenTime: 50, // > 30 * 1.4 = 42
          timestamp: now,
          category: ActivityCategory.social,
        ),
      ];

      final insights = InsightsEngine.generateDailyInsights(
        childId: childId,
        childName: childName,
        historicalData: historicalData,
        todayData: todayData,
      );

      final hasSocialSurge = insights.any((i) => i.title == 'Social Media Surge');
      expect(hasSocialSurge, isTrue);
    });
  });
}
