import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:child_safety_monitor/data/database/app_database.dart';
import 'package:child_safety_monitor/screens/dashboard/dashboard_screen.dart';
import 'package:child_safety_monitor/providers/insights_provider.dart';
import 'package:child_safety_monitor/services/insights_engine.dart';
import 'package:child_safety_monitor/widgets/smart_insight_card.dart';

class _FakeInsightsNotifier extends InsightsNotifier {
  _FakeInsightsNotifier(super.db, InsightsState initial) {
    state = initial;
  }

  @override
  Future<void> loadInsights() async {
    // Avoid hitting db during test
  }

  void updateState(InsightsState newState) {
    state = newState;
  }
}

void main() {
  testWidgets('DashboardScreen renders main metrics and scoped insights section correctly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final testDb = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() async => await testDb.close());

    final fakeInsights = [
      Insight(
        id: 'test_insight_1',
        childId: 'child_1',
        childName: 'Ananya',
        type: InsightType.positive,
        title: 'Learning Champion!',
        message: 'Ananya spent more time on educational apps today.',
        timestamp: DateTime.now(),
      ),
      Insight(
        id: 'test_insight_2',
        childId: 'child_2',
        childName: 'Arjun',
        type: InsightType.warning,
        title: 'Gaming Limit Nearing',
        message: 'Arjun has played for 2 hours today.',
        timestamp: DateTime.now(),
      ),
    ];

    final fakeNotifier = _FakeInsightsNotifier(
      testDb,
      InsightsState(
        insights: fakeInsights,
        isLoading: false,
        hasEnoughData: true,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(testDb),
          insightsProvider.overrideWith((ref) => fakeNotifier),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: DashboardScreen(),
          ),
        ),
      ),
    );

    // Pump frames to complete entry animations (e.g. FadeSlideIn 600ms + 300ms delay)
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));

    // Verify Dashboard headers & metrics
    expect(find.text('Analytics Dashboard'), findsOneWidget);
    expect(find.text('Family Risk Score'), findsOneWidget);
    expect(find.text('Weekly Activity'), findsOneWidget);
    expect(find.text('Risk Categories'), findsOneWidget);
    expect(find.text('AI Insights Engine'), findsOneWidget);

    // Verify insights rendered via direct collection for-loop
    expect(find.byType(SmartInsightCard), findsNWidgets(2));
    expect(find.text('Learning Champion!'), findsOneWidget);
    expect(find.text('Gaming Limit Nearing'), findsOneWidget);

    // Verify updating insights state reflects correctly in the scoped section
    fakeNotifier.updateState(
      InsightsState(
        insights: [fakeInsights.first],
        isLoading: false,
        hasEnoughData: true,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(SmartInsightCard), findsOneWidget);
    expect(find.text('Learning Champion!'), findsOneWidget);
    expect(find.text('Gaming Limit Nearing'), findsNothing);
  });
}
