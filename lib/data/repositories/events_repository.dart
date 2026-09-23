import 'package:child_safety_monitor/data/database/app_database.dart';
import 'package:child_safety_monitor/data/models/behavioral_event.dart';
import 'package:drift/drift.dart';

/// Repository for retrieving and streaming behavioral events from the database.
class EventsRepository {
  final AppDatabase db;
  EventsRepository(this.db);

  /// Watches the latest [limit] behavioral events for a specific child.
  Stream<List<BehavioralEvent>> getRecentEvents(String childId, {int limit = 50}) {
    return (db.select(db.behavioralEvents)
          ..where((t) => t.childId.equals(childId))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
          ..limit(limit))
        .watch()
        .map((events) => events.map(_mapToDomain).toList());
  }

  /// Fetches behavioral events for a child within a given date range.
  Future<List<BehavioralEvent>> getEventsByDateRange(String childId, DateTime start, DateTime end) async {
    final results = await (db.select(db.behavioralEvents)
          ..where((t) => t.childId.equals(childId))
          ..where((t) => t.timestamp.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .get();
    return results.map(_mapToDomain).toList();
  }

  /// Helper to convert Drift-generated [BehavioralEventData] to [BehavioralEvent] domain model.
  BehavioralEvent _mapToDomain(BehavioralEventData data) {
    return BehavioralEvent(
      id: data.id,
      childId: data.childId,
      timestamp: data.timestamp,
      durationSeconds: data.durationSeconds,
      interactionCount: data.interactionCount,
      newKnownContacts: data.newKnownContacts,
      unknownContacts: data.unknownContacts,
      appCategory: data.appCategory,
      appName: data.appName,
      deviceType: data.deviceType,
      riskScore: data.riskScore,
      riskLevel: data.riskLevel,
    );
  }
}
