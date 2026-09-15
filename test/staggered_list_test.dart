import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:child_safety_monitor/widgets/animated_widgets.dart';

void main() {
  testWidgets('StaggeredList renders all children correctly and animates', (WidgetTester tester) async {
    final children = [
      const Text('Item 1'),
      const Text('Item 2'),
      const Text('Item 3'),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StaggeredList(
            itemDelay: const Duration(milliseconds: 100),
            itemDuration: const Duration(milliseconds: 300),
            children: children,
          ),
        ),
      ),
    );

    // Verify all children are present in the tree
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);
    expect(find.text('Item 3'), findsOneWidget);

    // Advance time to complete full staggered animation (100ms * 2 + 300ms = 500ms)
    await tester.pump(const Duration(milliseconds: 500));

    // Verify children are still rendered properly after animation completion
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);
    expect(find.text('Item 3'), findsOneWidget);
  });

  testWidgets('StaggeredList handles empty children list without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StaggeredList(
            children: [],
          ),
        ),
      ),
    );

    expect(find.byType(StaggeredList), findsOneWidget);
  });
}
