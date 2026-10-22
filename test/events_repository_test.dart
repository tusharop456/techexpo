import 'package:child_safety_monitor/data/database/app_database.dart';
import 'package:child_safety_monitor/data/models/behavioral_event.dart';
import 'package:child_safety_monitor/data/repositories/events_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late EventsRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = EventsRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('getRecentEvents streams domain BehavioralEvent models correctly', () async {
    // Insert a child first due to foreign key constraints
    await db.into(db.children).insert(
          ChildrenCompanion.insert(
            id: 'child_1',
            name: 'Test Child',
          ),
        );

    final now = DateTime.now();
    await db.into(db.behavioralEvents).insert(
          BehavioralEventsCompanion.insert(
            id: 'event_1',
            childId: 'child_1',
            timestamp: now,
            durationSeconds: 120,
            interactionCount: 5,
            newKnownContacts: 1,
            unknownContacts: 0,
            appCategory: 'social',
            appName: 'ChatApp',
            deviceType: 'mobile',
            riskScore: 10,
            riskLevel: 'low',
          ),
        );

    final eventsStream = repository.getRecentEvents('child_1');
    final events = await eventsStream.first;

    expect(events, isA<List<BehavioralEvent>>());
    expect(events.length, equals(1));
    expect(events.first.id, equals('event_1'));
    expect(events.first.appName, equals('ChatApp'));
    expect(events.first.riskLevel, equals('low'));
  });

  test('getEventsByDateRange returns domain BehavioralEvent models correctly', () async {
    await db.into(db.children).insert(
          ChildrenCompanion.insert(
            id: 'child_1',
            name: 'Test Child',
          ),
        );

    final now = DateTime.now();
    final start = now.subtract(const Duration(hours: 1));
    final end = now.add(const Duration(hours: 1));

    await db.into(db.behavioralEvents).insert(
          BehavioralEventsCompanion.insert(
            id: 'event_2',
            childId: 'child_1',
            timestamp: now,
            durationSeconds: 300,
            interactionCount: 15,
            newKnownContacts: 0,
            unknownContacts: 2,
            appCategory: 'gaming',
            appName: 'GameApp',
            deviceType: 'tablet',
            riskScore: 40,
            riskLevel: 'medium',
          ),
        );

    final events = await repository.getEventsByDateRange('child_1', start, end);

    expect(events, isA<List<BehavioralEvent>>());
    expect(events.length, equals(1));
    expect(events.first.id, equals('event_2'));
    expect(events.first.appName, equals('GameApp'));
    expect(events.first.riskLevel, equals('medium'));
  });
}
