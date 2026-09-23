import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:child_safety_monitor/data/database/app_database.dart';
import 'package:child_safety_monitor/data/repositories/events_repository.dart';
import 'package:child_safety_monitor/data/models/behavioral_event.dart';

void main() {
  late AppDatabase db;
  late EventsRepository repository;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = EventsRepository(db);

    // Insert a child record first to satisfy foreign key constraint
    await db.into(db.children).insert(
          ChildrenCompanion.insert(
            id: 'child1',
            name: 'Alex',
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  test('EventsRepository maps BehavioralEventData to BehavioralEvent correctly for getRecentEvents', () async {
    final now = DateTime.now();

    await db.into(db.behavioralEvents).insert(
          BehavioralEventsCompanion.insert(
            id: 'event1',
            childId: 'child1',
            timestamp: now,
            durationSeconds: 120,
            interactionCount: 15,
            newKnownContacts: 1,
            unknownContacts: 0,
            appCategory: 'Social',
            appName: 'ChatApp',
            deviceType: 'Mobile',
            riskScore: 25,
            riskLevel: 'Low',
          ),
        );

    final stream = repository.getRecentEvents('child1');
    final events = await stream.first;

    expect(events.length, equals(1));
    expect(events.first, isA<BehavioralEvent>());
    expect(events.first.id, equals('event1'));
    expect(events.first.childId, equals('child1'));
    expect(events.first.appName, equals('ChatApp'));
    expect(events.first.riskScore, equals(25));
  });

  test('EventsRepository maps BehavioralEventData to BehavioralEvent correctly for getEventsByDateRange', () async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(hours: 1));
    final end = now.add(const Duration(hours: 1));

    await db.into(db.behavioralEvents).insert(
          BehavioralEventsCompanion.insert(
            id: 'event2',
            childId: 'child1',
            timestamp: now,
            durationSeconds: 300,
            interactionCount: 50,
            newKnownContacts: 2,
            unknownContacts: 1,
            appCategory: 'Gaming',
            appName: 'GameApp',
            deviceType: 'Tablet',
            riskScore: 60,
            riskLevel: 'Medium',
          ),
        );

    final events = await repository.getEventsByDateRange('child1', start, end);

    expect(events.length, equals(1));
    expect(events.first, isA<BehavioralEvent>());
    expect(events.first.id, equals('event2'));
    expect(events.first.appName, equals('GameApp'));
    expect(events.first.riskScore, equals(60));
  });
}
