import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull;
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

    // Insert a parent child record due to foreign key constraint
    await db.into(db.children).insert(
      ChildrenCompanion.insert(
        id: 'child_1',
        name: 'Test Child',
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('getRecentEvents maps BehavioralEventData to BehavioralEvent domain models', () async {
    final now = DateTime.now();
    await db.into(db.behavioralEvents).insert(
      BehavioralEventsCompanion.insert(
        id: 'event_1',
        childId: 'child_1',
        timestamp: now,
        durationSeconds: 300,
        interactionCount: 50,
        newKnownContacts: 2,
        unknownContacts: 0,
        appCategory: 'education',
        appName: 'Duolingo',
        deviceType: 'phone',
        riskScore: 10,
        riskLevel: 'low',
      ),
    );

    final eventsStream = repository.getRecentEvents('child_1');
    final events = await eventsStream.first;

    expect(events.length, equals(1));
    expect(events.first, isA<BehavioralEvent>());
    expect(events.first.id, equals('event_1'));
    expect(events.first.appName, equals('Duolingo'));
    expect(events.first.riskScore, equals(10));
  });

  test('getEventsByDateRange maps BehavioralEventData to BehavioralEvent domain models', () async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(hours: 1));
    final end = now.add(const Duration(hours: 1));

    await db.into(db.behavioralEvents).insert(
      BehavioralEventsCompanion.insert(
        id: 'event_2',
        childId: 'child_1',
        timestamp: now,
        durationSeconds: 600,
        interactionCount: 100,
        newKnownContacts: 1,
        unknownContacts: 1,
        appCategory: 'social',
        appName: 'Instagram',
        deviceType: 'phone',
        riskScore: 50,
        riskLevel: 'medium',
      ),
    );

    final events = await repository.getEventsByDateRange('child_1', start, end);

    expect(events.length, equals(1));
    expect(events.first, isA<BehavioralEvent>());
    expect(events.first.id, equals('event_2'));
    expect(events.first.appName, equals('Instagram'));
    expect(events.first.riskLevel, equals('medium'));
  });
}
