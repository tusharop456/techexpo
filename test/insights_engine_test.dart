
import 'package:flutter_test/flutter_test.dart';
import 'package:child_safety_monitor/services/insights_engine.dart';
import 'package:child_safety_monitor/data/models/activity_log.dart';

void main() {
  group('InsightsEngine', () {
    final now = DateTime.now();
    final childId = 'child_1';
    final childName = 'Ananya';

    test('generateDailyInsights generates expected insights', () {
      final historicalData = [
        // 7 days of data, 60 mins each
        for (int i = 1; i <= 7; i++)
          ActivityLog(
            id: 'h_$i',
            childId: childId,
            screenTime: 60,
            timestamp: now.subtract(Duration(days: i)),
            category: ActivityCategory.education,
          ),
      ];

      final todayData = [
        ActivityLog(
          id: 't_1',
          childId: childId,
          screenTime: 120, // 2x avg
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
        historicalData: historicalData,
        todayData: todayData,
      );

      expect(insights, isNotEmpty);
      // Should have usage spike (150 total vs 60 avg)
      expect(insights.any((i) => i.title == 'Usage Spike Detected'), isTrue);
      // Gaming vs Education: 120 vs 30 = 4:1. Ratio > 3:1, so should have Gaming Imbalance
      expect(insights.any((i) => i.title == 'Gaming Imbalance'), isTrue);
    });
  });
}
