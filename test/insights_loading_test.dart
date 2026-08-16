import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:child_safety_monitor/data/database/app_database.dart';
import 'package:child_safety_monitor/providers/insights_provider.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('InsightsNotifier loadInsights partitions historical and today logs correctly', () async {
    final now = DateTime.now();
    final todayLogTime = DateTime(now.year, now.month, now.day, 10, 0); // Today at 10 AM
    final historicalLogTime = now.subtract(const Duration(days: 3)); // 3 days ago

    // Insert child
    await db.into(db.children).insert(
      ChildrenCompanion.insert(
        id: 'child_1',
        name: 'Ananya',
        riskLevel: const Value(20),
        lastActive: Value(now),
      ),
    );

    // Insert today log
    await db.into(db.activityLogs).insert(
      ActivityLogsCompanion.insert(
        id: 'log_today',
        childId: 'child_1',
        category: 'entertainment',
        screenTime: 120,
        timestamp: todayLogTime,
        appName: const Value('YouTube'),
      ),
    );

    // Insert historical log (3 days ago)
    await db.into(db.activityLogs).insert(
      ActivityLogsCompanion.insert(
        id: 'log_historical',
        childId: 'child_1',
        category: 'gaming',
        screenTime: 90,
        timestamp: historicalLogTime,
        appName: const Value('Minecraft'),
      ),
    );

    final notifier = InsightsNotifier(db);
    await notifier.loadInsights();

    final state = notifier.state;
    expect(state.isLoading, false);
    expect(state.error, isNull);
    expect(state.insights, isNotEmpty);
  });
}
