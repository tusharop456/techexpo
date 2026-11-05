import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:child_safety_monitor/data/database/app_database.dart';
import 'package:child_safety_monitor/screens/dashboard/dashboard_screen.dart';
import 'package:child_safety_monitor/providers/insights_provider.dart';
import 'package:child_safety_monitor/providers/app_state.dart';
import 'package:child_safety_monitor/services/insights_engine.dart';
import 'package:child_safety_monitor/widgets/smart_insight_card.dart';

void main() {
  testWidgets('DashboardScreen renders properly with isolated insights section',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final demoInsights = [
      Insight(
        id: 'insight_1',
        childId: 'child_1',
        childName: 'Ananya',
        type: InsightType.warning,
        title: 'Social Media Surge',
        message: 'Ananya spent extra time on Instagram today.',
        recommendation: 'Encourage a quick break.',
        timestamp: DateTime.now(),
      ),
      Insight(
        id: 'insight_2',
        childId: 'child_2',
        childName: 'Liam',
        type: InsightType.positive,
        title: 'Learning Champion',
        message: 'Liam spent 90 minutes on Khan Academy.',
        recommendation: 'Celebrate good study habits!',
        timestamp: DateTime.now(),
      ),
    ];

    final db = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          insightsProvider.overrideWith((ref) => _MockInsightsNotifier(
                db,
                InsightsState(
                  insights: demoInsights,
                  isLoading: false,
                  hasEnoughData: true,
                ),
              )),
          averageRiskProvider.overrideWith((ref) => 25),
        ],
        child: const MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );

    // Initial render and advance through entry animations
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify DashboardScreen metrics & header rendered
    expect(find.text('Analytics Dashboard'), findsOneWidget);
    expect(find.text('Family Risk Score'), findsOneWidget);
    expect(find.text('AI Insights Engine'), findsOneWidget);

    // Verify smart insight cards rendered via collection for-loop
    expect(find.byType(SmartInsightCard), findsNWidgets(2));
    expect(find.text('Social Media Surge'), findsOneWidget);
    expect(find.text('Learning Champion'), findsOneWidget);

    await db.close();
  });
}

class _MockInsightsNotifier extends InsightsNotifier {
  final InsightsState _initialState;

  _MockInsightsNotifier(super.db, this._initialState) {
    state = _initialState;
  }

  @override
  Future<void> loadInsights() async {
    // Avoid overriding state in mock
  }
}
