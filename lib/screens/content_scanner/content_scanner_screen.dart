import 'package:flutter/material.dart';
import 'package:child_safety_monitor/core/constants/app_colors.dart';
import 'package:child_safety_monitor/services/content_scanner_service.dart';
import 'dart:math' as math;

/// AI-Powered Content Scanner Screen
class ContentScannerScreen extends StatefulWidget {
  const ContentScannerScreen({super.key});

  @override
  State<ContentScannerScreen> createState() => _ContentScannerScreenState();
}

class _ContentScannerScreenState extends State<ContentScannerScreen> {
  final TextEditingController _contentController = TextEditingController();
  ContentScanResult? _result;
  bool _isLoading = false;
  String? _error;

  Future<void> _scanContent() async {
    if (_contentController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter a URL or text to scan');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
    });

    try {
      final result = await contentScannerService.scanContent(
        content: _contentController.text.trim(),
      );
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildInputSection(),
            const SizedBox(height: 32),
            if (_isLoading) _buildLoadingState(),
            if (_error != null) _buildErrorState(),
            if (_result != null) _buildResultSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667EEA).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.security_rounded, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 20),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Content Scanner',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: -1,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Analyze URLs and text for child safety',
              style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputSection() {
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
          const Text(
            'Enter URL or Text to Scan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentController,
            maxLines: 3,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Enter a URL (e.g., youtube.com) or paste text content...',
              hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6)),
              filled: true,
              fillColor: AppColors.glass.withValues(alpha: 0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.glassBorder.withValues(alpha: 0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2),
              ),
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _scanContent,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: const Color(0xFF667EEA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.radar_rounded, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    _isLoading ? 'Analyzing...' : 'Scan Content',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppColors.glass.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.15)),
      ),
      child: const Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: Color(0xFF667EEA)),
            SizedBox(height: 20),
            Text(
              'AI is analyzing content...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(color: AppColors.error, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection() {
    final result = _result!;
    return Column(
      children: [
        // Safety Score Card
        _buildSafetyScoreCard(result),
        const SizedBox(height: 24),
        // Risk Categories
        if (result.riskCategories.isNotEmpty) ...[
          _buildRiskCategoriesCard(result),
          const SizedBox(height: 24),
        ],
        // AI Explanation
        _buildExplanationCard(result),
        const SizedBox(height: 24),
        // Recommendations
        if (result.recommendations.isNotEmpty) _buildRecommendationsCard(result),
      ],
    );
  }

  Widget _buildSafetyScoreCard(ContentScanResult result) {
    final color = _getScoreColor(result.safetyScore);
    final label = _getScoreLabel(result.safetyScore);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
      ),
      child: Row(
        children: [
          // Score Gauge
          SizedBox(
            width: 140,
            height: 140,
            child: CustomPaint(
              painter: ScoreGaugePainter(
                score: result.safetyScore,
                color: color,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${result.safetyScore}',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      'out of 100',
                      style: TextStyle(
                        fontSize: 12,
                        color: color.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getScoreIcon(result.safetyScore), color: color, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  result.isAgeAppropriate
                      ? '✅ Age-appropriate content'
                      : '⚠️ May not be age-appropriate',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Content type: ${result.contentType.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskCategoriesCard(ContentScanResult result) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.glass.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 24),
              SizedBox(width: 12),
              Text(
                'Risk Categories Detected',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: result.riskCategories.map((cat) {
              final color = _getSeverityColor(cat.severity);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          cat.name,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    if (cat.description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        cat.description,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationCard(ContentScanResult result) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.glass.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.psychology_rounded, color: Color(0xFF667EEA), size: 24),
              SizedBox(width: 12),
              Text(
                'AI Analysis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            result.aiExplanation,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard(ContentScanResult result) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tips_and_updates_rounded, color: Color(0xFF10B981), size: 24),
              SizedBox(width: 12),
              Text(
                'Recommendations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...result.recommendations.map((rec) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: Color(0xFF10B981), fontSize: 16)),
                Expanded(
                  child: Text(
                    rec,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return const Color(0xFF10B981); // Green
    if (score >= 60) return const Color(0xFFF59E0B); // Yellow
    if (score >= 40) return const Color(0xFFF97316); // Orange
    return const Color(0xFFEF4444); // Red
  }

  String _getScoreLabel(int score) {
    if (score >= 80) return 'SAFE';
    if (score >= 60) return 'CAUTION';
    if (score >= 40) return 'WARNING';
    return 'DANGER';
  }

  IconData _getScoreIcon(int score) {
    if (score >= 80) return Icons.check_circle_rounded;
    if (score >= 60) return Icons.info_rounded;
    if (score >= 40) return Icons.warning_rounded;
    return Icons.dangerous_rounded;
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return const Color(0xFFEF4444);
      case 'medium':
        return const Color(0xFFF97316);
      default:
        return const Color(0xFFF59E0B);
    }
  }
}

/// Custom painter for the score gauge
class ScoreGaugePainter extends CustomPainter {
  final int score;
  final Color color;

  ScoreGaugePainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    // Cache bounding rect to prevent duplicate Rect allocations on every paint
    final arcRect = Rect.fromCircle(center: center, radius: radius);

    // Background arc
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      arcRect,
      -math.pi * 0.75,
      math.pi * 1.5,
      false,
      bgPaint,
    );

    // Score arc
    final scorePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (score / 100) * math.pi * 1.5;
    canvas.drawArc(
      arcRect,
      -math.pi * 0.75,
      sweepAngle,
      false,
      scorePaint,
    );
  }

  @override
  // Only repaint when properties change to avoid unnecessary canvas re-draws on parent rebuilds
  bool shouldRepaint(covariant ScoreGaugePainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.color != color;
  }
}
