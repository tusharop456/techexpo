import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:child_safety_monitor/data/database/app_database.dart';
import 'package:child_safety_monitor/data/models/behavioral_event.dart';
import 'package:child_safety_monitor/data/repositories/events_repository.dart';

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

  test('EventsRepository maps BehavioralEventData to BehavioralEvent domain model correctly', () async {
    final now = DateTime.now();

    // Insert a child record first (foreign key constraint)
    await db.into(db.children).insert(
      ChildrenCompanion.insert(
        id: 'child_1',
        name: 'Child One',
        riskLevel: const drift.Value(1),
        lastActive: drift.Value(now),
      ),
    );

    // Insert behavioral event records
    await db.into(db.behavioralEvents).insert(
      BehavioralEventsCompanion.insert(
        id: 'evt_1',
        childId: 'child_1',
        timestamp: now.subtract(const Duration(minutes: 10)),
        durationSeconds: 300,
        interactionCount: 15,
        newKnownContacts: 1,
        unknownContacts: 0,
        appCategory: 'social',
        appName: 'TikTok',
        deviceType: 'mobile',
        riskScore: 25,
        riskLevel: 'low',
      ),
    );

    await db.into(db.behavioralEvents).insert(
      BehavioralEventsCompanion.insert(
        id: 'evt_2',
        childId: 'child_1',
        timestamp: now.subtract(const Duration(minutes: 5)),
        durationSeconds: 600,
        interactionCount: 40,
        newKnownContacts: 0,
        unknownContacts: 2,
        appCategory: 'chat',
        appName: 'Discord',
        deviceType: 'desktop',
        riskScore: 75,
        riskLevel: 'high',
      ),
    );

    // Verify getRecentEvents returns list of BehavioralEvent domain objects
    final recentEventsStream = repository.getRecentEvents('child_1', limit: 10);
    final eventsList = await recentEventsStream.first;

    expect(eventsList, isA<List<BehavioralEvent>>());
    expect(eventsList.length, equals(2));
    expect(eventsList.first.id, equals('evt_2')); // Ordered DESC by timestamp
    expect(eventsList.first.appName, equals('Discord'));
    expect(eventsList.first.riskLevel, equals('high'));

    // Verify getEventsByDateRange returns list of BehavioralEvent domain objects
    final rangeEvents = await repository.getEventsByDateRange(
      'child_1',
      now.subtract(const Duration(hours: 1)),
      now,
    );

    expect(rangeEvents, isA<List<BehavioralEvent>>());
    expect(rangeEvents.length, equals(2));
    expect(rangeEvents.last.id, equals('evt_1'));
    expect(rangeEvents.last.appName, equals('TikTok'));
  });
}
