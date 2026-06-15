import 'package:flutter_test/flutter_test.dart';
import 'package:child_safety_monitor/services/insights_engine.dart';
import 'package:child_safety_monitor/data/models/activity_log.dart';

void main() {
  group('InsightsEngine Tests', () {
    final now = DateTime.now();
    final childId = 'child_1';
    final childName = 'Test Child';

    test('generates usage anomaly insight (spike)', () {
      final historicalData = List.generate(
        7,
        (i) => ActivityLog(
          id: 'h_$i',
          childId: childId,
          screenTime: 60, // 60 mins per day
          timestamp: now.subtract(Duration(days: i + 1)),
          category: ActivityCategory.education,
        ),
      );

      final todayData = [
        ActivityLog(
          id: 't_1',
          childId: childId,
          screenTime: 120, // 100% increase over 60
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

      expect(insights.any((i) => i.type == InsightType.anomaly), isTrue);
    });

    test('generates gaming imbalance insight', () {
      final todayData = [
        ActivityLog(
          id: 't_1',
          childId: childId,
          screenTime: 120,
          timestamp: now,
          category: ActivityCategory.gaming,
        ),
        ActivityLog(
          id: 't_2',
          childId: childId,
          screenTime: 30,
          timestamp: now,
          category: ActivityCategory.education,
        ),
      ];

      final insights = InsightsEngine.generateDailyInsights(
        childId: childId,
        childName: childName,
        historicalData: [],
        todayData: todayData,
      );

      expect(insights.any((i) => i.title == 'Gaming Imbalance'), isTrue);
    });

    test('generates late night activity insight', () {
      final todayData = [
        ActivityLog(
          id: 't_1',
          childId: childId,
          screenTime: 40,
          timestamp: DateTime(now.year, now.month, now.day, 23, 0),
          category: ActivityCategory.entertainment,
        ),
      ];

      final insights = InsightsEngine.generateDailyInsights(
        childId: childId,
        childName: childName,
        historicalData: [],
        todayData: todayData,
      );

      expect(insights.any((i) => i.title == 'Late Night Activity'), isTrue);
    });

    test('generates social media surge insight', () {
      final historicalData = List.generate(
        7,
        (i) => ActivityLog(
          id: 'h_$i',
          childId: childId,
          screenTime: 20,
          timestamp: now.subtract(Duration(days: i + 1)),
          category: ActivityCategory.social,
        ),
      );

      final todayData = [
        ActivityLog(
          id: 't_1',
          childId: childId,
          screenTime: 60, // > 1.4x average
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

      expect(insights.any((i) => i.title == 'Social Media Surge'), isTrue);
    });
  });
}
