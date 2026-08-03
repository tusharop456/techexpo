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

  test('Batch hasEnoughDataForInsights and getLast7DaysLogs', () async {
    // 1. Insert test children
    await db.into(db.children).insert(
      const ChildrenCompanion(
        id: Value('child_1'),
        name: Value('Child One'),
        riskLevel: Value(20),
      ),
    );
    await db.into(db.children).insert(
      const ChildrenCompanion(
        id: Value('child_2'),
        name: Value('Child Two'),
        riskLevel: Value(40),
      ),
    );

    // 2. Insert logs for child_1 (9 logs - not enough for insights)
    for (int i = 0; i < 9; i++) {
      await db.into(db.activityLogs).insert(
        ActivityLogsCompanion(
          id: Value('log_1_$i'),
          childId: const Value('child_1'),
          screenTime: const Value(30),
          timestamp: Value(DateTime.now().subtract(Duration(hours: i))),
          category: const Value('gaming'),
        ),
      );
    }

    // 3. Insert logs for child_2 (12 logs - enough for insights)
    for (int i = 0; i < 12; i++) {
      await db.into(db.activityLogs).insert(
        ActivityLogsCompanion(
          id: Value('log_2_$i'),
          childId: const Value('child_2'),
          screenTime: const Value(20),
          timestamp: Value(DateTime.now().subtract(Duration(hours: i))),
          category: const Value('education'),
        ),
      );
    }

    // 4. Run batch checking for data sufficiency
    final hasDataMap = await db.getManyHasEnoughData(['child_1', 'child_2']);
    expect(hasDataMap['child_1'], isFalse); // Only 9 logs
    expect(hasDataMap['child_2'], isTrue);  // 12 logs

    // 5. Run batch logs retrieval
    final allLogs = await db.getAllLast7DaysLogs(['child_1', 'child_2']);
    expect(allLogs.length, equals(21)); // 9 + 12 = 21 logs total

    // Check sorting / presence of children logs
    final child1Logs = allLogs.where((l) => l.childId == 'child_1').toList();
    final child2Logs = allLogs.where((l) => l.childId == 'child_2').toList();
    expect(child1Logs.length, equals(9));
    expect(child2Logs.length, equals(12));
  });
}
