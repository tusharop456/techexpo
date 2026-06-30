import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:child_safety_monitor/data/database/app_database.dart';
import 'package:child_safety_monitor/data/models/app_models.dart';

// Provides the single database instance to the whole app
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// Provides a stream of all children
final childrenStreamProvider = StreamProvider<List<ChildData>>((ref) {
  return ref.watch(databaseProvider).watchChildren();
});

// Provides a stream of all alerts
final alertsStreamProvider = StreamProvider<List<Alert>>((ref) {
  return ref.watch(databaseProvider).watchAllAlerts();
});

// Provides a stream of unacknowledged alerts
final pendingAlertsStreamProvider = StreamProvider<List<Alert>>((ref) {
  return ref.watch(databaseProvider).watchPendingAlerts();
});

// State provider to track which child is currently selected for the dashboard
final selectedChildIdProvider = StateProvider<String?>((ref) => null);

// Provider for unread alert count
final unreadAlertCountProvider = FutureProvider<int>((ref) {
  return ref.watch(databaseProvider).getUnreadAlertCount();
});

// Provider for average risk level
final averageRiskProvider = FutureProvider<int>((ref) {
  return ref.watch(databaseProvider).getAverageRiskLevel();
});

// Provider for active children count
final activeChildrenCountProvider = FutureProvider<int>((ref) {
  return ref.watch(databaseProvider).getActiveChildrenCount();
});

// Mapped Alerts Provider (DB -> UI Model)
final mappedAlertsProvider = Provider<AsyncValue<List<AlertModel>>>((ref) {
  final alertsAsync = ref.watch(alertsStreamProvider);
  final childrenAsync = ref.watch(childrenStreamProvider);

  if (alertsAsync.isLoading || childrenAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (alertsAsync.hasError) return AsyncValue.error(alertsAsync.error!, alertsAsync.stackTrace!);
  if (childrenAsync.hasError) return AsyncValue.error(childrenAsync.error!, childrenAsync.stackTrace!);

  final alerts = alertsAsync.value ?? [];
  final children = childrenAsync.value ?? [];
  final childrenMap = {for (var c in children) c.id: c.name};

  final mapped = alerts.map((alert) {
    return AlertModel(
      id: alert.id,
      childId: alert.childId,
      childName: childrenMap[alert.childId] ?? 'Unknown',
      title: alert.title,
      message: alert.message,
      timestamp: alert.timestamp,
      isRead: alert.isAcknowledged,
      severity: alert.severity,
      category: alert.category, 
    );
  }).toList();

  return AsyncValue.data(mapped);
});