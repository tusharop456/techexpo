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
  int get schemaVersion => 2; // Bumped schema version to include new tables

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Keep Todos if it exists, create others
        await m.createTable(children);
        await m.createTable(alerts);
        await m.createTable(activityLogs);
        await m.createTable(behavioralEvents);
      }
    },
  );

  // --- Children Queries ---
  Future<List<Child>> getAllChildren() => select(children).get();
  Stream<List<Child>> watchChildren() => select(children).watch();

  /// Optimized: Uses SQL COUNT instead of fetching all rows
  Future<int> getActiveChildrenCount() async {
    final thirtyMinsAgo = DateTime.now().subtract(const Duration(minutes: 30));
    final countExp = children.id.count();
    final query = selectOnly(children)
      ..addColumns([countExp])
      ..where(children.lastActive.isBiggerThanValue(thirtyMinsAgo));
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }

  /// Optimized: Uses SQL AVG directly
  Future<int> getAverageRiskLevel() async {
    final avgExp = children.riskLevel.avg();
    final query = selectOnly(children)..addColumns([avgExp]);
    final result = await query.map((row) => row.read(avgExp)).getSingle();
    return result?.toInt() ?? 0;
  }

  // --- Alert Queries ---
  Stream<List<Alert>> watchAllAlerts() => (select(alerts)..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).watch();
  Stream<List<Alert>> watchPendingAlerts() => (select(alerts)..where((t) => t.isAcknowledged.equals(false))..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).watch();

  /// Optimized: Uses SQL COUNT instead of fetching all rows
  Future<int> getUnreadAlertCount() async {
    final countExp = alerts.id.count();
    final query = selectOnly(alerts)
      ..addColumns([countExp])
      ..where(alerts.isAcknowledged.equals(false));
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }
  Future<void> acknowledgeAlert(String alertId) async {
    await (update(alerts)..where((t) => t.id.equals(alertId))).write(const AlertsCompanion(isAcknowledged: Value(true)));
  }
  Future<void> markAllAlertsRead() async {
    await (update(alerts)..where((t) => t.isAcknowledged.equals(false))).write(const AlertsCompanion(isAcknowledged: Value(true)));
  }

  // --- Activity Log Queries ---
  Future<bool> hasEnoughDataForInsights(String childId) async {
    final query = select(activityLogs)..where((t) => t.childId.equals(childId))..limit(10);
    final results = await query.get();
    return results.length >= 5;
  }

  Future<List<ActivityLogEntry>> getLast7DaysLogs(String childId) {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return (select(activityLogs)
      ..where((t) => t.childId.equals(childId) & t.timestamp.isBiggerThanValue(sevenDaysAgo))
      ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
      .get();
  }

  Future<List<ActivityLogEntry>> getTodayLogs(String childId) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    return (select(activityLogs)
      ..where((t) => t.childId.equals(childId) & t.timestamp.isBiggerThanValue(todayStart))
      ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
      .get();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
