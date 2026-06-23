import 'package:child_safety_monitor/data/models/activity_log.dart';
import 'package:child_safety_monitor/services/insights_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InsightsEngine Benchmark', () {
    test('Benchmark generateDailyInsights with large dataset', () {
      final childId = 'child_1';
      final childName = 'Test Child';

      // Generate 1000 historical logs
      final historicalData = List.generate(1000, (i) => ActivityLog(
        id: 'hist_$i',
        childId: childId,
        screenTime: 30,
        timestamp: DateTime.now().subtract(Duration(hours: i)),
        category: ActivityCategory.values[i % ActivityCategory.values.length],
      ));

      // Generate 100 today logs
      final todayData = List.generate(100, (i) => ActivityLog(
        id: 'today_$i',
        childId: childId,
        screenTime: 10,
        timestamp: DateTime.now().subtract(Duration(minutes: i * 5)),
        category: ActivityCategory.values[i % ActivityCategory.values.length],
      ));

      final stopwatch = Stopwatch()..start();

      // Run the engine multiple times to get a better average
      for (var i = 0; i < 100; i++) {
        InsightsEngine.generateDailyInsights(
          childId: childId,
          childName: childName,
          historicalData: historicalData,
          todayData: todayData,
        );
      }

      stopwatch.stop();
      print('Execution time for 100 calls with 1100 logs: ${stopwatch.elapsedMilliseconds}ms');
      print('Average time per call: ${stopwatch.elapsedMilliseconds / 100}ms');
    });
  });
}
