import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:child_safety_monitor/core/constants/app_colors.dart';
import 'package:child_safety_monitor/data/models/app_models.dart';
import 'package:child_safety_monitor/providers/app_state.dart';
import 'package:child_safety_monitor/widgets/charts/risk_gauge.dart';

class ChildProfileScreen extends ConsumerStatefulWidget {
  final String childId;

  const ChildProfileScreen({super.key, required this.childId});

  @override
  ConsumerState<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends ConsumerState<ChildProfileScreen> {
  // Demo blocked apps data
  final List<Map<String, dynamic>> _blockedApps = [
    {'name': 'Moj', 'icon': Icons.video_library_rounded, 'blocked': true},
    {'name': 'Instagram', 'icon': Icons.camera_alt_rounded, 'blocked': true},
    {'name': 'YouTube', 'icon': Icons.play_circle_rounded, 'blocked': false},
    {'name': 'Snapchat', 'icon': Icons.chat_bubble_rounded, 'blocked': true},
    {'name': 'Twitter/X', 'icon': Icons.alternate_email_rounded, 'blocked': false},
    {'name': 'Discord', 'icon': Icons.headset_mic_rounded, 'blocked': false},
  ];

  // Demo screen time data
  final List<Map<String, dynamic>> _screenTimeData = [
    {'category': 'Education', 'hours': 2.5, 'color': AppColors.success},
    {'category': 'Social Media', 'hours': 1.8, 'color': AppColors.warning},
    {'category': 'Gaming', 'hours': 1.2, 'color': AppColors.secondary},
    {'category': 'Entertainment', 'hours': 0.8, 'color': AppColors.primary},
    {'category': 'Other', 'hours': 0.5, 'color': Colors.grey},
  ];

  @override
  Widget build(BuildContext context) {
    final children = ref.watch(childrenProvider);
    final child = children.firstWhere(
      (c) => c.id == widget.childId,
      orElse: () => ChildModel(id: '', name: 'Unknown'),
    );
    final alerts = ref.watch(alertsProvider).where((a) => a.childId == widget.childId).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Back button sidebar
          Container(
            width: 60,
            color: AppColors.surface,
            child: Column(
              children: [
                const SizedBox(height: 24),
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Back',
                ),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(child),
                  const SizedBox(height: 32),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildLeftColumn(child, alerts)),
                      const SizedBox(width: 32),
                      Expanded(child: _buildRightColumn(child)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ChildModel child) {
    final riskColor = AppColors.getRiskColor(child.riskLevel);
    final initials = child.name.isNotEmpty ? child.name[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [riskColor.withValues(alpha: 0.8), riskColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: riskColor.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(initials, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(width: 28),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(child.name, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1)),
                const SizedBox(height: 8),
                Text(child.deviceName, style: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.8))),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildHeaderChip(Icons.access_time_rounded, _formatTime(child.lastActive)),
                    const SizedBox(width: 16),
                    _buildHeaderChip(Icons.phone_android_rounded, 'Online'),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text('${child.riskLevel}%', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: riskColor)),
                    Text('Risk Score', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(child.riskLevel <= 40 ? '✓ Safe' : '⚠ Attention', style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildLeftColumn(ChildModel child, List<AlertModel> alerts) {
    return Column(
      children: [
        _buildScreenTimeCard(),
        const SizedBox(height: 24),
        _buildRecentAlertsCard(alerts),
        const SizedBox(height: 24),
        _buildActivityTimelineCard(),
      ],
    );
  }

  Widget _buildScreenTimeCard() {
    // Single-pass O(N) loop to calculate total hours, pie chart sections, and legend widgets concurrently
    double totalHours = 0;
    final sections = <PieChartSectionData>[];
    final legendWidgets = <Widget>[];

    for (int i = 0; i < _screenTimeData.length; i++) {
      final d = _screenTimeData[i];
      final hours = d['hours'] as double;
      final color = d['color'] as Color;
      final category = d['category'] as String;

      totalHours += hours;

      sections.add(
        PieChartSectionData(
          value: hours,
          color: color,
          radius: 35,
          showTitle: false,
        ),
      );

      legendWidgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(category, style: const TextStyle(color: AppColors.textPrimary))),
              Text('${hours}h', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Screen Time Today', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                child: Text('${totalHours.toStringAsFixed(1)}h total', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 40,
                    sections: sections,
                  ),
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  children: legendWidgets,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAlertsCard(List<AlertModel> alerts) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Alerts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text('${alerts.length} total', style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 20),
          if (alerts.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              child: const Center(child: Text('No alerts for this child', style: TextStyle(color: AppColors.textSecondary))),
            )
          else
            ...alerts.take(3).map((alert) => _buildAlertItem(alert)),
        ],
      ),
    );
  }

  Widget _buildAlertItem(AlertModel alert) {
    final color = alert.severity == 2 ? AppColors.error : AppColors.warning;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(alert.severity == 2 ? Icons.warning_rounded : Icons.info_rounded, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.title, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
                const SizedBox(height: 2),
                Text(_formatTime(alert.timestamp), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTimelineCard() {
    final activities = [
      {'time': '2:30 PM', 'action': 'Started YouTube', 'icon': Icons.play_circle_rounded, 'color': AppColors.primary},
      {'time': '1:45 PM', 'action': 'Completed Math Homework', 'icon': Icons.school_rounded, 'color': AppColors.success},
      {'time': '12:30 PM', 'action': 'Opened Instagram (Blocked)', 'icon': Icons.block_rounded, 'color': AppColors.error},
      {'time': '11:00 AM', 'action': 'Login from iPhone', 'icon': Icons.phone_iphone_rounded, 'color': AppColors.secondary},
    ];

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Activity Timeline', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 20),
          ...activities.asMap().entries.map((entry) {
            final i = entry.key;
            final a = entry.value;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: (a['color'] as Color).withValues(alpha: 0.12), shape: BoxShape.circle),
                      child: Icon(a['icon'] as IconData, color: a['color'] as Color, size: 20),
                    ),
                    if (i < activities.length - 1) Container(width: 2, height: 40, color: Colors.grey.shade200),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a['action'] as String, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text(a['time'] as String, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRightColumn(ChildModel child) {
    return Column(
      children: [
        _buildRiskGaugeCard(child),
        const SizedBox(height: 24),
        _buildBlockedAppsCard(),
        const SizedBox(height: 24),
        _buildQuickActionsCard(),
      ],
    );
  }

  Widget _buildRiskGaugeCard(ChildModel child) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          const Text('Risk Analysis', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 24),
          RiskGauge(score: child.riskLevel, size: 160),
          const SizedBox(height: 20),
          _buildRiskFactorRow('Content Access', 85, AppColors.success),
          const SizedBox(height: 12),
          _buildRiskFactorRow('Screen Time', 60, AppColors.warning),
          const SizedBox(height: 12),
          _buildRiskFactorRow('Social Activity', 45, AppColors.orange),
        ],
      ),
    );
  }

  Widget _buildRiskFactorRow(String label, int score, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            Text('$score%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: score / 100, backgroundColor: Colors.grey.shade200, color: color, minHeight: 6),
        ),
      ],
    );
  }

  Widget _buildBlockedAppsCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Blocked Apps', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          ..._blockedApps.asMap().entries.map((entry) {
            final i = entry.key;
            final app = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                    child: Icon(app['icon'] as IconData, color: AppColors.textSecondary, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Text(app['name'] as String, style: const TextStyle(fontWeight: FontWeight.w500))),
                  Switch.adaptive(
                    value: app['blocked'] as bool,
                    onChanged: (v) => setState(() => _blockedApps[i]['blocked'] = v),
                    activeTrackColor: AppColors.error,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 20),
          _buildActionButton(Icons.pause_circle_rounded, 'Pause Internet', AppColors.warning, () {}),
          const SizedBox(height: 12),
          _buildActionButton(Icons.location_on_rounded, 'View Location', AppColors.primary, () {}),
          const SizedBox(height: 12),
          _buildActionButton(Icons.phone_rounded, 'Call Device', AppColors.success, () {}),
          const SizedBox(height: 12),
          _buildActionButton(Icons.lock_rounded, 'Lock Device', AppColors.error, () {}),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 14),
              Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
