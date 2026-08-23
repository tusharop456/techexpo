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

  test('getManyHasEnoughData correctly checks log threshold for multiple children', () async {
    // Insert two children
    await db.into(db.children).insert(
      ChildrenCompanion.insert(
        id: 'child_1',
        name: 'Child One',
        riskLevel: const drift.Value(10),
        lastActive: drift.Value(DateTime.now()),
      ),
    );
    await db.into(db.children).insert(
      ChildrenCompanion.insert(
        id: 'child_2',
        name: 'Child Two',
        riskLevel: const drift.Value(20),
        lastActive: drift.Value(DateTime.now()),
      ),
    );

    // Insert 10 logs for child_1
    for (int i = 0; i < 10; i++) {
      await db.into(db.activityLogs).insert(
        ActivityLogsCompanion.insert(
          id: 'log_c1_$i',
          childId: 'child_1',
          appName: const drift.Value('App'),
          category: 'gaming',
          screenTime: 10,
          timestamp: DateTime.now(),
        ),
      );
    }

    // Insert 5 logs for child_2
    for (int i = 0; i < 5; i++) {
      await db.into(db.activityLogs).insert(
        ActivityLogsCompanion.insert(
          id: 'log_c2_$i',
          childId: 'child_2',
          appName: const drift.Value('App'),
          category: 'education',
          screenTime: 10,
          timestamp: DateTime.now(),
        ),
      );
    }

    final resultMap = await db.getManyHasEnoughData(['child_1', 'child_2']);
    expect(resultMap['child_1'], isTrue);
    expect(resultMap['child_2'], isFalse);
  });

  test('getAllLast7DaysLogs fetches logs for multiple children in batch', () async {
    final now = DateTime.now();
    final recent = now.subtract(const Duration(days: 2));
    final old = now.subtract(const Duration(days: 10));

    await db.into(db.children).insert(
      ChildrenCompanion.insert(
        id: 'c1',
        name: 'C1',
        riskLevel: const drift.Value(5),
        lastActive: drift.Value(now),
      ),
    );

    await db.into(db.activityLogs).insert(
      ActivityLogsCompanion.insert(
        id: 'l1',
        childId: 'c1',
        appName: const drift.Value('YouTube'),
        category: 'entertainment',
        screenTime: 30,
        timestamp: recent,
      ),
    );

    await db.into(db.activityLogs).insert(
      ActivityLogsCompanion.insert(
        id: 'l2',
        childId: 'c1',
        appName: const drift.Value('OldApp'),
        category: 'entertainment',
        screenTime: 30,
        timestamp: old,
      ),
    );

    final logs = await db.getAllLast7DaysLogs(['c1']);
    expect(logs.length, equals(1));
    expect(logs.first.id, equals('l1'));
  });

  test('InsightsNotifier loadInsights loads insights using batch queries', () async {
    final now = DateTime.now();
    await db.into(db.children).insert(
      ChildrenCompanion.insert(
        id: 'child_batch',
        name: 'Batch Child',
        riskLevel: const drift.Value(15),
        lastActive: drift.Value(now),
      ),
    );

    for (int i = 0; i < 12; i++) {
      await db.into(db.activityLogs).insert(
        ActivityLogsCompanion.insert(
          id: 'log_b_$i',
          childId: 'child_batch',
          appName: const drift.Value('Roblox'),
          category: 'gaming',
          screenTime: 20,
          timestamp: now.subtract(Duration(hours: i * 2)),
        ),
      );
    }

    final notifier = InsightsNotifier(db);
    await Future.delayed(const Duration(milliseconds: 100));

    expect(notifier.state.isLoading, isFalse);
    expect(notifier.state.hasEnoughData, isTrue);
    expect(notifier.state.insights, isNotEmpty);
  });
}
