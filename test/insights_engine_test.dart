import 'package:flutter_test/flutter_test.dart';
import 'package:child_safety_monitor/services/insights_engine.dart';
import 'package:child_safety_monitor/data/models/activity_log.dart';

void main() {
  group('InsightsEngine Optimization Tests', () {
    final now = DateTime.now();
    final childId = 'test_child';
    final childName = 'Test';

    test('should detect usage spike (anomaly) correctly', () {
      final historicalData = List.generate(7, (i) => ActivityLog(
        id: 'h_$i',
        childId: childId,
        screenTime: 100,
        timestamp: now.subtract(Duration(days: i + 1)),
        category: ActivityCategory.entertainment,
      ));

      final todayData = [
        ActivityLog(
          id: 't_1',
          childId: childId,
          screenTime: 150, // 50% increase from 100 avg
          timestamp: now,
          category: ActivityCategory.entertainment,
        )
      ];

      final insights = InsightsEngine.generateDailyInsights(
        childId: childId,
        childName: childName,
        historicalData: historicalData,
        todayData: todayData,
      );

      final anomaly = insights.firstWhere((i) => i.type == InsightType.anomaly);
      expect(anomaly.title, 'Usage Spike Detected');
      expect(anomaly.percentageChange, 50.0);
    });

    test('should detect gaming imbalance correctly', () {
      final todayData = [
        ActivityLog(
          id: 't_1',
          childId: childId,
          screenTime: 100,
          timestamp: now,
          category: ActivityCategory.gaming,
        ),
        ActivityLog(
          id: 't_2',
          childId: childId,
          screenTime: 20,
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

      final warning = insights.firstWhere((i) => i.type == InsightType.warning && i.title == 'Gaming Imbalance');
      expect(warning.message.contains('5.0x more time gaming'), true);
    });

    test('should detect late night usage correctly', () {
      final todayData = [
        ActivityLog(
          id: 't_1',
          childId: childId,
          screenTime: 40,
          timestamp: DateTime(now.year, now.month, now.day, 23, 30),
          category: ActivityCategory.social,
        ),
      ];

      final insights = InsightsEngine.generateDailyInsights(
        childId: childId,
        childName: childName,
        historicalData: [],
        todayData: todayData,
      );

      final warning = insights.firstWhere((i) => i.type == InsightType.warning && i.title == 'Late Night Activity');
      expect(warning.message.contains('40 minutes'), true);
    });

    test('should handle empty data gracefully', () {
      final insights = InsightsEngine.generateDailyInsights(
        childId: childId,
        childName: childName,
        historicalData: [],
        todayData: [],
      );

      expect(insights.isEmpty, true);
    });
  });
}
