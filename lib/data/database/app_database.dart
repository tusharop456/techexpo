import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Children, Alerts, ActivityLogs])
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

  // Queries
  Future<List<Child>> getAllChildren() => select(children).get();
  Stream<List<Child>> watchChildren() => select(children).watch();

  Future<List<Alert>> getAllAlerts() => select(alerts).get();
  Stream<List<Alert>> watchAllAlerts() => select(alerts).watch();
  Stream<List<Alert>> watchPendingAlerts() =>
    (select(alerts)..where((t) => t.isAcknowledged.equals(false))).watch();

  Future<int> getUnreadAlertCount() async {
    final countExp = alerts.id.count();
    final query = selectOnly(alerts)..addColumns([countExp])..where(alerts.isAcknowledged.equals(false));
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }

  Future acknowledgeAlert(String id) =>
    (update(alerts)..where((t) => t.id.equals(id))).write(const AlertsCompanion(isAcknowledged: Value(true)));

  Future markAllAlertsRead() =>
    update(alerts).write(const AlertsCompanion(isAcknowledged: Value(true)));

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

  Future<List<ActivityLogEntry>> getLast7DaysLogs(String childId) {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return (select(activityLogs)
      ..where((t) => t.childId.equals(childId) & t.timestamp.isBiggerThanValue(sevenDaysAgo)))
      .get();
  }

  Future<List<ActivityLogEntry>> getTodayLogs(String childId) {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    return (select(activityLogs)
      ..where((t) => t.childId.equals(childId) & t.timestamp.isBiggerThanValue(startOfToday)))
      .get();
  }

  Future<bool> hasEnoughDataForInsights(String childId) async {
    final logs = await getLast7DaysLogs(childId);
    return logs.length > 5;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'db.sqlite'));
      return NativeDatabase(file);
    } catch (e) {
      // Fallback for tests or environments where getApplicationDocumentsDirectory fails
      return NativeDatabase.memory();
    }
  });
}
