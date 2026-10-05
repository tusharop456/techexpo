import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:child_safety_monitor/data/models/weekly_report.dart';
import 'package:child_safety_monitor/data/models/activity_log.dart';
import 'package:child_safety_monitor/services/weekly_report_service.dart';
import 'package:child_safety_monitor/providers/database_provider.dart';

/// Weekly Report Screen - Displays AI-generated weekly analysis
class WeeklyReportScreen extends ConsumerStatefulWidget {
  final String childId;
  final String childName;
  final int childAge;

  const WeeklyReportScreen({
    super.key,
    required this.childId,
    required this.childName,
    this.childAge = 10,
  });

  @override
  ConsumerState<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends ConsumerState<WeeklyReportScreen> {
  WeeklyReport? _report;
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A1628),
              Color(0xFF1A2E4A),
              Color(0xFF0D2137),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _error != null
                        ? _buildErrorState()
                        : _report != null
                            ? _buildReportContent()
                            : _buildInitialState(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weekly Report',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.childName,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha:0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00D9FF).withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF00D9FF).withValues(alpha:0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, color: Color(0xFF00D9FF), size: 16),
                SizedBox(width: 4),
                Text(
                  'AI Powered',
                  style: TextStyle(color: Color(0xFF00D9FF), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.analytics_outlined,
                size: 64,
                color: Color(0xFF00D9FF),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Generate Weekly Report',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Get AI-powered insights about ${widget.childName}\'s digital activity for the past week.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha:0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            _buildGenerateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return GestureDetector(
      onTap: _generateReport,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00D9FF), Color(0xFF00A8CC)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00D9FF).withValues(alpha:0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Generate Report',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: Color(0xFF00D9FF),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Analyzing Activity Data...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI is generating your weekly report',
            style: TextStyle(
              color: Colors.white.withValues(alpha:0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Failed to Generate Report',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha:0.7)),
            ),
            const SizedBox(height: 24),
            _buildGenerateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildReportContent() {
    final report = _report!;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSafetyScoreCard(report),
          const SizedBox(height: 16),
          _buildStatsRow(report),
          const SizedBox(height: 16),
          _buildSummaryCard(report),
          const SizedBox(height: 16),
          _buildObservationsCard(report),
          const SizedBox(height: 16),
          if (report.concerns.isNotEmpty) ...[
            _buildConcernsCard(report),
            const SizedBox(height: 16),
          ],
          _buildHighlightsCard(report),
          const SizedBox(height: 16),
          _buildRecommendationsCard(report),
          const SizedBox(height: 16),
          _buildTopAppsCard(report),
          const SizedBox(height: 16),
          _buildCategoryBreakdownCard(report),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSafetyScoreCard(WeeklyReport report) {
    Color scoreColor;
    if (report.safetyScore >= 80) {
      scoreColor = Colors.greenAccent;
    } else if (report.safetyScore >= 60) {
      scoreColor = Colors.amber;
    } else {
      scoreColor = Colors.redAccent;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scoreColor.withValues(alpha:0.2),
            scoreColor.withValues(alpha:0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scoreColor.withValues(alpha:0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scoreColor.withValues(alpha:0.2),
              border: Border.all(color: scoreColor, width: 3),
            ),
            child: Center(
              child: Text(
                '${report.safetyScore}',
                style: TextStyle(
                  color: scoreColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Safety Score',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha:0.7),
                    fontSize: 14,
                  ),
                ),
                Text(
                  report.safetyScoreGrade,
                  style: TextStyle(
                    color: scoreColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${report.weekStart} - ${report.weekEnd}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha:0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(WeeklyReport report) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.access_time,
            label: 'Total Time',
            value: report.formattedTotalTime,
            color: const Color(0xFF00D9FF),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.trending_up,
            label: 'Daily Avg',
            value: report.formattedDailyAverage,
            color: const Color(0xFFFF6B9D),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha:0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha:0.6),
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(WeeklyReport report) {
    return _buildGlassCard(
      title: '📋 Executive Summary',
      child: Text(
        report.executiveSummary,
        style: TextStyle(
          color: Colors.white.withValues(alpha:0.9),
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildObservationsCard(WeeklyReport report) {
    return _buildGlassCard(
      title: '🔍 Key Observations',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: report.keyObservations
            .map((obs) => _buildBulletPoint(obs, const Color(0xFF00D9FF)))
            .toList(),
      ),
    );
  }

  Widget _buildConcernsCard(WeeklyReport report) {
    return _buildGlassCard(
      title: '⚠️ Areas of Concern',
      borderColor: Colors.amber.withValues(alpha:0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: report.concerns
            .map((concern) => _buildBulletPoint(concern, Colors.amber))
            .toList(),
      ),
    );
  }

  Widget _buildHighlightsCard(WeeklyReport report) {
    return _buildGlassCard(
      title: '✨ Positive Highlights',
      borderColor: Colors.greenAccent.withValues(alpha:0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: report.positiveHighlights
            .map((highlight) => _buildBulletPoint(highlight, Colors.greenAccent))
            .toList(),
      ),
    );
  }

  Widget _buildRecommendationsCard(WeeklyReport report) {
    return _buildGlassCard(
      title: '💡 Recommendations',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: report.recommendations
            .asMap()
            .entries
            .map((entry) => _buildNumberedPoint(entry.key + 1, entry.value))
            .toList(),
      ),
    );
  }

  Widget _buildTopAppsCard(WeeklyReport report) {
    return _buildGlassCard(
      title: '📱 Top Apps',
      child: Column(
        children: report.topApps.map((app) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D9FF).withValues(alpha:0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(app.category),
                    color: const Color(0xFF00D9FF),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.appName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        app.category,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha:0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${app.totalMinutes}m',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${app.percentage}%',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha:0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryBreakdownCard(WeeklyReport report) {
    return _buildGlassCard(
      title: '📊 Category Breakdown',
      child: Column(
        children: report.categoryStats.map((cat) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      cat.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      '${cat.totalMinutes}m (${cat.percentage}%)',
                      style: TextStyle(color: Colors.white.withValues(alpha:0.7)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: cat.percentage / 100,
                    backgroundColor: Colors.white.withValues(alpha:0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getCategoryColor(cat.name),
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGlassCard({
    required String title,
    required Widget child,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor ?? Colors.white.withValues(alpha:0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withValues(alpha:0.8),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberedPoint(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: const Color(0xFF00D9FF).withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Color(0xFF00D9FF),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withValues(alpha:0.8),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'gaming':
      case 'games':
        return Icons.sports_esports;
      case 'education':
      case 'educational':
        return Icons.school;
      case 'social':
      case 'social media':
        return Icons.people;
      case 'entertainment':
        return Icons.movie;
      case 'productivity':
        return Icons.work;
      default:
        return Icons.apps;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'gaming':
      case 'games':
        return Colors.purpleAccent;
      case 'education':
      case 'educational':
        return Colors.greenAccent;
      case 'social':
      case 'social media':
        return Colors.pinkAccent;
      case 'entertainment':
        return Colors.orangeAccent;
      case 'productivity':
        return Colors.blueAccent;
      default:
        return const Color(0xFF00D9FF);
    }
  }

  Future<void> _generateReport() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final now = DateTime.now();
      final weekEnd = now;
      final weekStart = now.subtract(const Duration(days: 7));

      // Fetch activity logs from database
      final db = ref.read(databaseProvider);
      final dbLogs = await db.getLast7DaysLogs(widget.childId);
      
      if (dbLogs.isEmpty) {
        setState(() {
          _error = 'No activity data found for the past week. Please ensure there are activity logs in the database.';
          _isLoading = false;
        });
        return;
      }

      // Convert database entries to ActivityLog model using fixed-length List.generate for performance
      final logs = List<ActivityLog>.generate(
        dbLogs.length,
        (index) {
          final entry = dbLogs[index];
          return ActivityLog(
            id: entry.id,
            childId: entry.childId,
            screenTime: entry.screenTime,
            timestamp: entry.timestamp,
            category: _stringToCategory(entry.category),
            appName: entry.appName,
          );
        },
        growable: false,
      );

      final report = await weeklyReportService.generateWeeklyReport(
        childId: widget.childId,
        childName: widget.childName,
        childAge: widget.childAge,
        logs: logs,
        weekStart: weekStart,
        weekEnd: weekEnd,
      );

      setState(() {
        _report = report;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  /// Convert string category from database to ActivityCategory enum
  ActivityCategory _stringToCategory(String category) {
    switch (category.toLowerCase()) {
      case 'gaming':
        return ActivityCategory.gaming;
      case 'social':
        return ActivityCategory.social;
      case 'education':
        return ActivityCategory.education;
      case 'entertainment':
        return ActivityCategory.entertainment;
      case 'productivity':
        return ActivityCategory.productivity;
      default:
        return ActivityCategory.other;
    }
  }
}

