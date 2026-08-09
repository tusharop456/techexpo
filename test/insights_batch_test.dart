import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:child_safety_monitor/data/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('Batch query getManyHasEnoughData identifies children with enough data', () async {
    // 1. Add children
    await db.into(db.children).insert(
      ChildrenCompanion.insert(id: 'child_1', name: 'Child One'),
    );
    await db.into(db.children).insert(
      ChildrenCompanion.insert(id: 'child_2', name: 'Child Two'),
    );
    await db.into(db.children).insert(
      ChildrenCompanion.insert(id: 'child_3', name: 'Child Three'),
    );

    // 2. Insert 12 logs for child_1 (should have enough data)
    for (int i = 0; i < 12; i++) {
      await db.into(db.activityLogs).insert(
        ActivityLogsCompanion.insert(
          id: 'log_1_$i',
          childId: 'child_1',
          screenTime: 15,
          timestamp: DateTime.now().subtract(Duration(hours: i)),
          category: 'gaming',
        ),
      );
    }

    // 3. Insert 5 logs for child_2 (should NOT have enough data)
    for (int i = 0; i < 5; i++) {
      await db.into(db.activityLogs).insert(
        ActivityLogsCompanion.insert(
          id: 'log_2_$i',
          childId: 'child_2',
          screenTime: 10,
          timestamp: DateTime.now().subtract(Duration(hours: i)),
          category: 'social',
        ),
      );
    }

    // 4. Do not insert any logs for child_3

    // 5. Query batch sufficiency
    final result = await db.getManyHasEnoughData(['child_1', 'child_2', 'child_3']);

    expect(result['child_1'], isTrue);
    expect(result['child_2'], isFalse);
    expect(result['child_3'], isFalse);
  });

  test('Batch query getAllLast7DaysLogs fetches correct logs within window', () async {
    // 1. Add children
    await db.into(db.children).insert(
      ChildrenCompanion.insert(id: 'child_1', name: 'Child One'),
    );
    await db.into(db.children).insert(
      ChildrenCompanion.insert(id: 'child_2', name: 'Child Two'),
    );

    final now = DateTime.now();
    final fiveDaysAgo = now.subtract(const Duration(days: 5));
    final tenDaysAgo = now.subtract(const Duration(days: 10));

    // 2. Insert logs within 7 days
    await db.into(db.activityLogs).insert(
      ActivityLogsCompanion.insert(
        id: 'log_recent_1',
        childId: 'child_1',
        screenTime: 30,
        timestamp: fiveDaysAgo,
        category: 'education',
      ),
    );
    await db.into(db.activityLogs).insert(
      ActivityLogsCompanion.insert(
        id: 'log_recent_2',
        childId: 'child_2',
        screenTime: 20,
        timestamp: fiveDaysAgo,
        category: 'social',
      ),
    );

    // 3. Insert logs older than 7 days
    await db.into(db.activityLogs).insert(
      ActivityLogsCompanion.insert(
        id: 'log_old_1',
        childId: 'child_1',
        screenTime: 45,
        timestamp: tenDaysAgo,
        category: 'gaming',
      ),
    );

    // 4. Query batch logs
    final logs = await db.getAllLast7DaysLogs(['child_1', 'child_2']);

    expect(logs.length, equals(2));
    expect(logs.any((l) => l.id == 'log_recent_1'), isTrue);
    expect(logs.any((l) => l.id == 'log_recent_2'), isTrue);
    expect(logs.any((l) => l.id == 'log_old_1'), isFalse);
  });

  test('Logs can be correctly partitioned in memory into today and historical logs', () async {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    final logToday = ActivityLogEntry(
      id: 'log_today',
      childId: 'child_1',
      screenTime: 15,
      timestamp: startOfToday.add(const Duration(hours: 2)),
      category: 'gaming',
      appName: 'Angry Birds',
    );

    final logYesterday = ActivityLogEntry(
      id: 'log_yesterday',
      childId: 'child_1',
      screenTime: 30,
      timestamp: startOfToday.subtract(const Duration(hours: 4)),
      category: 'social',
      appName: 'Instagram',
    );

    final allLogs = [logToday, logYesterday];

    final historical = <ActivityLogEntry>[];
    final today = <ActivityLogEntry>[];

    for (final e in allLogs) {
      historical.add(e);
      if (e.timestamp.isAfter(startOfToday) || e.timestamp.isAtSameMomentAs(startOfToday)) {
        today.add(e);
      }
    }

    expect(historical.length, equals(2));
    expect(today.length, equals(1));
    expect(today.first.id, equals('log_today'));
  });
}
