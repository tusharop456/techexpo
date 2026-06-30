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

  // --- Children Queries ---

  Future<List<ChildData>> getAllChildren() => select(children).get();

  Stream<List<ChildData>> watchChildren() => select(children).watch();

  Future<int> getActiveChildrenCount() async {
    // ⚡ BOLT OPTIMIZATION: Use SQL COUNT instead of fetching all rows
    final countExp = children.id.count();
    final query = selectOnly(children)..addColumns([countExp])..where(children.lastActive.isNotNull());
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }

  // --- Activity Log Queries ---

  Future<List<ActivityLogData>> getLast7DaysLogs(String childId) {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return (select(activityLogs)
          ..where((t) => t.childId.equals(childId))
          ..where((t) => t.timestamp.isBiggerThanValue(sevenDaysAgo)))
        .get();
  }

  Future<List<ActivityLogData>> getTodayLogs(String childId) {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    return (select(activityLogs)
          ..where((t) => t.childId.equals(childId))
          ..where((t) => t.timestamp.isBiggerThanValue(startOfToday)))
        .get();
  }

  Future<bool> hasEnoughDataForInsights(String childId) async {
    final logs = await (select(activityLogs)
          ..where((t) => t.childId.equals(childId))
          ..limit(10))
        .get();
    return logs.length >= 5;
  }

  // --- Alert Queries ---

  Stream<List<Alert>> watchAllAlerts() =>
    (select(alerts)..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).watch();

  Stream<List<Alert>> watchPendingAlerts() =>
    (select(alerts)..where((t) => t.isAcknowledged.equals(false))..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).watch();

  Future<int> getUnreadAlertCount() async {
    // ⚡ BOLT OPTIMIZATION: Use SQL COUNT instead of fetching all rows
    final countExp = alerts.id.count();
    final query = selectOnly(alerts)..addColumns([countExp])..where(alerts.isAcknowledged.equals(false));
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }

  Future<void> markAllAlertsRead() {
    return (update(alerts)..where((t) => t.isAcknowledged.equals(false)))
        .write(const AlertsCompanion(isAcknowledged: Value(true)));
  }

  Future<void> acknowledgeAlert(String id) {
    return (update(alerts)..where((t) => t.id.equals(id)))
        .write(const AlertsCompanion(isAcknowledged: Value(true)));
  }

  // --- Analytics Queries ---

  Future<int> getAverageRiskLevel() async {
    // ⚡ BOLT OPTIMIZATION: Use SQL AVG instead of calculating in Dart
    final avgExp = children.riskLevel.avg();
    final query = selectOnly(children)..addColumns([avgExp]);
    final result = await query.map((row) => row.read(avgExp)).getSingle();
    return result?.round() ?? 0;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
