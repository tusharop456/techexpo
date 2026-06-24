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
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(children);
        await m.createTable(alerts);
        await m.createTable(activityLogs);
        await m.createTable(behavioralEvents);
      }
    },
  );

  // Children
  Future<List<Child>> getAllChildren() => select(children).get();
  Stream<List<Child>> watchChildren() => select(children).watch();

  // Alerts
  Stream<List<Alert>> watchAllAlerts() => (select(alerts)..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).watch();
  Stream<List<Alert>> watchPendingAlerts() => (select(alerts)..where((t) => t.isAcknowledged.not())..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).watch();

  Future<int> getUnreadAlertCount() {
    final query = selectOnly(alerts)..addColumns([alerts.id.count()])..where(alerts.isAcknowledged.not());
    return query.map((row) => row.read(alerts.id.count()) ?? 0).getSingle();
  }

  Future<void> acknowledgeAlert(String id) => (update(alerts)..where((t) => t.id.equals(id))).write(const AlertsCompanion(isAcknowledged: Value(true)));
  Future<void> markAllAlertsRead() => (update(alerts)..where((t) => t.isAcknowledged.not())).write(const AlertsCompanion(isAcknowledged: Value(true)));

  // Activity Logs
  Future<List<ActivityLogEntry>> getTodayLogs(String childId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return (select(activityLogs)
      ..where((t) => t.childId.equals(childId))
      ..where((t) => t.timestamp.isBiggerThanValue(today))
    ).get();
  }

  Future<List<ActivityLogEntry>> getLast7DaysLogs(String childId) {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return (select(activityLogs)
      ..where((t) => t.childId.equals(childId))
      ..where((t) => t.timestamp.isBiggerThanValue(sevenDaysAgo))
    ).get();
  }

  /// Batch fetch logs for multiple children to avoid N+1 queries
  Future<List<ActivityLogEntry>> getLogsForChildren(List<String> childIds, {required bool todayOnly}) {
    final now = DateTime.now();
    final cutoff = todayOnly
        ? DateTime(now.year, now.month, now.day)
        : now.subtract(const Duration(days: 7));

    return (select(activityLogs)
      ..where((t) => t.childId.isIn(childIds))
      ..where((t) => t.timestamp.isBiggerThanValue(cutoff))
    ).get();
  }

  Future<bool> hasEnoughDataForInsights(String childId) async {
    final query = selectOnly(activityLogs)
      ..addColumns([activityLogs.id.count()])
      ..where(activityLogs.childId.equals(childId));
    final count = await query.map((row) => row.read(activityLogs.id.count()) ?? 0).getSingle();
    return count >= 5;
  }

  /// Batch check if children have enough data for insights
  Future<Map<String, bool>> getEnoughDataStatusForChildren(List<String> childIds) async {
    if (childIds.isEmpty) return {};

    final countQuery = await customSelect(
      'SELECT child_id, COUNT(*) as c FROM activity_logs WHERE child_id IN (${childIds.map((_) => '?').join(',')}) GROUP BY child_id HAVING c >= 5',
      variables: childIds.map((id) => Variable<String>(id)).toList(),
    ).get();

    final childrenWithEnoughData = countQuery.map((row) => row.read<String>('child_id')).toSet();

    return {
      for (final id in childIds) id: childrenWithEnoughData.contains(id)
    };
  }

  // Dashboard Metrics
  Future<int> getAverageRiskLevel() async {
    final query = selectOnly(children)..addColumns([children.riskLevel.avg()]);
    final avg = await query.map((row) => row.read(children.riskLevel.avg())).getSingle();
    return avg?.round() ?? 0;
  }

  Future<int> getActiveChildrenCount() async {
    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    final query = selectOnly(children)
      ..addColumns([children.id.count()])
      ..where(children.lastActive.isBiggerThanValue(oneHourAgo));
    return query.map((row) => row.read(children.id.count()) ?? 0).getSingle();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
