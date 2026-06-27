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

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // Added several tables in version 2
            await m.createTable(children);
            await m.createTable(alerts);
            await m.createTable(activityLogs);
            await m.createTable(behavioralEvents);
          }
        },
      );

  // --- Children Methods ---

  Future<List<Child>> getAllChildren() => select(children).get();

  Stream<List<Child>> watchChildren() => select(children).watch();

  Future<int> getActiveChildrenCount() async {
    final count = children.id.count();
    final query = selectOnly(children)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Future<int> getAverageRiskLevel() async {
    final avg = children.riskLevel.avg();
    final query = selectOnly(children)..addColumns([avg]);
    final result = await query.getSingle();
    return (result.read(avg) ?? 0).round();
  }

  // --- Alerts Methods ---

  Future<List<Alert>> getAllAlerts() => select(alerts).get();

  Stream<List<Alert>> watchAllAlerts() => (select(alerts)..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).watch();

  Stream<List<Alert>> watchPendingAlerts() => (select(alerts)
        ..where((t) => t.isAcknowledged.equals(false))
        ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
      .watch();

  Future<int> getUnreadAlertCount() async {
    final count = alerts.id.count();
    final query = selectOnly(alerts)
      ..where(alerts.isAcknowledged.equals(false))
      ..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Future<void> acknowledgeAlert(String id) {
    return (update(alerts)..where((t) => t.id.equals(id))).write(const AlertsCompanion(isAcknowledged: Value(true)));
  }

  Future<void> markAllAlertsRead() {
    return (update(alerts)..where((t) => t.isAcknowledged.equals(false))).write(const AlertsCompanion(isAcknowledged: Value(true)));
  }

  // --- ActivityLogs Methods ---

  Future<List<ActivityLogEntry>> getLast7DaysLogs(String childId) {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return (select(activityLogs)
          ..where((t) => t.childId.equals(childId))
          ..where((t) => t.timestamp.isBiggerThanValue(sevenDaysAgo)))
        .get();
  }

  Future<List<ActivityLogEntry>> getTodayLogs(String childId) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    return (select(activityLogs)
          ..where((t) => t.childId.equals(childId))
          ..where((t) => t.timestamp.isBiggerThanValue(todayStart)))
        .get();
  }

  Future<bool> hasEnoughDataForInsights(String childId) async {
    final count = activityLogs.id.count();
    final query = selectOnly(activityLogs)
      ..where(activityLogs.childId.equals(childId))
      ..addColumns([count])
      ..limit(5);
    final result = await query.getSingle();
    return (result.read(count) ?? 0) >= 5;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
