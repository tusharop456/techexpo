import 'package:child_safety_monitor/data/database/app_database.dart';
import 'package:drift/drift.dart';

class SampleDataGenerator {
  final AppDatabase _db;

  SampleDataGenerator(this._db);

  Future<void> generateAllData() async {
    await _db.update( _db.children).write(ChildrenCompanion(id: Value('demo_1'), name: Value('Liam'), riskLevel: Value(20), lastActive: Value(DateTime.now())));
    await _db.update( _db.children).write(ChildrenCompanion(id: Value('demo_2'), name: Value('Emma'), riskLevel: Value(45), lastActive: Value(DateTime.now())));
    
    // Using internal seed method from AppDatabase if available, otherwise manual
    // relying on AppDatabase's own _seedDemoData which is called in onCreate
    // But we can trigger inserts if needed
  }
}
