import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:child_safety_monitor/data/database/app_database.dart';
import 'package:child_safety_monitor/data/repositories/events_repository.dart';
import 'package:child_safety_monitor/data/models/behavioral_event.dart';

void main() {
  late AppDatabase database;
  late EventsRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = EventsRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('getEventsByDateRange correctly maps BehavioralEventData to BehavioralEvent domain model', () async {
    final now = DateTime.now();
    await database.into(database.children).insert(
      ChildrenCompanion.insert(
        id: 'child1',
        name: 'Alex',
      ),
    );

    await database.into(database.behavioralEvents).insert(
      BehavioralEventsCompanion.insert(
        id: 'evt1',
        childId: 'child1',
        timestamp: now,
        durationSeconds: 120,
        interactionCount: 15,
        newKnownContacts: 2,
        unknownContacts: 0,
        appCategory: 'Social',
        appName: 'ChatApp',
        deviceType: 'Mobile',
        riskScore: 10,
        riskLevel: 'Low',
      ),
    );

    final events = await repository.getEventsByDateRange(
      'child1',
      now.subtract(const Duration(minutes: 5)),
      now.add(const Duration(minutes: 5)),
    );

    expect(events.length, equals(1));
    expect(events.first, isA<BehavioralEvent>());
    expect(events.first.id, equals('evt1'));
    expect(events.first.appName, equals('ChatApp'));
  });

  test('getRecentEvents stream correctly emits BehavioralEvent domain models', () async {
    final now = DateTime.now();
    await database.into(database.children).insert(
      ChildrenCompanion.insert(
        id: 'child2',
        name: 'Sam',
      ),
    );

    await database.into(database.behavioralEvents).insert(
      BehavioralEventsCompanion.insert(
        id: 'evt2',
        childId: 'child2',
        timestamp: now,
        durationSeconds: 300,
        interactionCount: 50,
        newKnownContacts: 0,
        unknownContacts: 1,
        appCategory: 'Gaming',
        appName: 'GameApp',
        deviceType: 'Tablet',
        riskScore: 25,
        riskLevel: 'Medium',
      ),
    );

    final stream = repository.getRecentEvents('child2');
    final events = await stream.first;

    expect(events.length, equals(1));
    expect(events.first, isA<BehavioralEvent>());
    expect(events.first.id, equals('evt2'));
    expect(events.first.appName, equals('GameApp'));
  });
}
