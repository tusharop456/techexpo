import 'package:child_safety_monitor/data/database/app_database.dart';
import 'package:child_safety_monitor/data/models/behavioral_event.dart';
import 'package:drift/drift.dart';

class EventsRepository {
  final AppDatabase db;
  EventsRepository(this.db);

  // Watches the latest 50 behavioral events for a specific child
  Stream<List<BehavioralEvent>> getRecentEvents(String childId, {int limit = 50}) {
    return (db.select(db.behavioralEvents)
          ..where((t) => t.childId.equals(childId))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
          ..limit(limit))
        .watch()
        .map((events) => events.cast<BehavioralEvent>());
  }
  Future<List<BehavioralEvent>> getEventsByDateRange(String childId, DateTime start, DateTime end) async {
    final results = await (db.select(db.behavioralEvents)
          ..where((t) => t.childId.equals(childId))
          ..where((t) => t.timestamp.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .get();
    return results.cast<BehavioralEvent>();
  }
}