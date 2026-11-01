import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:child_safety_monitor/screens/child_profile/child_profile_screen.dart';
import 'package:child_safety_monitor/providers/app_state.dart';
import 'package:child_safety_monitor/data/models/app_models.dart';

class _FakeChildrenNotifier extends ChildrenNotifier {
  _FakeChildrenNotifier(List<ChildModel> initial) {
    state = initial;
  }
}

class _FakeAlertsNotifier extends AlertsNotifier {
  _FakeAlertsNotifier(List<AlertModel> initial) {
    state = initial;
  }
}

void main() {
  testWidgets('ChildProfileScreen renders screen time section with single-pass aggregated data', (WidgetTester tester) async {
    final testChild = ChildModel(
      id: 'child_1',
      name: 'Ananya',
      riskLevel: 25,
      lastActive: DateTime.now(),
      deviceName: 'Pixel 7',
    );

    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          childrenProvider.overrideWith((ref) => _FakeChildrenNotifier([testChild])),
          alertsProvider.overrideWith((ref) => _FakeAlertsNotifier([])),
        ],
        child: const MaterialApp(
          home: ChildProfileScreen(childId: 'child_1'),
        ),
      ),
    );

    // Verify Screen Time Today title
    expect(find.text('Screen Time Today'), findsOneWidget);

    // Verify calculated total hours: 2.5 + 1.8 + 1.2 + 0.8 + 0.5 = 6.8h total
    expect(find.text('6.8h total'), findsOneWidget);

    // Verify category labels in legend
    expect(find.text('Education'), findsOneWidget);
    expect(find.text('Social Media'), findsOneWidget);
    expect(find.text('Gaming'), findsOneWidget);
    expect(find.text('Entertainment'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);

    // Verify category hour text in legend
    expect(find.text('2.5h'), findsOneWidget);
    expect(find.text('1.8h'), findsOneWidget);
    expect(find.text('1.2h'), findsOneWidget);
    expect(find.text('0.8h'), findsOneWidget);
    expect(find.text('0.5h'), findsOneWidget);

    // Verify PieChart exists and has 5 sections
    final pieChartFinder = find.byType(PieChart);
    expect(pieChartFinder, findsAtLeastNWidgets(1));
    final pieChartWidget = tester.widget<PieChart>(pieChartFinder.first);
    expect(pieChartWidget.data.sections.length, equals(5));
  });
}
