import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:child_safety_monitor/data/models/app_models.dart';

// Generate unique IDs
int _idCounter = 0;
String _generateId() => 'id_${++_idCounter}_${DateTime.now().millisecondsSinceEpoch}';

// ===== CHILDREN STATE =====

class ChildrenNotifier extends StateNotifier<List<ChildModel>> {
  ChildrenNotifier() : super([
    // Demo data
    ChildModel(
      id: 'child_1',
      name: 'Ananya',
      riskLevel: 25,
      lastActive: DateTime.now().subtract(const Duration(minutes: 2)),
      deviceName: 'iPhone 14',
    ),
    ChildModel(
      id: 'child_2',
      name: 'Arjun',
      riskLevel: 65,
      lastActive: DateTime.now().subtract(const Duration(minutes: 15)),
      deviceName: 'Samsung Galaxy S23',
    ),
    ChildModel(
      id: 'child_3',
      name: 'Priya',
      riskLevel: 15,
      lastActive: DateTime.now(),
      deviceName: 'iPad Air',
    ),
  ]);

  void addChild(String name, {String deviceName = 'New Device'}) {
    state = [
      ...state,
      ChildModel(
        id: _generateId(),
        name: name,
        riskLevel: 0,
        lastActive: DateTime.now(),
        deviceName: deviceName,
      ),
    ];
  }

  void updateChild(String id, {String? name, int? riskLevel, String? deviceName}) {
    state = state.map((child) {
      if (child.id == id) {
        return child.copyWith(
          name: name,
          riskLevel: riskLevel,
          deviceName: deviceName,
          lastActive: DateTime.now(),
        );
      }
      return child;
    }).toList();
  }

  void removeChild(String id) {
    state = state.where((child) => child.id != id).toList();
  }
}

final childrenProvider = StateNotifierProvider<ChildrenNotifier, List<ChildModel>>((ref) {
  return ChildrenNotifier();
});

// ===== ALERTS STATE =====

class AlertsNotifier extends StateNotifier<List<AlertModel>> {
  AlertsNotifier() : super([
    AlertModel(
      id: 'alert_1',
      childId: 'child_2',
      childName: 'Arjun',
      title: 'Inappropriate Content Blocked',
      message: 'Attempted to access age-restricted content on YouTube',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      severity: 2,
      category: 'content',
    ),
    AlertModel(
      id: 'alert_2',
      childId: 'child_3',
      childName: 'Priya',
      title: 'Screen Time Limit Reached',
      message: 'Daily screen time limit of 3 hours has been reached',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      severity: 1,
      category: 'time',
    ),
    AlertModel(
      id: 'alert_3',
      childId: 'child_1',
      childName: 'Ananya',
      title: 'New App Installation',
      message: 'Installed "Moj" on her device',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      severity: 1,
      category: 'app',
      isRead: true,
    ),
    AlertModel(
      id: 'alert_4',
      childId: 'child_2',
      childName: 'Arjun',
      title: 'Location Alert',
      message: 'Left the designated safe zone (School)',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      severity: 2,
      category: 'location',
      isRead: true,
    ),
  ]);

  void markAsRead(String id) {
    state = state.map((alert) {
      if (alert.id == id) {
        return alert.copyWith(isRead: true);
      }
      return alert;
    }).toList();
  }

  void markAllAsRead() {
    state = state.map((alert) => alert.copyWith(isRead: true)).toList();
  }

  void addAlert(AlertModel alert) {
    state = [alert, ...state];
  }
}

final alertsProvider = StateNotifierProvider<AlertsNotifier, List<AlertModel>>((ref) {
  return AlertsNotifier();
});

// ===== COMPUTED PROVIDERS =====

final unreadAlertCountProvider = Provider<int>((ref) {
  final alerts = ref.watch(alertsProvider);
  return alerts.where((a) => !a.isRead).length;
});

final averageRiskProvider = Provider<int>((ref) {
  final children = ref.watch(childrenProvider);
  if (children.isEmpty) return 0;
  final total = children.fold<int>(0, (sum, c) => sum + c.riskLevel);
  return (total / children.length).round();
});

final activeChildrenCountProvider = Provider<int>((ref) {
  final children = ref.watch(childrenProvider);
  final thirtyMinsAgo = DateTime.now().subtract(const Duration(minutes: 30));
  return children.where((c) => c.lastActive.isAfter(thirtyMinsAgo)).length;
});

// ===== ACTIVITIES (Static demo data) =====

final activitiesProvider = Provider<List<ActivityModel>>((ref) {
  return [
    ActivityModel(
      id: 'act_1',
      childName: 'Ananya',
      description: 'Completed homework session',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      iconType: 'school',
      colorType: 'success',
    ),
    ActivityModel(
      id: 'act_2',
      childName: 'Arjun',
      description: 'Started YouTube',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      iconType: 'play',
      colorType: 'primary',
    ),
    ActivityModel(
      id: 'act_3',
      childName: 'Priya',
      description: 'Finished gaming session',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      iconType: 'game',
      colorType: 'secondary',
    ),
    ActivityModel(
      id: 'act_4',
      childName: 'System',
      description: 'Content filter blocked access',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      iconType: 'block',
      colorType: 'error',
    ),
  ];
});
