import 'package:drift/drift.dart';

@DataClassName('Child')
class Children extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get riskLevel => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastActive => dateTime().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Alerts extends Table {
  TextColumn get id => text()();
  TextColumn get childId => text().references(Children, #id)();
  TextColumn get title => text()();
  TextColumn get message => text()();
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get isAcknowledged => boolean().withDefault(const Constant(false))();
  IntColumn get severity => integer()(); // 0: low, 1: medium, 2: high
  TextColumn get category => text().withDefault(const Constant('general'))(); // content, time, app, location, social
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Activity Logs table for AI Insights Engine
@DataClassName('ActivityLogEntry')
class ActivityLogs extends Table {
  TextColumn get id => text()();
  TextColumn get childId => text().references(Children, #id)();
  IntColumn get screenTime => integer()(); // in minutes
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get category => text()(); // gaming, social, education, entertainment, productivity, other
  TextColumn get appName => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('BehavioralEventData')
class BehavioralEvents extends Table {
  TextColumn get id => text()();
  TextColumn get childId => text().references(Children, #id)();
  DateTimeColumn get timestamp => dateTime()();
  IntColumn get durationSeconds => integer()();
  IntColumn get interactionCount => integer()();
  IntColumn get newKnownContacts => integer()();
  IntColumn get unknownContacts => integer()();
  TextColumn get appCategory => text()();
  TextColumn get appName => text()();
  TextColumn get deviceType => text()();
  IntColumn get riskScore => integer()();
  TextColumn get riskLevel => text()();

  @override
  Set<Column> get primaryKey => {id};
}
