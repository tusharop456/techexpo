import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:child_safety_monitor/data/models/activity_log.dart';
import 'package:flutter/foundation.dart';
import 'insights_engine.dart';

/// Service for generating AI-powered insights using backend API
class GeminiInsightService {
  // Backend server URL - set to your laptop's IP address
  // Change this IP if your network changes
  static const String _backendBaseUrl = 'http://localhost:8000';
  
  bool _isInitialized = false;
  bool _backendAvailable = false;
  
  /// Initialize the service by checking backend connectivity
  Future<void> initialize() async {
    try {
      // Check if backend is reachable
      final response = await http.get(
        Uri.parse('$_backendBaseUrl/health'),
      ).timeout(const Duration(seconds: 5));
      
      _backendAvailable = response.statusCode == 200;
      _isInitialized = true;
      
      if (_backendAvailable) {
        debugPrint('✅ Connected to backend at $_backendBaseUrl');
      } else {
        debugPrint('⚠️ Backend returned status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('⚠️ Could not connect to backend: $e');
      debugPrint('   Falling back to local insights engine.');
      _backendAvailable = false;
      _isInitialized = true;
    }
  }
  
  /// Check if the service is properly configured
  bool get isConfigured => _isInitialized && _backendAvailable;
  
  /// Generate AI-enhanced insights using Gemini API
  /// Falls back to local insights engine if API call fails
  Future<List<Insight>> generateInsights({
    required String childId,
    required String childName,
    required List<ActivityLog> historicalData,
    required List<ActivityLog> todayData,
  }) async {
    // First, get local insights as a baseline
    final localInsights = InsightsEngine.generateDailyInsights(
      childId: childId,
      childName: childName,
      historicalData: historicalData,
      todayData: todayData,
    );
    
    // If API is not configured, return local insights
    if (!isConfigured) {
      return localInsights;
    }
    
    try {
      // Call backend API for AI insights
      final backendInsights = await _callBackendApi(childId, childName, todayData);
      
      // Combine local and backend insights
      return [...localInsights, ...backendInsights];
    } catch (e) {
      // Log error and fallback to local insights
      debugPrint('Backend API error: $e');
      return localInsights;
    }
  }
  

  
  /// Call the backend API to generate insights
  Future<List<Insight>> _callBackendApi(String childId, String childName, List<ActivityLog> todayData) async {
    // Prepare logs in the format expected by the backend
    final logs = todayData.map((log) => {
      'app_name': log.appName,
      'category': log.category.name,
      'duration_minutes': log.screenTime,
      'timestamp': log.timestamp.toIso8601String(),
    }).toList();

    final response = await http.post(
      Uri.parse('$_backendBaseUrl/insights/generate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'logs': logs}),
    ).timeout(const Duration(seconds: 30));
    
    if (response.statusCode != 200) {
      throw Exception('Backend API error: ${response.statusCode} - ${response.body}');
    }
    
    final data = jsonDecode(response.body);
    final summary = data['summary'] as String;
    
    // Return as a single insight with the full summary
    return [
      Insight(
        id: 'backend_${childId}_${DateTime.now().millisecondsSinceEpoch}',
        childId: childId,
        childName: childName,
        type: InsightType.neutral,
        title: '🤖 AI Analysis',
        message: summary,
        recommendation: null,
        timestamp: DateTime.now(),
      ),
    ];
  }
}

/// Global singleton instance
final geminiService = GeminiInsightService();
