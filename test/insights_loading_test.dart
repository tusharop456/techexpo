import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
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

  test('InsightsNotifier loads insights correctly by partitioning logs in memory', () async {
    // Insert a child
    await db.into(db.children).insert(
      ChildrenCompanion.insert(
        id: 'child_1',
        name: 'Test Child',
        riskLevel: const Value(10),
        lastActive: Value(DateTime.now()),
      ),
    );

    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day, 10, 0);
    final fiveDaysAgo = now.subtract(const Duration(days: 5));

    // Insert historical log (5 days ago)
    await db.into(db.activityLogs).insert(
      ActivityLogsCompanion.insert(
        id: 'log_1',
        childId: 'child_1',
        appName: const Value('YouTube'),
        screenTime: 60,
        category: 'entertainment',
        timestamp: fiveDaysAgo,
      ),
    );

    // Insert today log
    await db.into(db.activityLogs).insert(
      ActivityLogsCompanion.insert(
        id: 'log_2',
        childId: 'child_1',
        appName: const Value('Minecraft'),
        screenTime: 120,
        category: 'gaming',
        timestamp: startOfToday,
      ),
    );

    final notifier = InsightsNotifier(db);
    // Wait for initial loadInsights to complete
    await Future.delayed(const Duration(milliseconds: 200));

    final state = notifier.state;
    expect(state.isLoading, false);
    expect(state.insights, isNotEmpty);
  });
}
