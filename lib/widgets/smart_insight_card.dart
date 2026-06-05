import 'package:flutter/material.dart';
import 'package:child_safety_monitor/services/insights_engine.dart';
import 'package:child_safety_monitor/core/constants/app_colors.dart';

/// Smart Insight Card - Displays AI-generated insights with natural language
class SmartInsightCard extends StatelessWidget {
  final Insight insight;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;

  const SmartInsightCard({
    super.key,
    required this.insight,
    this.onDismiss,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getBackgroundColors(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getBorderColor(), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _getShadowColor(),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getIconBackgroundColor(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getIcon(), color: _getIconColor(), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          insight.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _getTitleColor(),
                          ),
                        ),
                        if (insight.percentageChange != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getPercentageBadgeColor(),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${insight.percentageChange! > 0 ? '+' : ''}${insight.percentageChange!.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _getPercentageTextColor(),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getTimeAgo(),
                      style: TextStyle(fontSize: 12, color: _getSubtitleColor()),
                    ),
                  ],
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: Icon(Icons.close_rounded, color: _getSubtitleColor(), size: 20),
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            insight.message,
            style: TextStyle(
              fontSize: 15,
              color: _getMessageColor(),
              height: 1.4,
            ),
          ),
          if (insight.recommendation != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getRecommendationBgColor(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.tips_and_updates_rounded, color: _getIconColor(), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      insight.recommendation!,
                      style: TextStyle(
                        fontSize: 13,
                        color: _getMessageColor(),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (onAction != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onAction,
                  icon: Icon(Icons.arrow_forward_rounded, size: 16, color: _getIconColor()),
                  label: Text('View Details', style: TextStyle(color: _getIconColor(), fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  List<Color> _getBackgroundColors() {
    switch (insight.type) {
      case InsightType.warning:
        return [const Color(0xFFFEF9C3), const Color(0xFFFEF3C7)]; // Soft yellow
      case InsightType.positive:
        return [const Color(0xFFD1FAE5), const Color(0xFFECFDF5)]; // Soft green
      case InsightType.anomaly:
        return [const Color(0xFFFEE2E2), const Color(0xFFFEF2F2)]; // Soft red
      case InsightType.neutral:
        return [const Color(0xFFDBEAFE), const Color(0xFFEFF6FF)]; // Soft blue
    }
  }

  Color _getBorderColor() {
    switch (insight.type) {
      case InsightType.warning:
        return const Color(0xFFFCD34D);
      case InsightType.positive:
        return const Color(0xFF6EE7B7);
      case InsightType.anomaly:
        return const Color(0xFFFCA5A5);
      case InsightType.neutral:
        return const Color(0xFF93C5FD);
    }
  }

  Color _getShadowColor() {
    switch (insight.type) {
      case InsightType.warning:
        return const Color(0xFFF59E0B).withValues(alpha: 0.15);
      case InsightType.positive:
        return const Color(0xFF10B981).withValues(alpha: 0.15);
      case InsightType.anomaly:
        return const Color(0xFFEF4444).withValues(alpha: 0.15);
      case InsightType.neutral:
        return const Color(0xFF3B82F6).withValues(alpha: 0.15);
    }
  }

  Color _getIconBackgroundColor() {
    switch (insight.type) {
      case InsightType.warning:
        return const Color(0xFFF59E0B).withValues(alpha: 0.2);
      case InsightType.positive:
        return const Color(0xFF10B981).withValues(alpha: 0.2);
      case InsightType.anomaly:
        return const Color(0xFFEF4444).withValues(alpha: 0.2);
      case InsightType.neutral:
        return const Color(0xFF3B82F6).withValues(alpha: 0.2);
    }
  }

  IconData _getIcon() {
    switch (insight.type) {
      case InsightType.warning:
        return Icons.lightbulb_rounded;
      case InsightType.positive:
        return Icons.emoji_events_rounded;
      case InsightType.anomaly:
        return Icons.trending_up_rounded;
      case InsightType.neutral:
        return Icons.info_rounded;
    }
  }

  Color _getIconColor() {
    switch (insight.type) {
      case InsightType.warning:
        return const Color(0xFFD97706);
      case InsightType.positive:
        return const Color(0xFF059669);
      case InsightType.anomaly:
        return const Color(0xFFDC2626);
      case InsightType.neutral:
        return const Color(0xFF2563EB);
    }
  }

  Color _getTitleColor() {
    switch (insight.type) {
      case InsightType.warning:
        return const Color(0xFF92400E);
      case InsightType.positive:
        return const Color(0xFF065F46);
      case InsightType.anomaly:
        return const Color(0xFF991B1B);
      case InsightType.neutral:
        return const Color(0xFF1E40AF);
    }
  }

  Color _getSubtitleColor() {
    switch (insight.type) {
      case InsightType.warning:
        return const Color(0xFFB45309);
      case InsightType.positive:
        return const Color(0xFF047857);
      case InsightType.anomaly:
        return const Color(0xFFB91C1C);
      case InsightType.neutral:
        return const Color(0xFF1D4ED8);
    }
  }

  Color _getMessageColor() {
    switch (insight.type) {
      case InsightType.warning:
        return const Color(0xFF78350F);
      case InsightType.positive:
        return const Color(0xFF064E3B);
      case InsightType.anomaly:
        return const Color(0xFF7F1D1D);
      case InsightType.neutral:
        return const Color(0xFF1E3A8A);
    }
  }

  Color _getRecommendationBgColor() {
    switch (insight.type) {
      case InsightType.warning:
        return Colors.white.withValues(alpha: 0.6);
      case InsightType.positive:
        return Colors.white.withValues(alpha: 0.6);
      case InsightType.anomaly:
        return Colors.white.withValues(alpha: 0.6);
      case InsightType.neutral:
        return Colors.white.withValues(alpha: 0.6);
    }
  }

  Color _getPercentageBadgeColor() {
    if (insight.percentageChange == null) return Colors.grey;
    if (insight.percentageChange! > 0) {
      return insight.type == InsightType.positive 
        ? const Color(0xFF10B981) 
        : const Color(0xFFEF4444);
    }
    return const Color(0xFF10B981);
  }

  Color _getPercentageTextColor() {
    return Colors.white;
  }

  String _getTimeAgo() {
    final diff = DateTime.now().difference(insight.timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

/// Insights List Widget - Shows multiple insight cards
class InsightsListWidget extends StatelessWidget {
  final List<Insight> insights;
  final String? title;

  const InsightsListWidget({
    super.key,
    required this.insights,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(Icons.psychology_rounded, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No insights yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              'Check back later for AI-powered activity analysis',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title!,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${insights.length} insights',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
        ...insights.map((insight) => SmartInsightCard(insight: insight)),
      ],
    );
  }
}
