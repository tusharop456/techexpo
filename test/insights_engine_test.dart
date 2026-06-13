import 'package:flutter_test/flutter_test.dart';
import 'package:child_safety_monitor/services/insights_engine.dart';
import 'package:child_safety_monitor/utils/demo_data_generator.dart';

void main() {
  group('InsightsEngine Optimization Tests', () {
    test('should generate insights for child_1 (Ananya)', () {
      final id = 'child_1';
      final name = 'Ananya';

      final historical = DemoDataGenerator.getHistoricalLogsFor(id);
      final today = DemoDataGenerator.getTodayLogsFor(id);

      final insights = InsightsEngine.generateDailyInsights(
        childId: id,
        childName: name,
        historicalData: historical,
        todayData: today,
      );

      expect(insights, isNotEmpty);
      print('Generated ${insights.length} insights for Ananya');
    });

    test('should generate insights for child_2 (Arjun/Liam)', () {
      final id = 'child_2';
      final name = 'Arjun';

      final historical = DemoDataGenerator.getHistoricalLogsFor(id);
      final today = DemoDataGenerator.getTodayLogsFor(id);

      final insights = InsightsEngine.generateDailyInsights(
        childId: id,
        childName: name,
        historicalData: historical,
        todayData: today,
      );

      expect(insights, isNotEmpty);
      print('Generated ${insights.length} insights for Arjun');
    });
  });
}
