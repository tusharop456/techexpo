import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:child_safety_monitor/screens/content_scanner/content_scanner_screen.dart';

void main() {
  group('ScoreGaugePainter shouldRepaint tests', () {
    test('returns false when score and color are unchanged', () {
      final painter1 = ScoreGaugePainter(score: 85, color: Colors.green);
      final painter2 = ScoreGaugePainter(score: 85, color: Colors.green);

      expect(painter1.shouldRepaint(painter2), isFalse);
    });

    test('returns true when score changes', () {
      final painter1 = ScoreGaugePainter(score: 85, color: Colors.green);
      final painter2 = ScoreGaugePainter(score: 90, color: Colors.green);

      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    test('returns true when color changes', () {
      final painter1 = ScoreGaugePainter(score: 85, color: Colors.green);
      final painter2 = ScoreGaugePainter(score: 85, color: Colors.red);

      expect(painter1.shouldRepaint(painter2), isTrue);
    });
  });
}
