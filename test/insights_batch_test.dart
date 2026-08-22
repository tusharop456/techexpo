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

  test('getAllLast7DaysLogs and getManyHasEnoughData return expected batch results', () async {
    final now = DateTime.now();

    // Insert children
    await db.into(db.children).insert(
      ChildrenCompanion.insert(
        id: 'child_a',
        name: 'Child A',
        riskLevel: const drift.Value(10),
        lastActive: drift.Value(now),
      ),
    );
    await db.into(db.children).insert(
      ChildrenCompanion.insert(
        id: 'child_b',
        name: 'Child B',
        riskLevel: const drift.Value(20),
        lastActive: drift.Value(now),
      ),
    );

    // Insert 10 logs for child_a (enough data)
    for (int i = 0; i < 10; i++) {
      await db.into(db.activityLogs).insert(
        ActivityLogsCompanion.insert(
          id: 'log_a_$i',
          childId: 'child_a',
          appName: const drift.Value('AppA'),
          category: 'gaming',
          screenTime: 30,
          timestamp: now.subtract(Duration(hours: i + 1)),
        ),
      );
    }

    // Insert 2 logs for child_b (not enough data)
    for (int i = 0; i < 2; i++) {
      await db.into(db.activityLogs).insert(
        ActivityLogsCompanion.insert(
          id: 'log_b_$i',
          childId: 'child_b',
          appName: const drift.Value('AppB'),
          category: 'social',
          screenTime: 15,
          timestamp: now.subtract(Duration(hours: i + 1)),
        ),
      );
    }

    final childIds = ['child_a', 'child_b'];

    // Test getManyHasEnoughData
    final hasEnoughDataMap = await db.getManyHasEnoughData(childIds);
    expect(hasEnoughDataMap['child_a'], isTrue);
    expect(hasEnoughDataMap['child_b'], isFalse);

    // Test getAllLast7DaysLogs
    final logs = await db.getAllLast7DaysLogs(childIds);
    expect(logs.length, equals(12));

    // Test InsightsNotifier integration with batch methods
    final notifier = InsightsNotifier(db);
    await Future.delayed(const Duration(milliseconds: 100));

    expect(notifier.state.isLoading, isFalse);
    expect(notifier.state.hasEnoughData, isTrue);
    expect(notifier.state.insights, isNotEmpty);
  });
}
