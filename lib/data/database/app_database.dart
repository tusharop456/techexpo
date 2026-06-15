import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Children, Alerts, ActivityLogs, BehavioralEvents])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // --- Children ---
  Stream<List<Child>> watchChildren() => select(children).watch();
  Future<List<Child>> getAllChildren() => select(children).get();

  /// BOLT OPTIMIZATION: Use SQL count instead of fetching all records to memory
  Future<int> getActiveChildrenCount() {
    final countExp = children.id.count();
    final query = selectOnly(children)..addColumns([countExp]);
    query.where(children.lastActive.isNotNull());
    return query.map((row) => row.read(countExp) ?? 0).getSingle();
  }

  // --- Alerts ---
  Stream<List<Alert>> watchAllAlerts() =>
      (select(alerts)..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).watch();
  Stream<List<Alert>> watchPendingAlerts() =>
      (select(alerts)..where((t) => t.isAcknowledged.equals(false))).watch();

  /// BOLT OPTIMIZATION: Use SQL count instead of fetching all records to memory
  Future<int> getUnreadAlertCount() {
    final countExp = alerts.id.count();
    final query = selectOnly(alerts)..addColumns([countExp]);
    query.where(alerts.isAcknowledged.equals(false));
    return query.map((row) => row.read(countExp) ?? 0).getSingle();
  }

  Future<void> markAllAlertsRead() =>
      (update(alerts)..where((t) => t.isAcknowledged.equals(false)))
          .write(const AlertsCompanion(isAcknowledged: Value(true)));
  Future<void> acknowledgeAlert(String id) =>
      (update(alerts)..where((t) => t.id.equals(id)))
          .write(const AlertsCompanion(isAcknowledged: Value(true)));

  // --- Activity Logs ---
  Future<List<ActivityLogEntry>> getTodayLogs(String childId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return (select(activityLogs)
          ..where((t) =>
              t.childId.equals(childId) & t.timestamp.isBiggerOrEqualValue(today)))
        .get();
  }

  Future<List<ActivityLogEntry>> getLast7DaysLogs(String childId) {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return (select(activityLogs)
          ..where((t) =>
              t.childId.equals(childId) &
              t.timestamp.isBiggerOrEqualValue(sevenDaysAgo)))
        .get();
  }

  // --- Analysis ---

  /// BOLT OPTIMIZATION: Use SQL avg instead of manual summation in memory
  Future<int> getAverageRiskLevel() {
    final avgRisk = children.riskLevel.avg();
    final query = selectOnly(children)..addColumns([avgRisk]);
    return query.map((row) => row.read(avgRisk)?.round() ?? 0).getSingle();
  }

  Future<bool> hasEnoughDataForInsights(String childId) async {
    final logs = await (select(activityLogs)
          ..where((t) => t.childId.equals(childId))
          ..limit(1))
        .get();
    return logs.isNotEmpty;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
