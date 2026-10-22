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

  test('EventsRepository maps BehavioralEventData to BehavioralEvent correctly', () async {
    final now = DateTime.now();

    await database.into(database.behavioralEvents).insert(
      BehavioralEventsCompanion.insert(
        id: 'evt_1',
        childId: 'child_1',
        timestamp: now,
        durationSeconds: 1200,
        interactionCount: 150,
        newKnownContacts: 1,
        unknownContacts: 0,
        appCategory: 'Social',
        appName: 'ChatApp',
        deviceType: 'Phone',
        riskScore: 20,
        riskLevel: 'low',
      ),
    );

    final events = await repository.getEventsByDateRange(
      'child_1',
      now.subtract(const Duration(minutes: 5)),
      now.add(const Duration(minutes: 5)),
    );

    expect(events.length, 1);
    expect(events.first, isA<BehavioralEvent>());
    expect(events.first.id, 'evt_1');
    expect(events.first.childId, 'child_1');
    expect(events.first.appName, 'ChatApp');
    expect(events.first.riskScore, 20);
    expect(events.first.riskLevel, 'low');
  });

  test('EventsRepository getRecentEvents streams BehavioralEvent list correctly', () async {
    final now = DateTime.now();

    await database.into(database.behavioralEvents).insert(
      BehavioralEventsCompanion.insert(
        id: 'evt_2',
        childId: 'child_1',
        timestamp: now,
        durationSeconds: 300,
        interactionCount: 50,
        newKnownContacts: 0,
        unknownContacts: 2,
        appCategory: 'Gaming',
        appName: 'GameX',
        deviceType: 'Tablet',
        riskScore: 65,
        riskLevel: 'medium',
      ),
    );

    final stream = repository.getRecentEvents('child_1');
    final events = await stream.first;

    expect(events.length, 1);
    expect(events.first, isA<BehavioralEvent>());
    expect(events.first.id, 'evt_2');
    expect(events.first.appName, 'GameX');
    expect(events.first.riskLevel, 'medium');
  });
}
