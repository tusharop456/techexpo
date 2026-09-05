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

  test('getAllLast7DaysLogs retrieves logs across multiple children in a single query', () async {
    final now = DateTime.now();

    // Insert 2 children
    await db.into(db.children).insert(
      ChildrenCompanion.insert(
        id: 'child_1',
        name: 'Child One',
        riskLevel: drift.Value(1),
        lastActive: drift.Value(now),
      ),
    );
    await db.into(db.children).insert(
      ChildrenCompanion.insert(
        id: 'child_2',
        name: 'Child Two',
        riskLevel: drift.Value(2),
        lastActive: drift.Value(now),
      ),
    );

    // Insert logs for child_1 and child_2
    await db.into(db.activityLogs).insert(
      ActivityLogsCompanion.insert(
        id: 'log_1',
        childId: 'child_1',
        appName: drift.Value('Roblox'),
        category: 'gaming',
        screenTime: 30,
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
    );
    await db.into(db.activityLogs).insert(
      ActivityLogsCompanion.insert(
        id: 'log_2',
        childId: 'child_2',
        appName: drift.Value('YouTube'),
        category: 'entertainment',
        screenTime: 45,
        timestamp: now.subtract(const Duration(hours: 1)),
      ),
    );

    final logs = await db.getAllLast7DaysLogs(['child_1', 'child_2']);
    expect(logs.length, equals(2));
    expect(logs.map((e) => e.childId).toSet(), equals({'child_1', 'child_2'}));
  });

  test('getManyHasEnoughData accurately identifies children with >= 10 logs in a single batch query', () async {
    final now = DateTime.now();

    // Insert 2 children
    await db.into(db.children).insert(
      ChildrenCompanion.insert(
        id: 'child_1',
        name: 'Child One',
        riskLevel: drift.Value(1),
        lastActive: drift.Value(now),
      ),
    );
    await db.into(db.children).insert(
      ChildrenCompanion.insert(
        id: 'child_2',
        name: 'Child Two',
        riskLevel: drift.Value(2),
        lastActive: drift.Value(now),
      ),
    );

    // Insert 10 logs for child_1 (enough data)
    for (int i = 0; i < 10; i++) {
      await db.into(db.activityLogs).insert(
        ActivityLogsCompanion.insert(
          id: 'c1_log_$i',
          childId: 'child_1',
          appName: drift.Value('App $i'),
          category: 'education',
          screenTime: 15,
          timestamp: now.subtract(Duration(minutes: i * 10)),
        ),
      );
    }

    // Insert 3 logs for child_2 (not enough data)
    for (int i = 0; i < 3; i++) {
      await db.into(db.activityLogs).insert(
        ActivityLogsCompanion.insert(
          id: 'c2_log_$i',
          childId: 'child_2',
          appName: drift.Value('App $i'),
          category: 'gaming',
          screenTime: 15,
          timestamp: now.subtract(Duration(minutes: i * 10)),
        ),
      );
    }

    final childrenWithEnoughData = await db.getManyHasEnoughData(['child_1', 'child_2']);
    expect(childrenWithEnoughData.contains('child_1'), isTrue);
    expect(childrenWithEnoughData.contains('child_2'), isFalse);
  });
}
