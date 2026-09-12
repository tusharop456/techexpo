import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:child_safety_monitor/core/constants/app_colors.dart';
import 'package:child_safety_monitor/providers/app_state.dart';

class ScreenTimeScreen extends ConsumerWidget {
  final String? childId;
  const ScreenTimeScreen({super.key, this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final children = ref.watch(childrenProvider);
    final selectedChild = childId != null
        ? children.firstWhere((c) => c.id == childId, orElse: () => children.first)
        : (children.isNotEmpty ? children.first : null);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, selectedChild?.name ?? 'All Children'),
            const SizedBox(height: 28),
            _buildTodaySummary(),
            const SizedBox(height: 28),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildDailyPieChart()),
                const SizedBox(width: 24),
                Expanded(child: _buildWeeklyBarChart()),
              ],
            ),
            const SizedBox(height: 28),
            _buildTopApps(),
            const SizedBox(height: 28),
            _buildUsageLimits(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.schedule_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Screen Time', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                const SizedBox(height: 4),
                Text('Usage analytics for $title', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 16)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(30)),
            child: const Row(
              children: [
                Icon(Icons.today_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Today', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySummary() {
    final stats = [
      {'label': 'Total Today', 'value': '4h 32m', 'icon': Icons.timer_rounded, 'color': const Color(0xFF6366F1), 'change': '+12%'},
      {'label': 'Most Used', 'value': 'YouTube', 'icon': Icons.play_circle_rounded, 'color': const Color(0xFFEF4444), 'change': '1h 45m'},
      {'label': 'Pickups', 'value': '47', 'icon': Icons.phone_android_rounded, 'color': const Color(0xFFF59E0B), 'change': '-8%'},
      {'label': 'Avg Session', 'value': '12m', 'icon': Icons.hourglass_bottom_rounded, 'color': const Color(0xFF10B981), 'change': 'Normal'},
    ];

    return Row(
      children: stats.map((stat) => Expanded(
        child: Container(
          margin: EdgeInsets.only(right: stat != stats.last ? 16 : 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: (stat['color'] as Color).withValues(alpha: 0.2)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: (stat['color'] as Color).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                    child: Icon(stat['icon'] as IconData, color: stat['color'] as Color, size: 22),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text(stat['change'] as String, style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(stat['value'] as String, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: -0.5)),
              const SizedBox(height: 4),
              Text(stat['label'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildDailyPieChart() {
    final categories = [
      {'name': 'Social Media', 'time': '1h 45m', 'percent': 38.0, 'color': const Color(0xFFEF4444)},
      {'name': 'Games', 'time': '1h 10m', 'percent': 26.0, 'color': const Color(0xFF8B5CF6)},
      {'name': 'Education', 'time': '50m', 'percent': 18.0, 'color': const Color(0xFF10B981)},
      {'name': 'Entertainment', 'time': '35m', 'percent': 13.0, 'color': const Color(0xFFF59E0B)},
      {'name': 'Other', 'time': '12m', 'percent': 5.0, 'color': const Color(0xFF6B7280)},
    ];

    // Single-pass construction for pie chart sections and legend items to avoid multiple linear traversals.
    final sections = <PieChartSectionData>[];
    final legendItems = <Widget>[];

    for (final c in categories) {
      final percent = c['percent'] as double;
      final color = c['color'] as Color;
      final name = c['name'] as String;
      final time = c['time'] as String;

      sections.add(
        PieChartSectionData(
          value: percent,
          color: color,
          radius: 45,
          title: '${percent.toInt()}%',
          titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      );

      legendItems.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 10),
              SizedBox(width: 90, child: Text(name, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
              Text(time, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
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
              const Text('Usage by Category', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Icon(Icons.pie_chart_rounded, color: Colors.grey.shade400),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 50,
                      sections: sections,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: legendItems,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyBarChart() {
    final weekData = [
      {'day': 'Mon', 'hours': 3.5},
      {'day': 'Tue', 'hours': 4.2},
      {'day': 'Wed', 'hours': 5.1},
      {'day': 'Thu', 'hours': 3.8},
      {'day': 'Fri', 'hours': 6.2},
      {'day': 'Sat', 'hours': 7.5},
      {'day': 'Sun', 'hours': 4.5},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
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
              const Text('Weekly Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                child: const Text('Avg: 5h/day', style: TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 8,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(days[value.toInt()], style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Text('${value.toInt()}h', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                      reservedSize: 30,
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 2, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1)),
                borderData: FlBorderData(show: false),
                barGroups: weekData.asMap().entries.map((entry) {
                  final isWeekend = entry.key >= 5;
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value['hours'] as double,
                        width: 28,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        gradient: LinearGradient(
                          colors: isWeekend
                              ? [const Color(0xFFF59E0B), const Color(0xFFEF4444)]
                              : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopApps() {
    final apps = [
      {'name': 'YouTube', 'time': '1h 45m', 'icon': Icons.play_circle_filled_rounded, 'color': const Color(0xFFEF4444), 'limit': '2h', 'usage': 0.87},
      {'name': 'Moj', 'time': '52m', 'icon': Icons.music_note_rounded, 'color': const Color(0xFFE91E63), 'limit': '1h', 'usage': 0.87},
      {'name': 'Minecraft', 'time': '45m', 'icon': Icons.games_rounded, 'color': const Color(0xFF10B981), 'limit': '1h', 'usage': 0.75},
      {'name': 'Instagram', 'time': '38m', 'icon': Icons.camera_alt_rounded, 'color': const Color(0xFFE1306C), 'limit': '45m', 'usage': 0.84},
      {'name': 'Khan Academy', 'time': '35m', 'icon': Icons.school_rounded, 'color': const Color(0xFF14BF96), 'limit': 'Unlimited', 'usage': 0.0},
      {'name': 'Discord', 'time': '22m', 'icon': Icons.forum_rounded, 'color': const Color(0xFF5865F2), 'limit': '30m', 'usage': 0.73},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
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
              const Text('Top Apps Today', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.tune_rounded, size: 18),
                label: const Text('Manage Limits'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...apps.map((app) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: (app['usage'] as double) > 0.8 ? AppColors.warning.withValues(alpha: 0.3) : Colors.transparent),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: (app['color'] as Color).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                  child: Icon(app['icon'] as IconData, color: app['color'] as Color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(app['name'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(app['time'] as String, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          const Text(' / ', style: TextStyle(color: AppColors.textSecondary)),
                          Text(app['limit'] as String, style: TextStyle(fontSize: 13, color: (app['usage'] as double) > 0.8 ? AppColors.warning : AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
                if ((app['usage'] as double) > 0)
                  SizedBox(
                    width: 120,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${((app['usage'] as double) * 100).toInt()}% used', style: TextStyle(fontSize: 12, color: (app['usage'] as double) > 0.8 ? AppColors.warning : AppColors.textSecondary)),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: app['usage'] as double,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation((app['usage'] as double) > 0.8 ? AppColors.warning : AppColors.success),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                    child: const Text('No Limit', style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildUsageLimits() {
    final limits = [
      {'category': 'Social Media', 'current': '2h 37m', 'limit': '3h', 'percent': 0.87, 'color': const Color(0xFFEF4444)},
      {'category': 'Games', 'current': '1h 10m', 'limit': '2h', 'percent': 0.58, 'color': const Color(0xFF8B5CF6)},
      {'category': 'Entertainment', 'current': '35m', 'limit': '1h 30m', 'percent': 0.39, 'color': const Color(0xFFF59E0B)},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF6366F1).withValues(alpha: 0.05), const Color(0xFF8B5CF6).withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFF6366F1).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.timer_off_rounded, color: Color(0xFF6366F1), size: 22),
                  ),
                  const SizedBox(width: 14),
                  const Text('Daily Limits', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: const Text('Edit Limits'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...limits.map((limit) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(width: 10, height: 10, decoration: BoxDecoration(color: limit['color'] as Color, borderRadius: BorderRadius.circular(3))),
                        const SizedBox(width: 10),
                        Text(limit['category'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      ],
                    ),
                    Text('${limit['current']} / ${limit['limit']}', style: TextStyle(fontSize: 14, color: (limit['percent'] as double) > 0.8 ? AppColors.warning : AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: limit['percent'] as double,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation((limit['percent'] as double) > 0.8 ? AppColors.warning : limit['color'] as Color),
                    minHeight: 10,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
