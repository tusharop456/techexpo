import 'package:flutter/material.dart';
import 'package:child_safety_monitor/core/constants/app_colors.dart';

class CategoryChart extends StatelessWidget {
  final Map<String, double> categoryData;

  const CategoryChart({super.key, required this.categoryData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: categoryData.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text('${entry.value.toStringAsFixed(1)}h'),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: entry.value / 10, // Normalized to 10h max for demo
                backgroundColor: Colors.grey[200],
                color: AppColors.secondary,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}