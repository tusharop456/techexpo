import 'dart:convert';
import 'package:http/http.dart' as http;

/// Model for risk category
class RiskCategory {
  final String name;
  final String severity;
  final String description;

  RiskCategory({
    required this.name,
    required this.severity,
    required this.description,
  });

  factory RiskCategory.fromJson(Map<String, dynamic> json) {
    return RiskCategory(
      name: json['name'] as String,
      severity: json['severity'] as String,
      description: json['description'] as String,
    );
  }
}

/// Model for content scan result
class ContentScanResult {
  final int safetyScore;
  final String riskLevel;
  final String contentType;
  final List<RiskCategory> riskCategories;
  final String aiExplanation;
  final List<String> recommendations;
  final bool isAgeAppropriate;
  final String scannedContent;

  ContentScanResult({
    required this.safetyScore,
    required this.riskLevel,
    required this.contentType,
    required this.riskCategories,
    required this.aiExplanation,
    required this.recommendations,
    required this.isAgeAppropriate,
    required this.scannedContent,
  });

  factory ContentScanResult.fromJson(Map<String, dynamic> json) {
    return ContentScanResult(
      safetyScore: json['safety_score'] as int,
      riskLevel: json['risk_level'] as String,
      contentType: json['content_type'] as String,
      riskCategories: (json['risk_categories'] as List)
          .map((e) => RiskCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      aiExplanation: json['ai_explanation'] as String,
      recommendations: List<String>.from(json['recommendations'] as List),
      isAgeAppropriate: json['is_age_appropriate'] as bool,
      scannedContent: json['scanned_content'] as String,
    );
  }

  /// Get color based on safety score
  bool get isSafe => safetyScore >= 80;
  bool get isCaution => safetyScore >= 60 && safetyScore < 80;
  bool get isWarning => safetyScore >= 40 && safetyScore < 60;
  bool get isDanger => safetyScore < 40;
}

/// Service for content safety scanning
class ContentScannerService {
  // Configure your backend URL here
  static const String _backendUrl = 'http://localhost:8000';

  /// Scan content for child safety
  Future<ContentScanResult> scanContent({
    required String content,
    String contentType = 'auto',
    int childAge = 10,
  }) async {
    final response = await http.post(
      Uri.parse('$_backendUrl/content/scan'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'content': content,
        'content_type': contentType,
        'child_age': childAge,
      }),
    );

    if (response.statusCode == 200) {
      return ContentScanResult.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to scan content: ${response.body}');
    }
  }
}

/// Global instance
final contentScannerService = ContentScannerService();
