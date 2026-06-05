import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:child_safety_monitor/core/constants/app_colors.dart';

class RiskGauge extends StatelessWidget {
  final int score;
  final double size;

  const RiskGauge({super.key, required this.score, this.size = 200});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getRiskColor(score);
    
    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              startDegreeOffset: 180,
              sectionsSpace: 0,
              centerSpaceRadius: (size / 2) - 20,
              sections: [
                PieChartSectionData(
                  value: score.toDouble(),
                  color: color,
                  radius: 20,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: (100 - score).toDouble(),
                  color: Colors.grey.withValues(alpha: 0.2),
                  radius: 20,
                  showTitle: false,
                ),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$score',
                  style: TextStyle(
                    fontSize: size * 0.2,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'RISK SCORE',
                  style: TextStyle(
                    fontSize: size * 0.06,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}