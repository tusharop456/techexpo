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

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          // Add missing tables in version 2
          await m.createTable(children);
          await m.createTable(alerts);
          await m.createTable(activityLogs);
          await m.createTable(behavioralEvents);
        }
      },
      beforeOpen: (details) async {
        if (details.wasCreated) {
          // Initialize with some data if needed
        }
      },
    );
  }

  // --- Child Queries ---
  Future<List<Child>> getAllChildren() => select(children).get();
  Stream<List<Child>> watchChildren() => select(children).watch();

  Future<int> getActiveChildrenCount() async {
    final now = DateTime.now();
    final oneHourAgo = now.subtract(const Duration(hours: 1));
    final query = select(children)..where((t) => t.lastActive.isBiggerOrEqualValue(oneHourAgo));
    final results = await query.get();
    return results.length;
  }

  Future<int> getAverageRiskLevel() async {
    final results = await select(children).get();
    if (results.isEmpty) return 0;
    final totalRisk = results.fold<int>(0, (sum, child) => sum + child.riskLevel);
    return (totalRisk / results.length).round();
  }

  // --- Activity Log Queries ---
  Future<List<ActivityLogEntry>> getTodayLogs(String childId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return (select(activityLogs)
          ..where((t) => t.childId.equals(childId))
          ..where((t) => t.timestamp.isBiggerOrEqualValue(today)))
        .get();
  }

  Future<List<ActivityLogEntry>> getLast7DaysLogs(String childId) {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return (select(activityLogs)
          ..where((t) => t.childId.equals(childId))
          ..where((t) => t.timestamp.isBiggerOrEqualValue(sevenDaysAgo)))
        .get();
  }

  Future<bool> hasEnoughDataForInsights(String childId) async {
    final query = select(activityLogs)..where((t) => t.childId.equals(childId))..limit(6);
    final results = await query.get();
    return results.length > 5;
  }

  // --- Alert Queries ---
  Stream<List<Alert>> watchAllAlerts() => (select(alerts)..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).watch();
  Stream<List<Alert>> watchPendingAlerts() => (select(alerts)..where((t) => t.isAcknowledged.equals(false))..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).watch();

  Future<int> getUnreadAlertCount() async {
    final query = select(alerts)..where((t) => t.isAcknowledged.equals(false));
    final results = await query.get();
    return results.length;
  }

  Future<int> markAllAlertsRead([String? childId]) {
    final query = update(alerts);
    if (childId != null) {
      query.where((t) => t.childId.equals(childId));
    }
    return query.write(const AlertsCompanion(isAcknowledged: Value(true)));
  }

  Future<bool> acknowledgeAlert(String alertId) async {
    final updatedRows = await (update(alerts)..where((t) => t.id.equals(alertId)))
        .write(const AlertsCompanion(isAcknowledged: Value(true)));
    return updatedRows > 0;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
