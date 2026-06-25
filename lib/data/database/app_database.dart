import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Children, Alerts, ActivityLogs, BehavioralEvents])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // Version 2 added Children, Alerts, ActivityLogs, and BehavioralEvents
            await m.createTable(children);
            await m.createTable(alerts);
            await m.createTable(activityLogs);
            await m.createTable(behavioralEvents);
          }
        },
      );

  // --- Query Methods ---

  // Children
  Future<List<Child>> getAllChildren() => select(children).get();
  Stream<List<Child>> watchChildren() => select(children).watch();

  // Alerts
  Stream<List<Alert>> watchAllAlerts() => (select(alerts)..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).watch();
  Stream<List<Alert>> watchPendingAlerts() => (select(alerts)..where((t) => t.isAcknowledged.equals(false))..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).watch();
  Future<int> getUnreadAlertCount() {
    final count = countAll();
    final query = selectOnly(alerts)..addColumns([count])..where(alerts.isAcknowledged.equals(false));
    return query.map((row) => row.read(count) ?? 0).getSingle();
  }
  Future<void> markAllAlertsRead() => (update(alerts)..where((t) => t.isAcknowledged.equals(false))).write(const AlertsCompanion(isAcknowledged: Value(true)));
  Future<void> acknowledgeAlert(String id) => (update(alerts)..where((t) => t.id.equals(id))).write(const AlertsCompanion(isAcknowledged: Value(true)));

  // Risk & Activity Metrics
  Future<int> getAverageRiskLevel() async {
    final avgRisk = children.riskLevel.avg();
    final query = selectOnly(children)..addColumns([avgRisk]);
    final result = await query.map((row) => row.read(avgRisk)).getSingle();
    return result?.toInt() ?? 0;
  }
  Future<int> getActiveChildrenCount() async {
    final count = countAll();
    final query = selectOnly(children)..addColumns([count]);
    return query.map((row) => row.read(count) ?? 0).getSingle();
  }

  // Activity Logs
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

  Future<bool> hasEnoughDataForInsights(String childId) async {
    final count = countAll();
    final query = selectOnly(activityLogs)
      ..addColumns([count])
      ..where(activityLogs.childId.equals(childId));
    final result = await query.map((row) => row.read(count) ?? 0).getSingle();
    return result >= 5; // Arbitrary threshold for "enough data"
  }

  // --- Batch Optimization Methods ---

  /// Get activity logs for multiple children in a single query
  Future<List<ActivityLogEntry>> getLogsForChildren(List<String> childIds, {DateTime? after}) {
    var query = select(activityLogs)..where((t) => t.childId.isIn(childIds));
    if (after != null) {
      query = query..where((t) => t.timestamp.isBiggerThanValue(after));
    }
    return query.get();
  }

  /// Check enough data status for multiple children in a single query
  Future<Map<String, bool>> getEnoughDataStatusForChildren(List<String> childIds) async {
    final count = countAll();
    final query = selectOnly(activityLogs)
      ..addColumns([activityLogs.childId, count])
      ..where(activityLogs.childId.isIn(childIds))
      ..groupBy([activityLogs.childId]);

    final results = await query.get();
    final statusMap = {for (var id in childIds) id: false};

    for (final row in results) {
      final id = row.read(activityLogs.childId)!;
      final c = row.read(count) ?? 0;
      statusMap[id] = c >= 5;
    }

    return statusMap;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
