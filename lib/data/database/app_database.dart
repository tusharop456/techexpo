import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Todos, Children, Alerts, ActivityLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(children);
            await m.createTable(alerts);
            await m.createTable(activityLogs);
          }
        },
      );

  // Children
  Future<List<Child>> getAllChildren() => select(children).get();

  // Activity Logs
  Future<List<ActivityLogEntry>> getTodayLogs(String childId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return (select(activityLogs)
          ..where((t) => t.childId.equals(childId))
          ..where((t) => t.timestamp.isBiggerThanValue(today)))
        .get();
  }

  Future<List<ActivityLogEntry>> getLast7DaysLogs(String childId) {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return (select(activityLogs)
          ..where((t) => t.childId.equals(childId))
          ..where((t) => t.timestamp.isBiggerThanValue(sevenDaysAgo)))
        .get();
  }

  Future<bool> hasEnoughDataForInsights(String childId) async {
    final countExp = activityLogs.id.count();
    final query = selectOnly(activityLogs)..addColumns([countExp]);
    query.where(activityLogs.childId.equals(childId));
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return (result ?? 0) >= 5; // Need at least 5 logs
  }

  Future<Map<String, bool>> getEnoughDataStatusForChildren(List<String> childIds) async {
    if (childIds.isEmpty) return {};
    final countExp = activityLogs.id.count();
    final query = selectOnly(activityLogs)
      ..addColumns([activityLogs.childId, countExp])
      ..where(activityLogs.childId.isIn(childIds))
      ..groupBy([activityLogs.childId]);

    final results = await query.map((row) {
      return MapEntry(row.read(activityLogs.childId)!, (row.read(countExp) ?? 0) >= 5);
    }).get();

    return Map.fromEntries(results);
  }

  Future<List<ActivityLogEntry>> getLogsForChildren(List<String> childIds, DateTime since) {
    if (childIds.isEmpty) return Future.value([]);
    return (select(activityLogs)
          ..where((t) => t.childId.isIn(childIds))
          ..where((t) => t.timestamp.isBiggerThanValue(since)))
        .get();
  }

  // Alerts
  Stream<List<Alert>> watchAllAlerts() => select(alerts).watch();
  Stream<List<Alert>> watchPendingAlerts() => (select(alerts)..where((t) => t.isAcknowledged.equals(false))).watch();

  Future<int> getUnreadAlertCount() async {
    final countExp = alerts.id.count();
    final query = selectOnly(alerts)..addColumns([countExp]);
    query.where(alerts.isAcknowledged.equals(false));
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }

  Future<void> acknowledgeAlert(String id) => (update(alerts)..where((t) => t.id.equals(id))).write(const AlertsCompanion(isAcknowledged: Value(true)));
  Future<void> markAllAlertsRead() => update(alerts).write(const AlertsCompanion(isAcknowledged: Value(true)));

  // Dashboard Stats
  Stream<List<Child>> watchChildren() => select(children).watch();

  Future<int> getAverageRiskLevel() async {
    final avgRisk = children.riskLevel.avg();
    final query = selectOnly(children)..addColumns([avgRisk]);
    final result = await query.map((row) => row.read(avgRisk)).getSingle();
    return (result ?? 0.0).round();
  }

  Future<int> getActiveChildrenCount() async {
    final countExp = children.id.count();
    final query = selectOnly(children)..addColumns([countExp]);
    // Active if lastActive was within the last 24 hours
    final dayAgo = DateTime.now().subtract(const Duration(days: 1));
    query.where(children.lastActive.isBiggerThanValue(dayAgo));
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
