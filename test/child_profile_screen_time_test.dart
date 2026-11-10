import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:child_safety_monitor/screens/child_profile/child_profile_screen.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  testWidgets('ChildProfileScreen renders screen time section correctly', (WidgetTester tester) async {
    // Set a wide screen size (desktop layout) as expected by the dashboard and profile views
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ChildProfileScreen(childId: 'child_1'),
          ),
        ),
      ),
    );

    // Verify Screen Time Today title
    expect(find.text('Screen Time Today'), findsOneWidget);

    // Total hours calculated: 2.5 + 1.8 + 1.2 + 0.8 + 0.5 = 6.8h total
    expect(find.text('6.8h total'), findsOneWidget);

    // Verify categories render
    expect(find.text('Education'), findsOneWidget);
    expect(find.text('Social Media'), findsOneWidget);
    expect(find.text('Gaming'), findsOneWidget);
    expect(find.text('Entertainment'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);

    // Verify category hours text
    expect(find.text('2.5h'), findsOneWidget);
    expect(find.text('1.8h'), findsOneWidget);
    expect(find.text('1.2h'), findsOneWidget);
    expect(find.text('0.8h'), findsOneWidget);
    expect(find.text('0.5h'), findsOneWidget);

    // Verify PieChart exists and has 5 sections
    final pieChartFinder = find.byType(PieChart);
    expect(pieChartFinder, findsWidgets);

    final pieChartWidget = tester.widgetList<PieChart>(pieChartFinder).first;
    expect(pieChartWidget.data.sections.length, 5);
  });
}
