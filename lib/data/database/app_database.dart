import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Todos, Children, Alerts, ActivityLogs, BehavioralEvents])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Children Queries
  Future<List<Child>> getAllChildren() => select(children).get();
  Stream<List<Child>> watchChildren() => select(children).watch();

  // Alerts Queries
  Stream<List<Alert>> watchAllAlerts() => (select(alerts)..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).watch();
  Stream<List<Alert>> watchPendingAlerts() => (select(alerts)..where((t) => t.isAcknowledged.not())..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).watch();

  Future<int> getUnreadAlertCount() async {
    final query = selectOnly(alerts)..addColumns([alerts.id.count()])..where(alerts.isAcknowledged.not());
    final result = await query.map((row) => row.read(alerts.id.count())).getSingle();
    return result ?? 0;
  }

  Future<void> acknowledgeAlert(String id) => (update(alerts)..where((t) => t.id.equals(id))).write(const AlertsCompanion(isAcknowledged: Value(true)));
  Future<void> markAllAlertsRead() => update(alerts).write(const AlertsCompanion(isAcknowledged: Value(true)));

  // ActivityLogs Queries
  Future<List<ActivityLogEntry>> getLast7DaysLogs(String childId) {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return (select(activityLogs)
      ..where((t) => t.childId.equals(childId))
      ..where((t) => t.timestamp.isBiggerThanValue(sevenDaysAgo)))
      .get();
  }

  Future<List<ActivityLogEntry>> getTodayLogs(String childId) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    return (select(activityLogs)
      ..where((t) => t.childId.equals(childId))
      ..where((t) => t.timestamp.isBiggerThanValue(startOfDay)))
      .get();
  }

  Future<bool> hasEnoughDataForInsights(String childId) async {
    final count = await (selectOnly(activityLogs)
      ..addColumns([activityLogs.id.count()])
      ..where(activityLogs.childId.equals(childId)))
      .map((row) => row.read(activityLogs.id.count()))
      .getSingle();
    return (count ?? 0) > 5;
  }

  // Dashboard Metrics
  Future<int> getAverageRiskLevel() async {
    final query = selectOnly(children)..addColumns([children.riskLevel.avg()]);
    final result = await query.map((row) => row.read(children.riskLevel.avg())).getSingle();
    return (result ?? 0).round();
  }

  Future<int> getActiveChildrenCount() async {
    final thirtyMinsAgo = DateTime.now().subtract(const Duration(minutes: 30));
    final query = selectOnly(children)
      ..addColumns([children.id.count()])
      ..where(children.lastActive.isBiggerThanValue(thirtyMinsAgo));
    final result = await query.map((row) => row.read(children.id.count())).getSingle();
    return result ?? 0;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
