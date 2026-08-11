import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:child_safety_monitor/data/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    // Initialize an in-memory database
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('getAllLast7DaysLogs retrieves correct and filtered logs', () async {
    // 1. Insert mock children
    await db.into(db.children).insert(const ChildrenCompanion(
      id: Value('child_1'),
      name: Value('Emma'),
    ));
    await db.into(db.children).insert(const ChildrenCompanion(
      id: Value('child_2'),
      name: Value('Liam'),
    ));

    // 2. Insert mock activity logs
    final now = DateTime.now();
    final eightDaysAgo = now.subtract(const Duration(days: 8));
    final threeDaysAgo = now.subtract(const Duration(days: 3));

    // Valid: child_1, 3 days ago (within 7 days)
    await db.into(db.activityLogs).insert(ActivityLogsCompanion.insert(
      id: 'log_1',
      childId: 'child_1',
      screenTime: 30,
      timestamp: threeDaysAgo,
      category: 'gaming',
    ));

    // Valid: child_2, 3 days ago (within 7 days)
    await db.into(db.activityLogs).insert(ActivityLogsCompanion.insert(
      id: 'log_2',
      childId: 'child_2',
      screenTime: 45,
      timestamp: threeDaysAgo,
      category: 'social',
    ));

    // Invalid: child_1, 8 days ago (outside 7 days)
    await db.into(db.activityLogs).insert(ActivityLogsCompanion.insert(
      id: 'log_3',
      childId: 'child_1',
      screenTime: 15,
      timestamp: eightDaysAgo,
      category: 'education',
    ));

    // Invalid: child_3 (not in childIds list)
    await db.into(db.children).insert(const ChildrenCompanion(
      id: Value('child_3'),
      name: Value('Priya'),
    ));
    await db.into(db.activityLogs).insert(ActivityLogsCompanion.insert(
      id: 'log_4',
      childId: 'child_3',
      screenTime: 20,
      timestamp: threeDaysAgo,
      category: 'entertainment',
    ));

    // Execute batch query for child_1 and child_2
    final logs = await db.getAllLast7DaysLogs(['child_1', 'child_2']);

    // Should only contain log_1 and log_2
    expect(logs.length, equals(2));
    expect(logs.any((l) => l.id == 'log_1'), isTrue);
    expect(logs.any((l) => l.id == 'log_2'), isTrue);
    expect(logs.any((l) => l.id == 'log_3'), isFalse);
    expect(logs.any((l) => l.id == 'log_4'), isFalse);
  });

  test('getManyHasEnoughData correctly computes threshold maps', () async {
    // 1. Insert mock children
    await db.into(db.children).insert(const ChildrenCompanion(
      id: Value('child_1'),
      name: Value('Emma'),
    ));
    await db.into(db.children).insert(const ChildrenCompanion(
      id: Value('child_2'),
      name: Value('Liam'),
    ));

    // child_1 has 10 logs (should be true)
    for (int i = 0; i < 10; i++) {
      await db.into(db.activityLogs).insert(ActivityLogsCompanion.insert(
        id: 'log_emma_$i',
        childId: 'child_1',
        screenTime: 10,
        timestamp: DateTime.now(),
        category: 'education',
      ));
    }

    // child_2 has 5 logs (should be false)
    for (int i = 0; i < 5; i++) {
      await db.into(db.activityLogs).insert(ActivityLogsCompanion.insert(
        id: 'log_liam_$i',
        childId: 'child_2',
        screenTime: 10,
        timestamp: DateTime.now(),
        category: 'gaming',
      ));
    }

    final hasEnoughDataMap = await db.getManyHasEnoughData(['child_1', 'child_2', 'child_3']);

    expect(hasEnoughDataMap['child_1'], isTrue);
    expect(hasEnoughDataMap['child_2'], isFalse);
    expect(hasEnoughDataMap['child_3'], isFalse); // default false
  });
}
