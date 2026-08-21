import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:child_safety_monitor/data/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('getAllLast7DaysLogs retrieves logs for multiple children in batch', () async {
    final now = DateTime.now();
    final logTime = now.subtract(const Duration(hours: 2));
    final oldLogTime = now.subtract(const Duration(days: 10));

    // Insert 2 children
    await db.into(db.children).insert(
      ChildrenCompanion.insert(id: 'child_1', name: 'Child 1', riskLevel: const drift.Value(0), lastActive: drift.Value(now)),
    );
    await db.into(db.children).insert(
      ChildrenCompanion.insert(id: 'child_2', name: 'Child 2', riskLevel: const drift.Value(0), lastActive: drift.Value(now)),
    );

    // Insert logs
    await db.into(db.activityLogs).insert(
      ActivityLogsCompanion.insert(id: 'l1', childId: 'child_1', appName: const drift.Value('App 1'), category: 'gaming', screenTime: 30, timestamp: logTime),
    );
    await db.into(db.activityLogs).insert(
      ActivityLogsCompanion.insert(id: 'l2', childId: 'child_2', appName: const drift.Value('App 2'), category: 'social', screenTime: 45, timestamp: logTime),
    );
    // Old log older than 7 days
    await db.into(db.activityLogs).insert(
      ActivityLogsCompanion.insert(id: 'l3', childId: 'child_1', appName: const drift.Value('App 3'), category: 'social', screenTime: 15, timestamp: oldLogTime),
    );

    final batchLogs = await db.getAllLast7DaysLogs(['child_1', 'child_2']);
    expect(batchLogs.length, equals(2));
    expect(batchLogs.map((l) => l.id), containsAll(['l1', 'l2']));
  });

  test('getManyHasEnoughData correctly computes threshold for multiple children in batch', () async {
    final now = DateTime.now();

    // Insert 2 children
    await db.into(db.children).insert(
      ChildrenCompanion.insert(id: 'child_1', name: 'Child 1', riskLevel: const drift.Value(0), lastActive: drift.Value(now)),
    );
    await db.into(db.children).insert(
      ChildrenCompanion.insert(id: 'child_2', name: 'Child 2', riskLevel: const drift.Value(0), lastActive: drift.Value(now)),
    );

    // Insert 10 logs for child_1, 5 logs for child_2
    for (int i = 0; i < 10; i++) {
      await db.into(db.activityLogs).insert(
        ActivityLogsCompanion.insert(
          id: 'c1_$i',
          childId: 'child_1',
          appName: const drift.Value('App'),
          category: 'gaming',
          screenTime: 10,
          timestamp: now,
        ),
      );
    }
    for (int i = 0; i < 5; i++) {
      await db.into(db.activityLogs).insert(
        ActivityLogsCompanion.insert(
          id: 'c2_$i',
          childId: 'child_2',
          appName: const drift.Value('App'),
          category: 'social',
          screenTime: 10,
          timestamp: now,
        ),
      );
    }

    final resultMap = await db.getManyHasEnoughData(['child_1', 'child_2']);
    expect(resultMap['child_1'], isTrue);
    expect(resultMap['child_2'], isFalse);
  });
}
