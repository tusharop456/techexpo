import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Children, Alerts, ActivityLogs, BehavioralEvents, Todos])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());
  AppDatabase.forTesting(QueryExecutor e) : super(e);

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
    final countExp = activityLogs.id.count();
    final query = selectOnly(activityLogs)
      ..addColumns([countExp])
      ..where(activityLogs.childId.equals(childId));
    final result = await query.getSingle();
    final count = result.read(countExp) ?? 0;
    return count >= 10; // Threshold for insights
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
