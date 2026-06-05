import 'package:flutter/material.dart';
import 'package:child_safety_monitor/core/constants/app_colors.dart';

/// Empty state widget shown when there's not enough data for AI insights
class NoInsightsWidget extends StatelessWidget {
  final int minDaysRequired;
  final VoidCallback? onLearnMore;

  const NoInsightsWidget({
    super.key,
    this.minDaysRequired = 3,
    this.onLearnMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF667EEA).withValues(alpha: 0.08),
            const Color(0xFF764BA2).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF667EEA).withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          // Animated brain icon with glow
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          
          // Title
          const Text(
            'AI Insights Coming Soon!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          
          // Description
          Text(
            'Keep SafeGuard active for at least $minDaysRequired days to unlock personalized insights about your children\'s digital habits.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          
          // Progress indicator
          _buildProgressIndicator(),
          const SizedBox(height: 24),
          
          // Features preview
          _buildFeaturesList(),
          
          if (onLearnMore != null) ...[
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: onLearnMore,
              icon: const Icon(Icons.info_outline_rounded, size: 18),
              label: const Text('Learn More'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF667EEA),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Day indicators
          for (int i = 1; i <= minDaysRequired; i++) ...[
            _buildDayIndicator(i, i <= 1), // First day "complete" for demo
            if (i < minDaysRequired)
              Container(
                width: 30,
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: i == 1 
                    ? const Color(0xFF667EEA) 
                    : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildDayIndicator(int day, bool isComplete) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isComplete 
              ? const Color(0xFF667EEA) 
              : Colors.grey.shade200,
            shape: BoxShape.circle,
            border: isComplete 
              ? null 
              : Border.all(color: Colors.grey.shade300, width: 2),
          ),
          child: Center(
            child: isComplete
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
              : Text(
                  '$day',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                  ),
                ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Day $day',
          style: TextStyle(
            fontSize: 11,
            color: isComplete ? const Color(0xFF667EEA) : Colors.grey.shade500,
            fontWeight: isComplete ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      {'icon': Icons.trending_up_rounded, 'text': 'Usage trend analysis'},
      {'icon': Icons.warning_amber_rounded, 'text': 'Anomaly detection'},
      {'icon': Icons.school_rounded, 'text': 'Education vs Gaming balance'},
      {'icon': Icons.lightbulb_outline_rounded, 'text': 'Personalized recommendations'},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: features.map((f) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF667EEA).withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(f['icon'] as IconData, size: 16, color: const Color(0xFF667EEA)),
            const SizedBox(width: 8),
            Text(
              f['text'] as String,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}
