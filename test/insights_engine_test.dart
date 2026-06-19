import 'package:flutter_test/flutter_test.dart';
import 'package:child_safety_monitor/data/models/activity_log.dart';
import 'package:child_safety_monitor/services/insights_engine.dart';

void main() {
  group('InsightsEngine Optimization Tests', () {
    final now = DateTime.now();
    const childId = 'child_123';
    const childName = 'Test Child';

    test('generateDailyInsights should detect usage spike', () {
      final historicalData = List.generate(7, (index) => ActivityLog(
        id: 'h_$index',
        childId: childId,
        screenTime: 60, // 60 mins avg per day
        timestamp: now.subtract(Duration(days: index + 1)),
        category: ActivityCategory.entertainment,
      ));

      final todayData = [
        ActivityLog(
          id: 't_1',
          childId: childId,
          screenTime: 120, // 100% increase (spike)
          timestamp: now,
          category: ActivityCategory.entertainment,
        ),
      ];

      final insights = InsightsEngine.generateDailyInsights(
        childId: childId,
        childName: childName,
        historicalData: historicalData,
        todayData: todayData,
      );

      final spikeInsight = insights.firstWhere((i) => i.type == InsightType.anomaly);
      expect(spikeInsight.title, contains('Usage Spike'));
      expect(spikeInsight.percentageChange, 100.0);
    });

    test('generateDailyInsights should detect gaming imbalance', () {
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
          screenTime: 20, // 6:1 ratio (> 3:1)
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

      final gamingInsight = insights.firstWhere((i) => i.id.contains('gaming_ratio'));
      expect(gamingInsight.type, InsightType.warning);
      expect(gamingInsight.message, contains('6.0x more time gaming'));
    });

    test('generateDailyInsights should detect late-night usage', () {
      final historicalData = <ActivityLog>[];
      final todayData = [
        ActivityLog(
          id: 't_late',
          childId: childId,
          screenTime: 40,
          timestamp: DateTime(now.year, now.month, now.day, 23, 30), // 11:30 PM
          category: ActivityCategory.social,
        ),
      ];

      final insights = InsightsEngine.generateDailyInsights(
        childId: childId,
        childName: childName,
        historicalData: historicalData,
        todayData: todayData,
      );

      final lateNightInsight = insights.firstWhere((i) => i.id.contains('late_night'));
      expect(lateNightInsight.title, contains('Late Night'));
      expect(lateNightInsight.message, contains('40 minutes'));
    });

    test('generateDailyInsights should detect education progress', () {
       final historicalData = [
        ActivityLog(
          id: 'h_e_1',
          childId: childId,
          screenTime: 70, // Total 70 education mins in historical
          timestamp: now.subtract(const Duration(days: 1)),
          category: ActivityCategory.education,
        ),
      ];

      final todayData = [
        ActivityLog(
          id: 't_e_1',
          childId: childId,
          screenTime: 30, // 30 mins education today
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

      final eduInsight = insights.firstWhere((i) => i.id.contains('education_up'));
      expect(eduInsight.type, InsightType.positive);
      // avgDailyEducation = 70 / 7 = 10.
      // todayEducation = 30.
      // increase = (30 - 10) / 10 * 100 = 200%.
      expect(eduInsight.percentageChange, 200.0);
    });

   group('Edge Cases', () {
      test('Empty data should return empty insights', () {
        final insights = InsightsEngine.generateDailyInsights(
          childId: childId,
          childName: childName,
          historicalData: [],
          todayData: [],
        );
        expect(insights, isEmpty);
      });
    });
  });
}
