import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RiskTrendChart extends StatelessWidget {
  final List<FlSpot> spots;
  final Color color;

  const RiskTrendChart({
    super.key,
    required this.spots,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }
}
