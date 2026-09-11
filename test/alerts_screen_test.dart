import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:child_safety_monitor/screens/alerts/alerts_screen.dart';
import 'package:child_safety_monitor/providers/database_provider.dart';
import 'package:child_safety_monitor/data/models/app_models.dart';

void main() {
  testWidgets('AlertsScreen renders properly and calculates single-pass stats correctly', (WidgetTester tester) async {
    final testAlerts = [
      AlertModel(
        id: '1',
        childId: 'child_1',
        childName: 'Ananya',
        title: 'Unread Critical Alert',
        message: 'Critical issue detected',
        timestamp: DateTime.now(),
        isRead: false,
        severity: 2,
        category: 'content',
      ),
      AlertModel(
        id: '2',
        childId: 'child_2',
        childName: 'Arjun',
        title: 'Read Normal Alert',
        message: 'Normal alert message',
        timestamp: DateTime.now(),
        isRead: true,
        severity: 1,
        category: 'time',
      ),
      AlertModel(
        id: '3',
        childId: 'child_1',
        childName: 'Ananya',
        title: 'Unread Normal Alert',
        message: 'Screen time limit',
        timestamp: DateTime.now(),
        isRead: false,
        severity: 1,
        category: 'app',
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mappedAlertsProvider.overrideWithValue(AsyncValue.data(testAlerts)),
        ],
        child: const MaterialApp(
          home: AlertsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify header unread count (2 unread alerts)
    expect(find.text('2 unread alerts requiring attention'), findsOneWidget);

    // Verify tab bar badges (All: 3, Critical: 1)
    expect(find.text('All'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.widgetWithText(Tab, 'Critical'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('Resolved'), findsOneWidget);

    // Verify alert cards are rendered
    expect(find.text('Unread Critical Alert'), findsOneWidget);
  });
}
