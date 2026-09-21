import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:child_safety_monitor/screens/content_scanner/content_scanner_screen.dart';

void main() {
  group('ScoreGaugePainter tests', () {
    test('shouldRepaint returns false when score and color are identical', () {
      final painter1 = ScoreGaugePainter(score: 85, color: Colors.green);
      final painter2 = ScoreGaugePainter(score: 85, color: Colors.green);

      expect(painter2.shouldRepaint(painter1), isFalse);
    });

    test('shouldRepaint returns true when score changes', () {
      final painter1 = ScoreGaugePainter(score: 85, color: Colors.green);
      final painter2 = ScoreGaugePainter(score: 90, color: Colors.green);

      expect(painter2.shouldRepaint(painter1), isTrue);
    });

    test('shouldRepaint returns true when color changes', () {
      final painter1 = ScoreGaugePainter(score: 85, color: Colors.green);
      final painter2 = ScoreGaugePainter(score: 85, color: Colors.red);

      expect(painter2.shouldRepaint(painter1), isTrue);
    });
  });
}
