import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:child_safety_monitor/data/database/app_database.dart';
import 'package:child_safety_monitor/data/repositories/events_repository.dart';
import 'package:child_safety_monitor/data/models/behavioral_event.dart';

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

  test('getRecentEvents maps BehavioralEventData to BehavioralEvent domain model', () async {
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
        id: 'evt_1',
        childId: 'child_1',
        timestamp: now,
        durationSeconds: 120,
        interactionCount: 15,
        newKnownContacts: 1,
        unknownContacts: 0,
        appCategory: 'social',
        appName: 'TestApp',
        deviceType: 'mobile',
        riskScore: 30,
        riskLevel: 'low',
      ),
    );

    final stream = repository.getRecentEvents('child_1', limit: 10);
    final events = await stream.first;

    expect(events.length, 1);
    expect(events.first, isA<BehavioralEvent>());
    expect(events.first.id, 'evt_1');
    expect(events.first.appName, 'TestApp');
    expect(events.first.riskScore, 30);
  });

  test('getEventsByDateRange maps BehavioralEventData to BehavioralEvent domain model', () async {
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
        id: 'evt_2',
        childId: 'child_1',
        timestamp: now,
        durationSeconds: 300,
        interactionCount: 45,
        newKnownContacts: 2,
        unknownContacts: 1,
        appCategory: 'gaming',
        appName: 'GameApp',
        deviceType: 'tablet',
        riskScore: 75,
        riskLevel: 'high',
      ),
    );

    final events = await repository.getEventsByDateRange('child_1', start, end);

    expect(events.length, 1);
    expect(events.first, isA<BehavioralEvent>());
    expect(events.first.id, 'evt_2');
    expect(events.first.appName, 'GameApp');
    expect(events.first.riskLevel, 'high');
  });
}
