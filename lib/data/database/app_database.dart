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

  // Children
  Stream<List<Child>> watchChildren() => select(children).watch();
  Future<List<Child>> getAllChildren() => select(children).get();

  // Alerts
  Stream<List<Alert>> watchAllAlerts() =>
      (select(alerts)..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).watch();
  Stream<List<Alert>> watchPendingAlerts() =>
      (select(alerts)..where((t) => t.isAcknowledged.not())
      ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).watch();

  Future<int> getUnreadAlertCount() async {
    final countExp = alerts.id.count();
    final query = selectOnly(alerts)..addColumns([countExp])..where(alerts.isAcknowledged.not());
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }

  Future<void> acknowledgeAlert(String id) =>
      (update(alerts)..where((t) => t.id.equals(id))).write(const AlertsCompanion(isAcknowledged: Value(true)));

  Future<void> markAllAlertsRead() =>
      (update(alerts)..where((t) => t.isAcknowledged.not())).write(const AlertsCompanion(isAcknowledged: Value(true)));

  // Activity Logs
  Future<List<ActivityLogEntry>> getTodayLogs(String childId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return (select(activityLogs)
      ..where((t) => t.childId.equals(childId))
      ..where((t) => t.timestamp.isBiggerOrEqualValue(today))).get();
  }

  Future<List<ActivityLogEntry>> getLast7DaysLogs(String childId) {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return (select(activityLogs)
      ..where((t) => t.childId.equals(childId))
      ..where((t) => t.timestamp.isBiggerOrEqualValue(weekAgo))).get();
  }

  Future<bool> hasEnoughDataForInsights(String childId) async {
    final countExp = activityLogs.id.count();
    final query = selectOnly(activityLogs)
      ..addColumns([countExp])
      ..where(activityLogs.childId.equals(childId));
    final result = await query.map((row) => row.read(countExp)).getSingle();
    final count = result ?? 0;
    return count >= 10; // Simple threshold
  }

  // Dashboard metrics
  Future<double> getAverageRiskLevel() async {
    final avgRisk = children.riskLevel.avg();
    final query = selectOnly(children)..addColumns([avgRisk]);
    final result = await query.map((row) => row.read(avgRisk)).getSingle();
    return result ?? 0.0;
  }

  Future<int> getActiveChildrenCount() async {
    final countExp = children.id.count();
    final query = selectOnly(children)..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();
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
