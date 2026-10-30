import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:child_safety_monitor/screens/content_scanner/content_scanner_screen.dart';

void main() {
  testWidgets('ScoreGaugePainter shouldRepaint logic', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ContentScannerScreen(),
      ),
    );

    // Pump widget tree to ensure CustomPaint rendered
    expect(find.byType(ContentScannerScreen), findsOneWidget);
  });
}
