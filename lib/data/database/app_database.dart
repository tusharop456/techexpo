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
  int get schemaVersion => 2;

  // Children methods
  Future<List<Child>> getAllChildren() => select(children).get();
  Stream<List<Child>> watchChildren() => select(children).watch();

  // Alerts methods
  Stream<List<Alert>> watchAllAlerts() => (select(alerts)..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).watch();
  Stream<List<Alert>> watchPendingAlerts() => (select(alerts)..where((t) => t.isAcknowledged.not())..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).watch();

  Future<int> getUnreadAlertCount() async {
    final countExp = alerts.id.count();
    final query = selectOnly(alerts)..addColumns([countExp])..where(alerts.isAcknowledged.not());
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }

  Future<void> markAllAlertsRead() async {
    await (update(alerts)..where((t) => t.isAcknowledged.not())).write(const AlertsCompanion(isAcknowledged: Value(true)));
  }

  Future<void> acknowledgeAlert(String id) async {
    await (update(alerts)..where((t) => t.id.equals(id))).write(const AlertsCompanion(isAcknowledged: Value(true)));
  }

  // Logs methods
  Future<List<ActivityLogEntry>> getLast7DaysLogs(String childId) {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return (select(activityLogs)
          ..where((t) => t.childId.equals(childId))
          ..where((t) => t.timestamp.isBiggerThan(Constant(sevenDaysAgo)))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .get();
  }

  Future<List<ActivityLogEntry>> getTodayLogs(String childId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return (select(activityLogs)
          ..where((t) => t.childId.equals(childId))
          ..where((t) => t.timestamp.isBiggerThan(Constant(today)))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .get();
  }

  Future<bool> hasEnoughDataForInsights(String childId) async {
    final countExp = activityLogs.id.count();
    final query = selectOnly(activityLogs)..addColumns([countExp])..where(activityLogs.childId.equals(childId));
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return (result ?? 0) >= 5; // Arbitrary threshold
  }

  // Metrics
  Future<int> getAverageRiskLevel() async {
    final avgExp = children.riskLevel.avg();
    final query = selectOnly(children)..addColumns([avgExp]);
    final result = await query.map((row) => row.read(avgExp)).getSingle();
    return result?.toInt() ?? 0;
  }

  Future<int> getActiveChildrenCount() async {
    final now = DateTime.now();
    final activeThreshold = now.subtract(const Duration(hours: 24));
    final countExp = children.id.count();
    final query = selectOnly(children)..addColumns([countExp])..where(children.lastActive.isBiggerThan(Constant(activeThreshold)));
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
