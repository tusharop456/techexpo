import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:child_safety_monitor/data/database/app_database.dart';
import 'package:drift/drift.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('Database batch fetch optimization test', () async {
    final childIds = ['child_1', 'child_2'];

    // Seed some data
    await db.into(db.children).insert(ChildrenCompanion.insert(id: 'child_1', name: 'Child 1'));
    await db.into(db.children).insert(ChildrenCompanion.insert(id: 'child_2', name: 'Child 2'));

    for (int i = 0; i < 10; i++) {
      await db.into(db.activityLogs).insert(ActivityLogsCompanion.insert(
        id: 'log_$i',
        childId: 'child_1',
        screenTime: 10,
        timestamp: DateTime.now(),
        category: 'gaming',
      ));
    }

    // Test batch methods
    final status = await db.getEnoughDataStatusForChildren(childIds);
    expect(status['child_1'], isTrue);
    expect(status['child_2'], isFalse);

    final logs = await db.getLogsForChildren(childIds);
    expect(logs.length, equals(10));

    final filteredLogs = await db.getLogsForChildren(childIds, after: DateTime.now().add(const Duration(minutes: 1)));
    expect(filteredLogs.length, equals(0));
  });
}
