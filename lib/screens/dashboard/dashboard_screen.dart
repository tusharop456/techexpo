import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:child_safety_monitor/widgets/charts/risk_gauge.dart';
import 'package:child_safety_monitor/widgets/smart_insight_card.dart';
import 'package:child_safety_monitor/widgets/animated_widgets.dart';
import 'package:child_safety_monitor/services/insights_engine.dart';
import 'package:child_safety_monitor/providers/app_state.dart';
import 'package:child_safety_monitor/providers/insights_provider.dart';
import 'package:child_safety_monitor/core/constants/app_colors.dart';


class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avgRisk = ref.watch(averageRiskProvider);
    final children = ref.watch(childrenProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Staggered entry animations for premium feel
            FadeSlideIn(
              delay: const Duration(milliseconds: 0),
              child: _buildHeader(),
            ),
            const SizedBox(height: 28),
            FadeSlideIn(
              delay: const Duration(milliseconds: 100),
              child: _buildMainMetrics(avgRisk, children.length),
            ),
            const SizedBox(height: 28),
            FadeSlideIn(
              delay: const Duration(milliseconds: 200),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildActivityChart()),
                  const SizedBox(width: 24),
                  Expanded(child: _buildRiskBreakdown()),
                ],
              ),
            ),
            const SizedBox(height: 28),
            FadeSlideIn(
              delay: const Duration(milliseconds: 300),
              child: _WeeklyInsightsSection(childName: children.isNotEmpty ? children.first.name : 'your children'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Analytics Dashboard', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: -1)),
            const SizedBox(height: 4),
            Text('Monitor your family\'s online safety trends', style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
          ],
        ),
        Row(
          children: [
            // Animated Search Bar
            const AnimatedSearchBar(
              hintText: 'Search...',
              collapsedWidth: 56,
              expandedWidth: 280,
            ),
            const SizedBox(width: 16),
            // Date picker
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.glass.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 10),
                  const Text('Last 7 days', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                  const SizedBox(width: 8),
                  Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Demo Alert Button for Competition
            _DemoAlertButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildMainMetrics(int avgRisk, int childCount) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.glass.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.15)),
              boxShadow: [BoxShadow(color: AppColors.glow.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Column(
              children: [
                const Text('Family Risk Score', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 20),
                RiskGauge(score: avgRisk, size: 180),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: (avgRisk < 50 ? AppColors.success : AppColors.warning).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(avgRisk < 50 ? Icons.trending_down_rounded : Icons.trending_up_rounded, size: 18, color: avgRisk < 50 ? AppColors.success : AppColors.warning),
                      const SizedBox(width: 6),
                      Text(
                        avgRisk < 50 ? 'Looking good!' : 'Needs attention',
                        style: TextStyle(fontSize: 14, color: avgRisk < 50 ? AppColors.success : AppColors.warning, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildMetricCard('Screen Time', '4.2 hrs', 'avg/day', Icons.schedule_rounded, AppColors.primary, '+8%', false)),
                  const SizedBox(width: 20),
                  Expanded(child: _buildMetricCard('Blocked', '23', 'this week', Icons.block_rounded, AppColors.error, '-15%', true)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildMetricCard('Safe Searches', '156', 'this week', Icons.verified_user_rounded, AppColors.success, '+22%', true)),
                  const SizedBox(width: 20),
                  Expanded(child: _buildMetricCard('Active Apps', '12', 'monitored', Icons.apps_rounded, AppColors.secondary, '0%', true)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle, IconData icon, Color color, String change, bool isPositive) {
    return HoverScaleCard(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.glass.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: -1)),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (isPositive ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(change, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isPositive ? AppColors.success : AppColors.error)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityChart() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.glass.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weekly Activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 28),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 8,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(days[value.toInt()], style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      getTitlesWidget: (value, meta) => Text('${value.toInt()}h', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) => FlLine(color: AppColors.glass, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeBarGroup(0, 5.2),
                  _makeBarGroup(1, 6.1),
                  _makeBarGroup(2, 4.8),
                  _makeBarGroup(3, 3.5),
                  _makeBarGroup(4, 4.2),
                  _makeBarGroup(5, 7.0),
                  _makeBarGroup(6, 5.5),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)], begin: Alignment.bottomCenter, end: Alignment.topCenter),
          width: 28,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        ),
      ],
    );
  }

  Widget _buildRiskBreakdown() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.glass.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Risk Categories', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 28),
          _buildRiskCategory('Content Filtering', 85, AppColors.success),
          const SizedBox(height: 20),
          _buildRiskCategory('Screen Time', 60, AppColors.warning),
          const SizedBox(height: 20),
          _buildRiskCategory('Social Media', 45, AppColors.orange),
          const SizedBox(height: 20),
          _buildRiskCategory('Gaming', 75, AppColors.success),
        ],
      ),
    );
  }

  Widget _buildRiskCategory(String name, int score, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            Text('$score%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: score / 100,
            backgroundColor: AppColors.glass,
            color: color,
            minHeight: 10,
          ),
        ),
      ],
    );
  }

}

/// Isolated ConsumerWidget for AI insights to prevent whole DashboardScreen
/// re-renders when AI insights state updates or reloads.
class _WeeklyInsightsSection extends ConsumerWidget {
  final String childName;

  const _WeeklyInsightsSection({required this.childName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get insights from provider
    final insightsState = ref.watch(insightsProvider);
    final insights = insightsState.insights;
    final isLoading = insightsState.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Insights Engine', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: -0.5)),
                Text('Smart analysis of your family\'s digital habits', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              ],
            ),
            const Spacer(),
            // Refresh Button - Targets Liam (child_2) for demo
            IconButton(
              onPressed: isLoading ? null : () {
                ref.read(insightsProvider.notifier).refreshInsightsForChild('child_2');
              },
              icon: isLoading 
                ? const SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
              tooltip: 'Refresh insights for Liam (Demo)',
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  PulseWidget(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Live', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Display Smart Insight Cards with loading state and animations
        if (isLoading)
          Column(
            children: List.generate(3, (index) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ShimmerCard(height: 120),
              ),
            ),
          )
        else if (insights.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Center(
              child: Text(
                'Click refresh to generate AI insights for Liam\'s gaming activity',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ...insights.take(4).toList().asMap().entries.map((entry) => 
            FadeSlideIn(
              delay: Duration(milliseconds: 100 * entry.key),
              child: HoverScaleCard(
                scale: 1.015,
                borderRadius: BorderRadius.circular(20),
                child: SmartInsightCard(insight: entry.value),
              ),
            ),
          ),
      ],
    );
  }
}


// Demo button to trigger real-time alerts for competition
class _DemoAlertButton extends StatefulWidget {
  @override
  State<_DemoAlertButton> createState() => _DemoAlertButtonState();
}

class _DemoAlertButtonState extends State<_DemoAlertButton> {
  bool _isLoading = false;
  int _alertIndex = 0;

  final List<Map<String, dynamic>> _demoAlerts = [
    {
      'child_name': 'Ananya',
      'title': '🎮 Gaming Limit Exceeded',
      'message': 'Ananya has been playing Minecraft for over 3 hours today. Consider setting a break reminder.',
      'severity': 1,
      'category': 'time',
    },
    {
      'child_name': 'Arjun',
      'title': '🚨 Inappropriate Content Blocked',
      'message': 'A website with adult content was blocked on Arjun\'s device. The site has been added to the blocklist.',
      'severity': 2,
      'category': 'content',
    },
    {
      'child_name': 'Priya',
      'title': '📱 New App Installed',
      'message': 'Priya installed "TikTok" on their device. Review the app permissions in settings.',
      'severity': 1,
      'category': 'app',
    },
    {
      'child_name': 'Ananya',
      'title': '🌙 Late Night Usage Detected',
      'message': 'Ananya\'s device is active at 11:45 PM. Bedtime was set for 9:00 PM.',
      'severity': 2,
      'category': 'time',
    },
    {
      'child_name': 'Arjun',
      'title': '💬 New Social Media Message',
      'message': 'Arjun received a message from an unknown contact on Instagram. Review their contacts.',
      'severity': 1,
      'category': 'social',
    },
  ];

  Future<void> _triggerDemoAlert() async {
    setState(() => _isLoading = true);

    try {
      final alert = _demoAlerts[_alertIndex % _demoAlerts.length];
      _alertIndex++;

      final response = await http.post(
        Uri.parse('http://localhost:8000/alerts/trigger'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(alert),
      );

      if (response.statusCode != 200) {
        debugPrint('Failed to trigger alert: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error triggering alert: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading ? null : _triggerDemoAlert,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF4757), Color(0xFFFF6B81)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF4757).withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                const Icon(Icons.notifications_active_rounded, size: 18, color: Colors.white),
              const SizedBox(width: 10),
              const Text(
                'Demo Alert',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

