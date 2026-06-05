import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:child_safety_monitor/data/models/weekly_report.dart';
import 'package:child_safety_monitor/data/models/activity_log.dart';

/// Service for generating weekly reports via the backend API
class WeeklyReportService {
  // Backend server URL - same as gemini_insight_service.dart
  // Change this IP if your network changes
  static const String _backendBaseUrl = 'http://localhost:8000';

  /// Generate a weekly report for a child
  /// 
  /// Takes the child's info and activity logs for the past week,
  /// sends them to the backend for AI analysis, and returns a
  /// comprehensive weekly report.
  Future<WeeklyReport> generateWeeklyReport({
    required String childId,
    required String childName,
    required int childAge,
    required List<ActivityLog> logs,
    required DateTime weekStart,
    required DateTime weekEnd,
  }) async {
    // Prepare logs in the format expected by the backend
    final logsJson = logs.map((log) => {
      'app_name': log.appName,
      'category': log.category.name,
      'duration_minutes': log.screenTime,
      'timestamp': log.timestamp.toIso8601String(),
    }).toList();

    // Build request body
    final requestBody = {
      'child': {
        'child_id': childId,
        'child_name': childName,
        'age': childAge,
      },
      'logs': logsJson,
      'week_start': weekStart.toIso8601String().split('T')[0],
      'week_end': weekEnd.toIso8601String().split('T')[0],
    };

    // Make API call
    final response = await http.post(
      Uri.parse('$_backendBaseUrl/reports/weekly'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    ).timeout(const Duration(seconds: 60)); // Longer timeout for AI processing

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return WeeklyReport.fromJson(data);
    } else {
      throw Exception('Failed to generate report: ${response.statusCode} - ${response.body}');
    }
  }

  /// Check if the backend is available
  Future<bool> isBackendAvailable() async {
    try {
      final response = await http.get(
        Uri.parse('$_backendBaseUrl/health'),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

/// Global singleton instance
final weeklyReportService = WeeklyReportService();
