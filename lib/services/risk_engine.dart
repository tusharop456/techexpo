import 'dart:math';
import 'package:child_safety_monitor/data/models/risk_result.dart';

class RiskEngine {
  static RiskResult calculateRisk({
    required DateTime timestamp,
    required int durationSeconds,
    required int interactionCount,
    required int newKnownContacts,
    required int unknownContacts,
    required int childAge,
  }) {
    // 1. Duration Risk (30% weight)
    double durationHours = durationSeconds / 3600;
    int dPoints = 0;
    if (durationHours >= 10) {
      dPoints = 90;
    } else if (durationHours >= 8) {
      dPoints = 70;
    } else if (durationHours >= 6) {
      dPoints = 50;
    } else if (durationHours >= 4) {
      dPoints = 30;
    } else if (durationHours >= 2) {
      dPoints = 15;
    }

    // 2. Frequency Risk (30% weight)
    int fPoints = 0;
    if (interactionCount >= 1000) {
      fPoints = 85;
    } else if (interactionCount >= 600) {
      fPoints = 65;
    } else if (interactionCount >= 300) {
      fPoints = 40;
    } else if (interactionCount >= 100) {
      fPoints = 20;
    }

    // 3. Contact Risk (40% weight)
    int knownPoints = min(newKnownContacts * 2, 20);
    int unknownPoints = min(unknownContacts * 15, 80);
    int cPoints = knownPoints + unknownPoints;

    // Base Calculation
    double baseRisk = (dPoints * 0.30) + (fPoints * 0.30) + (cPoints * 0.40);

    // 4. Temporal Modifiers
    int tModifier = 0;
    bool isWeekend = timestamp.weekday == DateTime.saturday || timestamp.weekday == DateTime.sunday;
    int hour = timestamp.hour;

    if (hour >= 0 && hour < 6) {
      tModifier = 30; // Late night
    } else if (!isWeekend && hour >= 9 && hour <= 15) {
      tModifier = 25; // School hours
    } else if (isWeekend) {
      tModifier = -10; // Weekend reduction
    }

    // 5. Age Adjustments
    double ageMult = 1.0;
    if (childAge >= 6 && childAge <= 8) {
      ageMult = 1.3;
    } else if (childAge >= 9 && childAge <= 11) {
      ageMult = 1.1;
    } else if (childAge >= 15 && childAge <= 17) {
      ageMult = 0.9;
    }

    // Final Score
    double modifiedRisk = baseRisk + tModifier;
    int finalScore = min((modifiedRisk * ageMult).round(), 100);
    finalScore = max(finalScore, 0); // Ensure no negative

    // Level & Messaging
    String level;
    List<String> recs = [];
    if (finalScore <= 30) {
      level = "low";
      recs.add("Normal activity detected. No action needed.");
    } else if (finalScore <= 60) {
      level = "medium";
      recs.add("Monitor app usage trends.");
      recs.add("Discuss screen time balance with your child.");
    } else if (finalScore <= 80) {
      level = "high";
      recs.add("High interaction with unknown contacts.");
      recs.add("Check recent messaging history.");
      recs.add("Consider setting app limits.");
    } else {
      level = "critical";
      recs.add("IMMEDIATE ATTENTION: Excessive late-night usage.");
      recs.add("Restrict device access immediately.");
      recs.add("Review contact list for security.");
    }

    return RiskResult(
      riskScore: finalScore,
      riskLevel: level,
      durationRisk: dPoints,
      frequencyRisk: fPoints,
      contactRisk: cPoints,
      recommendations: recs,
      shouldAlert: finalScore > 70,
      message: "Score calculated based on ${durationHours.toStringAsFixed(1)}h usage and $unknownContacts unknown contacts.",
    );
  }
}