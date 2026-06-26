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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Create tables that were missing in version 1
        await m.createTable(children);
        await m.createTable(alerts);
        await m.createTable(activityLogs);
        await m.createTable(behavioralEvents);
      }
    },
  );

  // Data watching methods
  Stream<List<Child>> watchChildren() => select(children).watch();
  Stream<List<Alert>> watchAllAlerts() => select(alerts).watch();
  Stream<List<Alert>> watchPendingAlerts() =>
      (select(alerts)..where((t) => t.isAcknowledged.equals(false))).watch();

  // Dashboard metric methods
  Future<int> getUnreadAlertCount() async {
    final countExp = alerts.id.count();
    final query = selectOnly(alerts)..addColumns([countExp])..where(alerts.isAcknowledged.equals(false));
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }

  Future<int> getAverageRiskLevel() async {
    final avgRisk = children.riskLevel.avg();
    final query = selectOnly(children)..addColumns([avgRisk]);
    final result = await query.map((row) => row.read(avgRisk)).getSingle();
    return result?.round() ?? 0;
  }

  Future<int> getActiveChildrenCount() async {
    final thirtyMinsAgo = DateTime.now().subtract(const Duration(minutes: 30));
    final countExp = children.id.count();
    final query = selectOnly(children)..addColumns([countExp])..where(children.lastActive.isBiggerThanValue(thirtyMinsAgo));
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }

  // Insight and alert action methods
  Future<List<Child>> getAllChildren() => select(children).get();

  Future<bool> hasEnoughDataForInsights(String childId) async {
    final countExp = activityLogs.id.count();
    final query = selectOnly(activityLogs)
      ..addColumns([countExp])
      ..where(activityLogs.childId.equals(childId));
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return (result ?? 0) >= 5; // Require at least 5 logs
  }

  Future<List<ActivityLogEntry>> getLast7DaysLogs(String childId) {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return (select(activityLogs)
          ..where((t) => t.childId.equals(childId))
          ..where((t) => t.timestamp.isBiggerThanValue(sevenDaysAgo)))
        .get();
  }

  Future<List<ActivityLogEntry>> getTodayLogs(String childId) {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    return (select(activityLogs)
          ..where((t) => t.childId.equals(childId))
          ..where((t) => t.timestamp.isBiggerThanValue(startOfToday)))
        .get();
  }

  Future<void> markAllAlertsRead() async {
    await (update(alerts)..where((t) => t.isAcknowledged.equals(false)))
        .write(const AlertsCompanion(isAcknowledged: Value(true)));
  }

  Future<void> acknowledgeAlert(String alertId) async {
    await (update(alerts)..where((t) => t.id.equals(alertId)))
        .write(const AlertsCompanion(isAcknowledged: Value(true)));
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
