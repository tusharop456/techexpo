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

  test('EventsRepository maps database BehavioralEventData to BehavioralEvent domain model', () async {
    final now = DateTime.now();
    await db.into(db.children).insert(
          ChildrenCompanion.insert(
            id: 'child_1',
            name: 'Test Child',
          ),
        );

    await db.into(db.behavioralEvents).insert(
          BehavioralEventsCompanion.insert(
            id: 'event_1',
            childId: 'child_1',
            timestamp: now,
            durationSeconds: 120,
            interactionCount: 15,
            newKnownContacts: 1,
            unknownContacts: 0,
            appCategory: 'Social',
            appName: 'ChatApp',
            deviceType: 'Phone',
            riskScore: 25,
            riskLevel: 'Low',
          ),
        );

    final events = await repository.getEventsByDateRange(
      'child_1',
      now.subtract(const Duration(hours: 1)),
      now.add(const Duration(hours: 1)),
    );

    expect(events.length, equals(1));
    expect(events.first, isA<BehavioralEvent>());
    expect(events.first.id, equals('event_1'));
    expect(events.first.appName, equals('ChatApp'));
    expect(events.first.riskScore, equals(25));
  });
}
