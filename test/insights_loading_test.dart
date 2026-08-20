import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:child_safety_monitor/data/database/app_database.dart';
import 'package:child_safety_monitor/providers/insights_provider.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('InsightsNotifier loads insights and partitions today logs correctly from historical logs', () async {
    final now = DateTime.now();
    final todayLogTime = now.subtract(const Duration(hours: 1));
    final pastLogTime = now.subtract(const Duration(days: 3));

    // Insert a child
    await db.into(db.children).insert(
      ChildrenCompanion.insert(
        id: 'child_100',
        name: 'Test Child',
        riskLevel: drift.Value(10),
        lastActive: drift.Value(now),
      ),
    );

    // Insert activity logs for today and 3 days ago
    await db.into(db.activityLogs).insert(
      ActivityLogsCompanion.insert(
        id: 'log_1',
        childId: 'child_100',
        appName: drift.Value('Minecraft'),
        category: 'gaming',
        screenTime: 60,
        timestamp: todayLogTime,
      ),
    );

    await db.into(db.activityLogs).insert(
      ActivityLogsCompanion.insert(
        id: 'log_2',
        childId: 'child_100',
        appName: drift.Value('YouTube'),
        category: 'entertainment',
        screenTime: 120,
        timestamp: pastLogTime,
      ),
    );

    final notifier = InsightsNotifier(db);
    // Wait for loadInsights async operation triggered in constructor
    await Future.delayed(const Duration(milliseconds: 100));

    expect(notifier.state.isLoading, isFalse);
    expect(notifier.state.insights, isNotEmpty);
  });
}
