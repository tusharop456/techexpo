import 'package:child_safety_monitor/data/database/app_database.dart';
import 'package:drift/drift.dart';

class SampleDataGenerator {
  final AppDatabase _db;

  SampleDataGenerator(this._db);

  Future<void> generateAllData() async {
    await _db.into(_db.children).insertOnConflictUpdate(ChildrenCompanion(
      id: const Value('demo_1'),
      name: const Value('Liam'),
      riskLevel: const Value(20),
      lastActive: Value(DateTime.now()),
    ));
    await _db.into(_db.children).insertOnConflictUpdate(ChildrenCompanion(
      id: const Value('demo_2'),
      name: const Value('Emma'),
      riskLevel: const Value(45),
      lastActive: Value(DateTime.now()),
    ));
  }
}
