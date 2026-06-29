import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Children, Alerts, ActivityLogs, BehavioralEvents, Todos])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Children methods
  Future<List<Child>> getAllChildren() => select(children).get();
  Stream<List<Child>> watchChildren() => select(children).watch();

  // Alerts methods
  Stream<List<Alert>> watchAllAlerts() => (select(alerts)..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).watch();
  Stream<List<Alert>> watchPendingAlerts() => (select(alerts)..where((t) => t.isAcknowledged.not())..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).watch();

  Future<int> getUnreadAlertCount() {
    final countExp = alerts.id.count();
    final query = selectOnly(alerts)..addColumns([countExp])..where(alerts.isAcknowledged.not());
    return query.map((row) => row.read(countExp) ?? 0).getSingle();
  }

  Future<int> markAllAlertsRead() {
    return (update(alerts)..where((t) => t.isAcknowledged.not())).write(const AlertsCompanion(isAcknowledged: Value(true)));
  }

  Future<bool> acknowledgeAlert(String id) async {
    final count = await (update(alerts)..where((t) => t.id.equals(id))).write(const AlertsCompanion(isAcknowledged: Value(true)));
    return count > 0;
  }

  // Activity Logs methods
  Future<List<ActivityLogEntry>> getLast7DaysLogs(String childId) {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return (select(activityLogs)
          ..where((t) => t.childId.equals(childId))
          ..where((t) => t.timestamp.isBiggerThanValue(sevenDaysAgo)))
        .get();
  }

  Future<List<ActivityLogEntry>> getTodayLogs(String childId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return (select(activityLogs)
          ..where((t) => t.childId.equals(childId))
          ..where((t) => t.timestamp.isBiggerThanValue(today)))
        .get();
  }

  Future<bool> hasEnoughDataForInsights(String childId) async {
    final countExp = activityLogs.id.count();
    final query = selectOnly(activityLogs)..addColumns([countExp])..where(activityLogs.childId.equals(childId));
    final count = await query.map((row) => row.read(countExp) ?? 0).getSingle();
    return count >= 5; // Arbitrary threshold
  }

  // Dashboard Stats
  Future<int> getAverageRiskLevel() async {
    final avgRisk = children.riskLevel.avg();
    final query = selectOnly(children)..addColumns([avgRisk]);
    final result = await query.map((row) => row.read(avgRisk)).getSingle();
    return result?.toInt() ?? 0;
  }

  Future<int> getActiveChildrenCount() async {
    final countExp = children.id.count();
    // For demo purposes, consider active if lastActive is within last 24h
    final oneDayAgo = DateTime.now().subtract(const Duration(days: 1));
    final query = selectOnly(children)
      ..addColumns([countExp])
      ..where(children.lastActive.isBiggerThanValue(oneDayAgo));
    return query.map((row) => row.read(countExp) ?? 0).getSingle();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
