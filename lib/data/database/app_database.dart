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

  // Children
  Future<List<Child>> getAllChildren() => select(children).get();
  Stream<List<Child>> watchChildren() => select(children).watch();

  Future<int> getActiveChildrenCount() async {
    final thirtyMinsAgo = DateTime.now().subtract(const Duration(minutes: 30));
    final countExp = children.id.count();
    final query = selectOnly(children)
      ..addColumns([countExp])
      ..where(children.lastActive.isBiggerThanValue(thirtyMinsAgo));
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  Future<int> getAverageRiskLevel() async {
    final query = selectOnly(children)..addColumns([children.riskLevel.avg()]);
    final result = await query.getSingle();
    final avg = result.read(children.riskLevel.avg());
    return avg?.round() ?? 0;
  }

  // Alerts
  Stream<List<Alert>> watchAllAlerts() => select(alerts).watch();
  Stream<List<Alert>> watchPendingAlerts() =>
    (select(alerts)..where((t) => t.isAcknowledged.equals(false))).watch();

  Future<int> getUnreadAlertCount() async {
    final countExp = alerts.id.count();
    final query = selectOnly(alerts)
      ..addColumns([countExp])
      ..where(alerts.isAcknowledged.equals(false));
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  Future<void> markAllAlertsRead() =>
    (update(alerts)..where((t) => t.isAcknowledged.equals(false)))
      .write(const AlertsCompanion(isAcknowledged: Value(true)));

  Future<void> acknowledgeAlert(String id) =>
    (update(alerts)..where((t) => t.id.equals(id)))
      .write(const AlertsCompanion(isAcknowledged: Value(true)));

  // Activity Logs
  Future<List<ActivityLogEntry>> getLast7DaysLogs(String childId) {
    return getAllLast7DaysLogs([childId]);
  }

  /// BOLT: Batch fetch logs for multiple children to prevent N+1 queries
  Future<List<ActivityLogEntry>> getAllLast7DaysLogs(List<String> childIds) {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return (select(activityLogs)
      ..where((t) => t.childId.isIn(childIds))
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
    final statusMap = await getManyHasEnoughData([childId]);
    return statusMap[childId] ?? false;
  }

  /// BOLT: Batch check insight eligibility using GROUP BY to prevent N+1 queries
  Future<Map<String, bool>> getManyHasEnoughData(List<String> childIds) async {
    final countExp = activityLogs.id.count();
    final query = selectOnly(activityLogs)
      ..addColumns([activityLogs.childId, countExp])
      ..where(activityLogs.childId.isIn(childIds))
      ..groupBy([activityLogs.childId]);

    final results = await query.get();

    final statusMap = <String, bool>{};
    for (final row in results) {
      final id = row.read(activityLogs.childId);
      final count = row.read(countExp) ?? 0;
      if (id != null) statusMap[id] = count >= 10;
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
