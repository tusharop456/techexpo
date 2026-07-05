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

  // Basic query methods
  Future<List<Child>> getAllChildren() => select(children).get();
  Stream<List<Child>> watchChildren() => select(children).watch();

  Stream<List<Alert>> watchAllAlerts() => (select(alerts)..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).watch();
  Stream<List<Alert>> watchPendingAlerts() => (select(alerts)..where((t) => t.isAcknowledged.not())..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).watch();

  Future<List<ActivityLogEntry>> getLast7DaysLogs(String childId) {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return (select(activityLogs)
          ..where((t) => t.childId.equals(childId))
          ..where((t) => t.timestamp.isBiggerThanValue(sevenDaysAgo))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .get();
  }

  Future<List<ActivityLogEntry>> getTodayLogs(String childId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return (select(activityLogs)
          ..where((t) => t.childId.equals(childId))
          ..where((t) => t.timestamp.isBiggerOrEqualValue(today))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .get();
  }

  // Aggregate methods
  Future<int> getUnreadAlertCount() async {
    final count = alerts.id.count();
    final query = selectOnly(alerts)..addColumns([count])..where(alerts.isAcknowledged.not());
    return await query.map((row) => row.read(count)).getSingle() ?? 0;
  }

  Future<int> getAverageRiskLevel() async {
    final avgRisk = children.riskLevel.avg();
    final query = selectOnly(children)..addColumns([avgRisk]);
    final result = await query.map((row) => row.read(avgRisk)).getSingle();
    return result?.toInt() ?? 0;
  }

  Future<int> getActiveChildrenCount() async {
    final now = DateTime.now();
    final activeThreshold = now.subtract(const Duration(hours: 1));
    final count = children.id.count();
    final query = selectOnly(children)
      ..addColumns([count])
      ..where(children.lastActive.isBiggerOrEqualValue(activeThreshold));
    return await query.map((row) => row.read(count)).getSingle() ?? 0;
  }

  Future<bool> hasEnoughDataForInsights(String childId) async {
    final count = activityLogs.id.count();
    final query = selectOnly(activityLogs)
      ..addColumns([count])
      ..where(activityLogs.childId.equals(childId));
    final result = await query.map((row) => row.read(count)).getSingle() ?? 0;
    return result >= 5; // Threshold of 5 logs
  }

  // Update methods
  Future<void> markAllAlertsRead() {
    return (update(alerts)..where((t) => t.isAcknowledged.not()))
        .write(const AlertsCompanion(isAcknowledged: Value(true)));
  }

  Future<void> acknowledgeAlert(String id) {
    return (update(alerts)..where((t) => t.id.equals(id)))
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
