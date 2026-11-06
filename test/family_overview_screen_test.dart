import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:child_safety_monitor/screens/family_overview/family_overview_screen.dart';
import 'package:child_safety_monitor/providers/insights_provider.dart';
import 'package:child_safety_monitor/services/insights_engine.dart';

void main() {
  testWidgets('FamilyOverviewScreen renders successfully with scoped insights section', (WidgetTester tester) async {
    // Provide a known InsightsState to verify rendering
    final testInsights = [
      Insight(
        id: 'test_insight_1',
        childId: 'child_1',
        childName: 'Ananya',
        type: InsightType.positive,
        title: 'Focus',
        message: 'Healthy balance achieved today.',
        timestamp: DateTime.now(),
      ),
    ];

    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          insightsProvider.overrideWith((ref) => _MockInsightsNotifier(
            InsightsState(
              insights: testInsights,
              isLoading: false,
              hasEnoughData: true,
            ),
          )),
        ],
        child: const MaterialApp(
          home: FamilyOverviewScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify header and main sections render
    expect(find.text('Family Safety Dashboard'), findsOneWidget);
    expect(find.text('AI Insights'), findsOneWidget);
    expect(find.text('Focus'), findsOneWidget);
    expect(find.text('Your Children'), findsOneWidget);
    expect(find.text('Recent Activity'), findsOneWidget);
  });
}

class _MockInsightsNotifier extends StateNotifier<InsightsState> implements InsightsNotifier {
  _MockInsightsNotifier(super.state);

  @override
  Future<void> loadInsights() async {}

  @override
  Future<void> refresh() async {}

  @override
  Future<void> refreshInsightsForChild(String childId) async {}

  @override
  void dismissInsight(String insightId) {
    state = state.copyWith(
      insights: state.insights.where((i) => i.id != insightId).toList(),
    );
  }
}
