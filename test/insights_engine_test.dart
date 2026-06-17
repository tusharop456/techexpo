import 'package:flutter_test/flutter_test.dart';
import 'package:child_safety_monitor/services/insights_engine.dart';
import 'package:child_safety_monitor/data/models/activity_log.dart';

void main() {
  group('InsightsEngine.generateDailyInsights', () {
    final now = DateTime.now();
    const childId = 'child_1';
    const childName = 'Test Child';

    test('detects usage spike (anomaly)', () {
      final historicalData = [
        ActivityLog(
          id: 'h1',
          childId: childId,
          screenTime: 60,
          timestamp: now.subtract(const Duration(days: 1)),
          category: ActivityCategory.other,
        ),
      ];
      final todayData = [
        ActivityLog(
          id: 't1',
          childId: childId,
          screenTime: 120, // 100% increase
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

      final spikeInsight = insights.firstWhere((i) => i.type == InsightType.anomaly);
      expect(spikeInsight.title, 'Usage Spike Detected');
      expect(spikeInsight.percentageChange, 100.0);
    });

    test('detects gaming imbalance', () {
      final todayData = [
        ActivityLog(
          id: 't1',
          childId: childId,
          screenTime: 120,
          timestamp: now,
          category: ActivityCategory.gaming,
        ),
        ActivityLog(
          id: 't2',
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

      final gamingInsight = insights.firstWhere((i) => i.title == 'Gaming Imbalance');
      expect(gamingInsight.type, InsightType.warning);
      expect(gamingInsight.message, contains('4.0x more time gaming'));
    });

    test('detects late night activity', () {
      final todayData = [
        ActivityLog(
          id: 't1',
          childId: childId,
          screenTime: 40,
          timestamp: DateTime(now.year, now.month, now.day, 23, 0),
          category: ActivityCategory.other,
        ),
      ];

      final insights = InsightsEngine.generateDailyInsights(
        childId: childId,
        childName: childName,
        historicalData: [],
        todayData: todayData,
      );

      final lateNightInsight = insights.firstWhere((i) => i.title == 'Late Night Activity');
      expect(lateNightInsight.type, InsightType.warning);
      expect(lateNightInsight.message, contains('40 minutes'));
    });

    test('detects social media surge', () {
       // Generate 7 days of historical data, all within the last 7 days
       final historicalData = List.generate(7, (index) => ActivityLog(
          id: 'h$index',
          childId: childId,
          screenTime: 10,
          // Use a smaller offset to ensure it's strictly after "7 days ago"
          timestamp: now.subtract(Duration(days: index, hours: 23)),
          category: ActivityCategory.social,
        ));

        final todayData = [
          ActivityLog(
            id: 't1',
            childId: childId,
            screenTime: 20, // Avg was 10, so 100% surge
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

        final socialInsight = insights.firstWhere((i) => i.title == 'Social Media Surge');
        expect(socialInsight.type, InsightType.warning);
        expect(socialInsight.percentageChange, 100.0);
    });
  });
}
