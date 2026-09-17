import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:child_safety_monitor/core/constants/app_colors.dart';
import 'package:child_safety_monitor/data/models/app_models.dart';
import 'package:child_safety_monitor/providers/database_provider.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(mappedAlertsProvider);
    final alerts = alertsAsync.value ?? [];

    // Performance optimization: Single-pass O(N) traversal to partition alerts and count metrics
    // instead of running 5 separate .where() linear scans.
    int unreadCount = 0;
    int criticalCount = 0;
    final List<AlertModel> criticalAlerts = [];
    final List<AlertModel> resolvedAlerts = [];

    for (final a in alerts) {
      if (!a.isRead) {
        unreadCount++;
      } else {
        resolvedAlerts.add(a);
      }
      if (a.severity == 2) {
        criticalCount++;
        criticalAlerts.add(a);
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(unreadCount),
          _buildTabBar(totalCount: alerts.length, criticalCount: criticalCount),
          Expanded(
            child: _buildAlertsList(
              allAlerts: alerts,
              criticalAlerts: criticalAlerts,
              resolvedAlerts: resolvedAlerts,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int unreadCount) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Safety Alerts', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: -1)),
              const SizedBox(height: 4),
              Text('$unreadCount unread alerts requiring attention', style: const TextStyle(fontSize: 15, color: AppColors.textSecondary)),
            ],
          ),
          Row(
            children: [
              _buildActionButton(Icons.check_circle_outline_rounded, 'Mark all read', () {
                ref.read(databaseProvider).markAllAlertsRead();
              }),
              const SizedBox(width: 12),
              _buildActionButton(Icons.filter_list_rounded, 'Filter', null),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback? onTap) {
    return Material(
      color: AppColors.glass.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar({required int totalCount, required int criticalCount}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: AppColors.glass.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.15)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: const Color(0xFF667EEA).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.all(6),
        tabs: [
          Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('All'), const SizedBox(width: 8), _buildBadge('$totalCount', false)])),
          Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('Critical'), const SizedBox(width: 8), _buildBadge('$criticalCount', true)])),
          const Tab(text: 'Resolved'),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, bool isError) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isError ? AppColors.error.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isError ? AppColors.error : null)),
    );
  }

  Widget _buildAlertsList({
    required List<AlertModel> allAlerts,
    required List<AlertModel> criticalAlerts,
    required List<AlertModel> resolvedAlerts,
  }) {
    return TabBarView(
      controller: _tabController,
      // Smooth swipe physics for premium feel
      physics: const BouncingScrollPhysics(),
      children: [
        _buildAlertsListView(allAlerts, 'all'),
        _buildAlertsListView(criticalAlerts, 'critical'),
        _buildAlertsListView(resolvedAlerts, 'resolved'),
      ],
    );
  }

  Widget _buildAlertsListView(List<AlertModel> alerts, String tabKey) {
    if (alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Icons.check_circle_rounded, size: 56, color: AppColors.success.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 20),
            const Text('No alerts in this category', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text('All clear!', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(32),
      itemCount: alerts.length,
      itemBuilder: (ctx, i) => _buildSwipeableAlertCard(alerts[i], i),
    );
  }

  /// Swipeable alert card with dismiss animation
  Widget _buildSwipeableAlertCard(AlertModel alert, int index) {
    return Dismissible(
      key: Key('alert_${alert.id}'),
      direction: DismissDirection.horizontal,
      // Swipe right to mark as read, left to delete
      background: _buildSwipeBackground(
        alignment: Alignment.centerLeft,
        color: AppColors.success,
        icon: Icons.check_circle_rounded,
        label: 'Mark Read',
      ),
      secondaryBackground: _buildSwipeBackground(
        alignment: Alignment.centerRight,
        color: AppColors.error,
        icon: Icons.delete_rounded,
        label: 'Dismiss',
      ),
        confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Mark as read
          ref.read(databaseProvider).acknowledgeAlert(alert.id);
          return false; // Don't remove from list, just mark read
        }
        return true; // Allow dismiss for delete direction
      },
      onDismissed: (direction) {
        // Could add delete functionality here
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 300 + (index * 50)),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: _buildAlertCard(alert),
      ),
    );
  }

  Widget _buildSwipeBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: alignment == Alignment.centerLeft
            ? [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
              ]
            : [
                Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(width: 12),
                Icon(icon, color: color, size: 28),
              ],
      ),
    );
  }

  Widget _buildAlertCard(AlertModel alert) {
    final severityColor = alert.severity == 2 ? AppColors.error : AppColors.warning;
    
    IconData categoryIcon;
    switch (alert.category) {
      case 'content': categoryIcon = Icons.block_rounded; break;
      case 'time': categoryIcon = Icons.schedule_rounded; break;
      case 'app': categoryIcon = Icons.apps_rounded; break;
      case 'location': categoryIcon = Icons.location_on_rounded; break;
      case 'social': categoryIcon = Icons.chat_rounded; break;
      default: categoryIcon = Icons.notifications_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.glass.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: alert.isRead ? Border.all(color: AppColors.glassBorder.withValues(alpha: 0.1)) : Border.all(color: severityColor.withValues(alpha: 0.4), width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => ref.read(databaseProvider).acknowledgeAlert(alert.id),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(categoryIcon, color: severityColor, size: 26),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (!alert.isRead)
                            Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(color: severityColor, shape: BoxShape.circle),
                            ),
                          Expanded(
                            child: Text(
                              alert.title,
                              style: TextStyle(fontSize: 17, fontWeight: alert.isRead ? FontWeight.w500 : FontWeight.bold, color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(alert.message, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4)),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                            child: Text(alert.childName, style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 14),
                          const Icon(Icons.access_time_rounded, size: 16, color: AppColors.textMuted),
                          const SizedBox(width: 6),
                          Text(_formatTime(alert.timestamp), style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                          const Spacer(),
                          if (alert.severity == 2)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                              child: const Row(
                                children: [
                                  Icon(Icons.priority_high_rounded, size: 14, color: AppColors.error),
                                  SizedBox(width: 4),
                                  Text('Critical', style: TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}