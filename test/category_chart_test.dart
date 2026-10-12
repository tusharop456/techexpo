import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:child_safety_monitor/widgets/category_chart.dart';

void main() {
  testWidgets('CategoryChart renders category names, formatted values, and indicators', (WidgetTester tester) async {
    final Map<String, double> sampleData = {
      'Gaming': 4.5,
      'Education': 2.0,
      'Social': 1.25,
    };

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CategoryChart(categoryData: sampleData),
        ),
      ),
    );

    // Verify key labels render
    expect(find.text('Gaming'), findsOneWidget);
    expect(find.text('Education'), findsOneWidget);
    expect(find.text('Social'), findsOneWidget);

    // Verify formatted time text
    expect(find.text('4.5h'), findsOneWidget);
    expect(find.text('2.0h'), findsOneWidget);
    expect(find.text('1.3h'), findsOneWidget); // 1.25 rounded to 1 decimal

    // Verify progress indicators count
    expect(find.byType(LinearProgressIndicator), findsNWidgets(3));
  });
}
