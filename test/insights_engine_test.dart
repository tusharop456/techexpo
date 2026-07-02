import 'package:flutter_test/flutter_test.dart';
import 'package:child_safety_monitor/services/insights_engine.dart';
import 'package:child_safety_monitor/data/models/activity_log.dart';

void main() {
  group('InsightsEngine Optimization Tests', () {
    final now = DateTime.now();
    const childId = 'child_1';
    const childName = 'Test Child';

    test('generateDailyInsights produces correct anomaly insight', () {
      final historicalData = [
        ActivityLog(id: 'h1', childId: childId, screenTime: 100, timestamp: now.subtract(const Duration(days: 1)), category: ActivityCategory.other),
      ];
      final todayData = [
        ActivityLog(id: 't1', childId: childId, screenTime: 200, timestamp: now, category: ActivityCategory.other),
      ];

      final insights = InsightsEngine.generateDailyInsights(
        childId: childId,
        childName: childName,
        historicalData: historicalData,
        todayData: todayData,
      );

      expect(insights.any((i) => i.type == InsightType.anomaly), isTrue);
      final anomaly = insights.firstWhere((i) => i.type == InsightType.anomaly);
      expect(anomaly.percentageChange, 100.0);
    });

    test('generateDailyInsights produces correct gaming imbalance insight', () {
      final historicalData = <ActivityLog>[];
      final todayData = [
        ActivityLog(id: 't1', childId: childId, screenTime: 120, timestamp: now, category: ActivityCategory.gaming),
        ActivityLog(id: 't2', childId: childId, screenTime: 20, timestamp: now, category: ActivityCategory.education),
      ];

      final insights = InsightsEngine.generateDailyInsights(
        childId: childId,
        childName: childName,
        historicalData: historicalData,
        todayData: todayData,
      );

      expect(insights.any((i) => i.title == 'Gaming Imbalance'), isTrue);
    });

    test('generateDailyInsights produces late night insight', () {
      final historicalData = <ActivityLog>[];
      final todayData = [
        ActivityLog(
          id: 't1',
          childId: childId,
          screenTime: 40,
          timestamp: DateTime(now.year, now.month, now.day, 23, 30),
          category: ActivityCategory.other
        ),
      ];

      final insights = InsightsEngine.generateDailyInsights(
        childId: childId,
        childName: childName,
        historicalData: historicalData,
        todayData: todayData,
      );

      expect(insights.any((i) => i.title == 'Late Night Activity'), isTrue);
    });
  });
}
