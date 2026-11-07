import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:child_safety_monitor/screens/child_profile/child_profile_screen.dart';

void main() {
  testWidgets('ChildProfileScreen renders screen time section, total hours, and category legends', (WidgetTester tester) async {
    // Set a large screen size to prevent desktop/tablet UI overflow
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ChildProfileScreen(childId: '1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify title and total aggregated hours (2.5 + 1.8 + 1.2 + 0.8 + 0.5 = 6.8h)
    expect(find.text('Screen Time Today'), findsOneWidget);
    expect(find.text('6.8h total'), findsOneWidget);

    // Verify category labels are rendered
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

    // Verify Screen Time PieChart (inside the Screen Time card) has 5 sections
    // Note: RiskGauge also contains a 2-section PieChart, so find the PieChart with 5 sections
    final pieCharts = tester.widgetList<PieChart>(find.byType(PieChart));
    final screenTimePieChart = pieCharts.firstWhere((chart) => chart.data.sections.length == 5);
    expect(screenTimePieChart.data.sections.length, 5);
    expect(screenTimePieChart.data.sections.map((s) => s.value).toList(), [2.5, 1.8, 1.2, 0.8, 0.5]);
  });
}
