import 'package:child_safety_monitor/data/database/app_database.dart';
import 'package:child_safety_monitor/data/models/behavioral_event.dart';
import 'package:drift/drift.dart';

class EventsRepository {
  final AppDatabase db;
  EventsRepository(this.db);

  /// BOLT OPTIMIZATION: Converts Drift-generated [BehavioralEventData] instances to
  /// domain model [BehavioralEvent] instances explicitly in O(N) linear time.
  /// This replaces invalid dynamic `.cast<BehavioralEvent>()` calls, preventing expensive
  /// runtime [TypeError] exceptions during database stream/query evaluation.
  BehavioralEvent _mapToDomain(BehavioralEventData e) {
    return BehavioralEvent(
      id: e.id,
      childId: e.childId,
      timestamp: e.timestamp,
      durationSeconds: e.durationSeconds,
      interactionCount: e.interactionCount,
      newKnownContacts: e.newKnownContacts,
      unknownContacts: e.unknownContacts,
      appCategory: e.appCategory,
      appName: e.appName,
      deviceType: e.deviceType,
      riskScore: e.riskScore,
      riskLevel: e.riskLevel,
    );
  }

  // Watches the latest 50 behavioral events for a specific child
  Stream<List<BehavioralEvent>> getRecentEvents(String childId, {int limit = 50}) {
    return (db.select(db.behavioralEvents)
          ..where((t) => t.childId.equals(childId))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
          ..limit(limit))
        .watch()
        .map((events) => events.map(_mapToDomain).toList());
  }

  Future<List<BehavioralEvent>> getEventsByDateRange(String childId, DateTime start, DateTime end) async {
    final results = await (db.select(db.behavioralEvents)
          ..where((t) => t.childId.equals(childId))
          ..where((t) => t.timestamp.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .get();
    return results.map(_mapToDomain).toList();
  }
}
