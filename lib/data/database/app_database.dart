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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(children);
        await m.createTable(alerts);
        await m.createTable(activityLogs);
        await m.createTable(behavioralEvents);
      }
    },
  );

  // Children methods
  Future<List<Child>> getAllChildren() => select(children).get();
  Stream<List<Child>> watchChildren() => select(children).watch();

  // Alerts methods
  Future<List<Alert>> getAllAlerts() => select(alerts).get();
  Stream<List<Alert>> watchAllAlerts() => (select(alerts)..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).watch();
  Stream<List<Alert>> watchPendingAlerts() => (select(alerts)..where((t) => t.isAcknowledged.equals(false))).watch();

  Future<int> getUnreadAlertCount() {
    final count = countAll();
    final query = selectOnly(alerts)..addColumns([count])..where(alerts.isAcknowledged.equals(false));
    return query.map((row) => row.read(count) ?? 0).getSingle();
  }

  Future markAllAlertsRead() => (update(alerts)..where((t) => t.isAcknowledged.equals(false))).write(const AlertsCompanion(isAcknowledged: Value(true)));
  Future acknowledgeAlert(String id) => (update(alerts)..where((t) => t.id.equals(id))).write(const AlertsCompanion(isAcknowledged: Value(true)));

  // ActivityLogs methods
  Future<List<ActivityLogEntry>> getTodayLogs(String childId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return (select(activityLogs)
          ..where((t) => t.childId.equals(childId) & t.timestamp.isBiggerOrEqualValue(today)))
        .get();
  }

  Future<List<ActivityLogEntry>> getLast7DaysLogs(String childId) {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return (select(activityLogs)
          ..where((t) => t.childId.equals(childId) & t.timestamp.isBiggerOrEqualValue(sevenDaysAgo)))
        .get();
  }

  Future<bool> hasEnoughDataForInsights(String childId) async {
    final countExp = countAll();
    final query = selectOnly(activityLogs)
      ..addColumns([countExp])
      ..where(activityLogs.childId.equals(childId));
    final count = await query.map((row) => row.read(countExp) ?? 0).getSingle();
    return count >= 3;
  }

  // Dashboard Stats
  Future<int> getAverageRiskLevel() async {
    final avgRisk = children.riskLevel.avg();
    final query = selectOnly(children)..addColumns([avgRisk]);
    final result = await query.map((row) => row.read(avgRisk)).getSingle();
    return result?.round() ?? 0;
  }

  Future<int> getActiveChildrenCount() {
    final now = DateTime.now();
    final activeThreshold = now.subtract(const Duration(hours: 1));
    final countExp = countAll();
    final query = selectOnly(children)
      ..addColumns([countExp])
      ..where(children.lastActive.isBiggerOrEqualValue(activeThreshold));
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
