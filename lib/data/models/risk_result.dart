class RiskResult {
  final int riskScore;
  final String riskLevel; // "low", "medium", "high", "critical"
  final int durationRisk;
  final int frequencyRisk;
  final int contactRisk;
  final List<String> recommendations;
  final bool shouldAlert;
  final String message;

  RiskResult({
    required this.riskScore,
    required this.riskLevel,
    required this.durationRisk,
    required this.frequencyRisk,
    required this.contactRisk,
    required this.recommendations,
    required this.shouldAlert,
    required this.message,
  });
}