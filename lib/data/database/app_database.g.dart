// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ChildrenTable extends Children with TableInfo<$ChildrenTable, Child> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChildrenTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _riskLevelMeta =
      const VerificationMeta('riskLevel');
  @override
  late final GeneratedColumn<int> riskLevel = GeneratedColumn<int>(
      'risk_level', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastActiveMeta =
      const VerificationMeta('lastActive');
  @override
  late final GeneratedColumn<DateTime> lastActive = GeneratedColumn<DateTime>(
      'last_active', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, name, riskLevel, lastActive];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'children';
  @override
  VerificationContext validateIntegrity(Insertable<Child> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('risk_level')) {
      context.handle(_riskLevelMeta,
          riskLevel.isAcceptableOrUnknown(data['risk_level']!, _riskLevelMeta));
    }
    if (data.containsKey('last_active')) {
      context.handle(
          _lastActiveMeta,
          lastActive.isAcceptableOrUnknown(
              data['last_active']!, _lastActiveMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Child map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Child(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      riskLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}risk_level'])!,
      lastActive: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_active']),
    );
  }

  @override
  $ChildrenTable createAlias(String alias) {
    return $ChildrenTable(attachedDatabase, alias);
  }
}

class Child extends DataClass implements Insertable<Child> {
  final String id;
  final String name;
  final int riskLevel;
  final DateTime? lastActive;
  const Child(
      {required this.id,
      required this.name,
      required this.riskLevel,
      this.lastActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['risk_level'] = Variable<int>(riskLevel);
    if (!nullToAbsent || lastActive != null) {
      map['last_active'] = Variable<DateTime>(lastActive);
    }
    return map;
  }

  ChildrenCompanion toCompanion(bool nullToAbsent) {
    return ChildrenCompanion(
      id: Value(id),
      name: Value(name),
      riskLevel: Value(riskLevel),
      lastActive: lastActive == null && nullToAbsent
          ? const Value.absent()
          : Value(lastActive),
    );
  }

  factory Child.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Child(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      riskLevel: serializer.fromJson<int>(json['riskLevel']),
      lastActive: serializer.fromJson<DateTime?>(json['lastActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'riskLevel': serializer.toJson<int>(riskLevel),
      'lastActive': serializer.toJson<DateTime?>(lastActive),
    };
  }

  Child copyWith(
          {String? id,
          String? name,
          int? riskLevel,
          Value<DateTime?> lastActive = const Value.absent()}) =>
      Child(
        id: id ?? this.id,
        name: name ?? this.name,
        riskLevel: riskLevel ?? this.riskLevel,
        lastActive: lastActive.present ? lastActive.value : this.lastActive,
      );
  Child copyWithCompanion(ChildrenCompanion data) {
    return Child(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      riskLevel: data.riskLevel.present ? data.riskLevel.value : this.riskLevel,
      lastActive:
          data.lastActive.present ? data.lastActive.value : this.lastActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Child(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('riskLevel: $riskLevel, ')
          ..write('lastActive: $lastActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, riskLevel, lastActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Child &&
          other.id == this.id &&
          other.name == this.name &&
          other.riskLevel == this.riskLevel &&
          other.lastActive == this.lastActive);
}

class ChildrenCompanion extends UpdateCompanion<Child> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> riskLevel;
  final Value<DateTime?> lastActive;
  final Value<int> rowid;
  const ChildrenCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.riskLevel = const Value.absent(),
    this.lastActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChildrenCompanion.insert({
    required String id,
    required String name,
    this.riskLevel = const Value.absent(),
    this.lastActive = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<Child> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? riskLevel,
    Expression<DateTime>? lastActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (riskLevel != null) 'risk_level': riskLevel,
      if (lastActive != null) 'last_active': lastActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChildrenCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<int>? riskLevel,
      Value<DateTime?>? lastActive,
      Value<int>? rowid}) {
    return ChildrenCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      riskLevel: riskLevel ?? this.riskLevel,
      lastActive: lastActive ?? this.lastActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (riskLevel.present) {
      map['risk_level'] = Variable<int>(riskLevel.value);
    }
    if (lastActive.present) {
      map['last_active'] = Variable<DateTime>(lastActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChildrenCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('riskLevel: $riskLevel, ')
          ..write('lastActive: $lastActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AlertsTable extends Alerts with TableInfo<$AlertsTable, Alert> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlertsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _childIdMeta =
      const VerificationMeta('childId');
  @override
  late final GeneratedColumn<String> childId = GeneratedColumn<String>(
      'child_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES children (id)'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageMeta =
      const VerificationMeta('message');
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
      'message', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isAcknowledgedMeta =
      const VerificationMeta('isAcknowledged');
  @override
  late final GeneratedColumn<bool> isAcknowledged = GeneratedColumn<bool>(
      'is_acknowledged', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_acknowledged" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _severityMeta =
      const VerificationMeta('severity');
  @override
  late final GeneratedColumn<int> severity = GeneratedColumn<int>(
      'severity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('general'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        childId,
        title,
        message,
        timestamp,
        isAcknowledged,
        severity,
        category
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alerts';
  @override
  VerificationContext validateIntegrity(Insertable<Alert> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('child_id')) {
      context.handle(_childIdMeta,
          childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta));
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('message')) {
      context.handle(_messageMeta,
          message.isAcceptableOrUnknown(data['message']!, _messageMeta));
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('is_acknowledged')) {
      context.handle(
          _isAcknowledgedMeta,
          isAcknowledged.isAcceptableOrUnknown(
              data['is_acknowledged']!, _isAcknowledgedMeta));
    }
    if (data.containsKey('severity')) {
      context.handle(_severityMeta,
          severity.isAcceptableOrUnknown(data['severity']!, _severityMeta));
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Alert map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Alert(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      childId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}child_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      message: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      isAcknowledged: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_acknowledged'])!,
      severity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}severity'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
    );
  }

  @override
  $AlertsTable createAlias(String alias) {
    return $AlertsTable(attachedDatabase, alias);
  }
}

class Alert extends DataClass implements Insertable<Alert> {
  final String id;
  final String childId;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isAcknowledged;
  final int severity;
  final String category;
  const Alert(
      {required this.id,
      required this.childId,
      required this.title,
      required this.message,
      required this.timestamp,
      required this.isAcknowledged,
      required this.severity,
      required this.category});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['child_id'] = Variable<String>(childId);
    map['title'] = Variable<String>(title);
    map['message'] = Variable<String>(message);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['is_acknowledged'] = Variable<bool>(isAcknowledged);
    map['severity'] = Variable<int>(severity);
    map['category'] = Variable<String>(category);
    return map;
  }

  AlertsCompanion toCompanion(bool nullToAbsent) {
    return AlertsCompanion(
      id: Value(id),
      childId: Value(childId),
      title: Value(title),
      message: Value(message),
      timestamp: Value(timestamp),
      isAcknowledged: Value(isAcknowledged),
      severity: Value(severity),
      category: Value(category),
    );
  }

  factory Alert.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Alert(
      id: serializer.fromJson<String>(json['id']),
      childId: serializer.fromJson<String>(json['childId']),
      title: serializer.fromJson<String>(json['title']),
      message: serializer.fromJson<String>(json['message']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      isAcknowledged: serializer.fromJson<bool>(json['isAcknowledged']),
      severity: serializer.fromJson<int>(json['severity']),
      category: serializer.fromJson<String>(json['category']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'childId': serializer.toJson<String>(childId),
      'title': serializer.toJson<String>(title),
      'message': serializer.toJson<String>(message),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'isAcknowledged': serializer.toJson<bool>(isAcknowledged),
      'severity': serializer.toJson<int>(severity),
      'category': serializer.toJson<String>(category),
    };
  }

  Alert copyWith(
          {String? id,
          String? childId,
          String? title,
          String? message,
          DateTime? timestamp,
          bool? isAcknowledged,
          int? severity,
          String? category}) =>
      Alert(
        id: id ?? this.id,
        childId: childId ?? this.childId,
        title: title ?? this.title,
        message: message ?? this.message,
        timestamp: timestamp ?? this.timestamp,
        isAcknowledged: isAcknowledged ?? this.isAcknowledged,
        severity: severity ?? this.severity,
        category: category ?? this.category,
      );
  Alert copyWithCompanion(AlertsCompanion data) {
    return Alert(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      title: data.title.present ? data.title.value : this.title,
      message: data.message.present ? data.message.value : this.message,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      isAcknowledged: data.isAcknowledged.present
          ? data.isAcknowledged.value
          : this.isAcknowledged,
      severity: data.severity.present ? data.severity.value : this.severity,
      category: data.category.present ? data.category.value : this.category,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Alert(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('title: $title, ')
          ..write('message: $message, ')
          ..write('timestamp: $timestamp, ')
          ..write('isAcknowledged: $isAcknowledged, ')
          ..write('severity: $severity, ')
          ..write('category: $category')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, childId, title, message, timestamp,
      isAcknowledged, severity, category);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Alert &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.title == this.title &&
          other.message == this.message &&
          other.timestamp == this.timestamp &&
          other.isAcknowledged == this.isAcknowledged &&
          other.severity == this.severity &&
          other.category == this.category);
}

class AlertsCompanion extends UpdateCompanion<Alert> {
  final Value<String> id;
  final Value<String> childId;
  final Value<String> title;
  final Value<String> message;
  final Value<DateTime> timestamp;
  final Value<bool> isAcknowledged;
  final Value<int> severity;
  final Value<String> category;
  final Value<int> rowid;
  const AlertsCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.title = const Value.absent(),
    this.message = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.isAcknowledged = const Value.absent(),
    this.severity = const Value.absent(),
    this.category = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlertsCompanion.insert({
    required String id,
    required String childId,
    required String title,
    required String message,
    required DateTime timestamp,
    this.isAcknowledged = const Value.absent(),
    required int severity,
    this.category = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        childId = Value(childId),
        title = Value(title),
        message = Value(message),
        timestamp = Value(timestamp),
        severity = Value(severity);
  static Insertable<Alert> custom({
    Expression<String>? id,
    Expression<String>? childId,
    Expression<String>? title,
    Expression<String>? message,
    Expression<DateTime>? timestamp,
    Expression<bool>? isAcknowledged,
    Expression<int>? severity,
    Expression<String>? category,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (title != null) 'title': title,
      if (message != null) 'message': message,
      if (timestamp != null) 'timestamp': timestamp,
      if (isAcknowledged != null) 'is_acknowledged': isAcknowledged,
      if (severity != null) 'severity': severity,
      if (category != null) 'category': category,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlertsCompanion copyWith(
      {Value<String>? id,
      Value<String>? childId,
      Value<String>? title,
      Value<String>? message,
      Value<DateTime>? timestamp,
      Value<bool>? isAcknowledged,
      Value<int>? severity,
      Value<String>? category,
      Value<int>? rowid}) {
    return AlertsCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      severity: severity ?? this.severity,
      category: category ?? this.category,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<String>(childId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (isAcknowledged.present) {
      map['is_acknowledged'] = Variable<bool>(isAcknowledged.value);
    }
    if (severity.present) {
      map['severity'] = Variable<int>(severity.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlertsCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('title: $title, ')
          ..write('message: $message, ')
          ..write('timestamp: $timestamp, ')
          ..write('isAcknowledged: $isAcknowledged, ')
          ..write('severity: $severity, ')
          ..write('category: $category, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivityLogsTable extends ActivityLogs
    with TableInfo<$ActivityLogsTable, ActivityLogEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _childIdMeta =
      const VerificationMeta('childId');
  @override
  late final GeneratedColumn<String> childId = GeneratedColumn<String>(
      'child_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES children (id)'));
  static const VerificationMeta _screenTimeMeta =
      const VerificationMeta('screenTime');
  @override
  late final GeneratedColumn<int> screenTime = GeneratedColumn<int>(
      'screen_time', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _appNameMeta =
      const VerificationMeta('appName');
  @override
  late final GeneratedColumn<String> appName = GeneratedColumn<String>(
      'app_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, childId, screenTime, timestamp, category, appName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_logs';
  @override
  VerificationContext validateIntegrity(Insertable<ActivityLogEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('child_id')) {
      context.handle(_childIdMeta,
          childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta));
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('screen_time')) {
      context.handle(
          _screenTimeMeta,
          screenTime.isAcceptableOrUnknown(
              data['screen_time']!, _screenTimeMeta));
    } else if (isInserting) {
      context.missing(_screenTimeMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('app_name')) {
      context.handle(_appNameMeta,
          appName.isAcceptableOrUnknown(data['app_name']!, _appNameMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityLogEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityLogEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      childId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}child_id'])!,
      screenTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}screen_time'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      appName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}app_name']),
    );
  }

  @override
  $ActivityLogsTable createAlias(String alias) {
    return $ActivityLogsTable(attachedDatabase, alias);
  }
}

class ActivityLogEntry extends DataClass
    implements Insertable<ActivityLogEntry> {
  final String id;
  final String childId;
  final int screenTime;
  final DateTime timestamp;
  final String category;
  final String? appName;
  const ActivityLogEntry(
      {required this.id,
      required this.childId,
      required this.screenTime,
      required this.timestamp,
      required this.category,
      this.appName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['child_id'] = Variable<String>(childId);
    map['screen_time'] = Variable<int>(screenTime);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || appName != null) {
      map['app_name'] = Variable<String>(appName);
    }
    return map;
  }

  ActivityLogsCompanion toCompanion(bool nullToAbsent) {
    return ActivityLogsCompanion(
      id: Value(id),
      childId: Value(childId),
      screenTime: Value(screenTime),
      timestamp: Value(timestamp),
      category: Value(category),
      appName: appName == null && nullToAbsent
          ? const Value.absent()
          : Value(appName),
    );
  }

  factory ActivityLogEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityLogEntry(
      id: serializer.fromJson<String>(json['id']),
      childId: serializer.fromJson<String>(json['childId']),
      screenTime: serializer.fromJson<int>(json['screenTime']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      category: serializer.fromJson<String>(json['category']),
      appName: serializer.fromJson<String?>(json['appName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'childId': serializer.toJson<String>(childId),
      'screenTime': serializer.toJson<int>(screenTime),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'category': serializer.toJson<String>(category),
      'appName': serializer.toJson<String?>(appName),
    };
  }

  ActivityLogEntry copyWith(
          {String? id,
          String? childId,
          int? screenTime,
          DateTime? timestamp,
          String? category,
          Value<String?> appName = const Value.absent()}) =>
      ActivityLogEntry(
        id: id ?? this.id,
        childId: childId ?? this.childId,
        screenTime: screenTime ?? this.screenTime,
        timestamp: timestamp ?? this.timestamp,
        category: category ?? this.category,
        appName: appName.present ? appName.value : this.appName,
      );
  ActivityLogEntry copyWithCompanion(ActivityLogsCompanion data) {
    return ActivityLogEntry(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      screenTime:
          data.screenTime.present ? data.screenTime.value : this.screenTime,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      category: data.category.present ? data.category.value : this.category,
      appName: data.appName.present ? data.appName.value : this.appName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityLogEntry(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('screenTime: $screenTime, ')
          ..write('timestamp: $timestamp, ')
          ..write('category: $category, ')
          ..write('appName: $appName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, childId, screenTime, timestamp, category, appName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityLogEntry &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.screenTime == this.screenTime &&
          other.timestamp == this.timestamp &&
          other.category == this.category &&
          other.appName == this.appName);
}

class ActivityLogsCompanion extends UpdateCompanion<ActivityLogEntry> {
  final Value<String> id;
  final Value<String> childId;
  final Value<int> screenTime;
  final Value<DateTime> timestamp;
  final Value<String> category;
  final Value<String?> appName;
  final Value<int> rowid;
  const ActivityLogsCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.screenTime = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.category = const Value.absent(),
    this.appName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivityLogsCompanion.insert({
    required String id,
    required String childId,
    required int screenTime,
    required DateTime timestamp,
    required String category,
    this.appName = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        childId = Value(childId),
        screenTime = Value(screenTime),
        timestamp = Value(timestamp),
        category = Value(category);
  static Insertable<ActivityLogEntry> custom({
    Expression<String>? id,
    Expression<String>? childId,
    Expression<int>? screenTime,
    Expression<DateTime>? timestamp,
    Expression<String>? category,
    Expression<String>? appName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (screenTime != null) 'screen_time': screenTime,
      if (timestamp != null) 'timestamp': timestamp,
      if (category != null) 'category': category,
      if (appName != null) 'app_name': appName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivityLogsCompanion copyWith(
      {Value<String>? id,
      Value<String>? childId,
      Value<int>? screenTime,
      Value<DateTime>? timestamp,
      Value<String>? category,
      Value<String?>? appName,
      Value<int>? rowid}) {
    return ActivityLogsCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      screenTime: screenTime ?? this.screenTime,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      appName: appName ?? this.appName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<String>(childId.value);
    }
    if (screenTime.present) {
      map['screen_time'] = Variable<int>(screenTime.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (appName.present) {
      map['app_name'] = Variable<String>(appName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityLogsCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('screenTime: $screenTime, ')
          ..write('timestamp: $timestamp, ')
          ..write('category: $category, ')
          ..write('appName: $appName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BehavioralEventsTable extends BehavioralEvents
    with TableInfo<$BehavioralEventsTable, BehavioralEventData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BehavioralEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _childIdMeta =
      const VerificationMeta('childId');
  @override
  late final GeneratedColumn<String> childId = GeneratedColumn<String>(
      'child_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES children (id)'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _severityMeta =
      const VerificationMeta('severity');
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
      'severity', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, childId, type, severity, description, timestamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'behavioral_events';
  @override
  VerificationContext validateIntegrity(
      Insertable<BehavioralEventData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('child_id')) {
      context.handle(_childIdMeta,
          childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta));
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(_severityMeta,
          severity.isAcceptableOrUnknown(data['severity']!, _severityMeta));
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BehavioralEventData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BehavioralEventData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      childId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}child_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      severity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}severity'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
    );
  }

  @override
  $BehavioralEventsTable createAlias(String alias) {
    return $BehavioralEventsTable(attachedDatabase, alias);
  }
}

class BehavioralEventData extends DataClass
    implements Insertable<BehavioralEventData> {
  final String id;
  final String childId;
  final String type;
  final String severity;
  final String description;
  final DateTime timestamp;
  const BehavioralEventData(
      {required this.id,
      required this.childId,
      required this.type,
      required this.severity,
      required this.description,
      required this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['child_id'] = Variable<String>(childId);
    map['type'] = Variable<String>(type);
    map['severity'] = Variable<String>(severity);
    map['description'] = Variable<String>(description);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  BehavioralEventsCompanion toCompanion(bool nullToAbsent) {
    return BehavioralEventsCompanion(
      id: Value(id),
      childId: Value(childId),
      type: Value(type),
      severity: Value(severity),
      description: Value(description),
      timestamp: Value(timestamp),
    );
  }

  factory BehavioralEventData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BehavioralEventData(
      id: serializer.fromJson<String>(json['id']),
      childId: serializer.fromJson<String>(json['childId']),
      type: serializer.fromJson<String>(json['type']),
      severity: serializer.fromJson<String>(json['severity']),
      description: serializer.fromJson<String>(json['description']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'childId': serializer.toJson<String>(childId),
      'type': serializer.toJson<String>(type),
      'severity': serializer.toJson<String>(severity),
      'description': serializer.toJson<String>(description),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  BehavioralEventData copyWith(
          {String? id,
          String? childId,
          String? type,
          String? severity,
          String? description,
          DateTime? timestamp}) =>
      BehavioralEventData(
        id: id ?? this.id,
        childId: childId ?? this.childId,
        type: type ?? this.type,
        severity: severity ?? this.severity,
        description: description ?? this.description,
        timestamp: timestamp ?? this.timestamp,
      );
  BehavioralEventData copyWithCompanion(BehavioralEventsCompanion data) {
    return BehavioralEventData(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      type: data.type.present ? data.type.value : this.type,
      severity: data.severity.present ? data.severity.value : this.severity,
      description:
          data.description.present ? data.description.value : this.description,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BehavioralEventData(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('type: $type, ')
          ..write('severity: $severity, ')
          ..write('description: $description, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, childId, type, severity, description, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BehavioralEventData &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.type == this.type &&
          other.severity == this.severity &&
          other.description == this.description &&
          other.timestamp == this.timestamp);
}

class BehavioralEventsCompanion extends UpdateCompanion<BehavioralEventData> {
  final Value<String> id;
  final Value<String> childId;
  final Value<String> type;
  final Value<String> severity;
  final Value<String> description;
  final Value<DateTime> timestamp;
  final Value<int> rowid;
  const BehavioralEventsCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.type = const Value.absent(),
    this.severity = const Value.absent(),
    this.description = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BehavioralEventsCompanion.insert({
    required String id,
    required String childId,
    required String type,
    required String severity,
    required String description,
    required DateTime timestamp,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        childId = Value(childId),
        type = Value(type),
        severity = Value(severity),
        description = Value(description),
        timestamp = Value(timestamp);
  static Insertable<BehavioralEventData> custom({
    Expression<String>? id,
    Expression<String>? childId,
    Expression<String>? type,
    Expression<String>? severity,
    Expression<String>? description,
    Expression<DateTime>? timestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (type != null) 'type': type,
      if (severity != null) 'severity': severity,
      if (description != null) 'description': description,
      if (timestamp != null) 'timestamp': timestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BehavioralEventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? childId,
      Value<String>? type,
      Value<String>? severity,
      Value<String>? description,
      Value<DateTime>? timestamp,
      Value<int>? rowid}) {
    return BehavioralEventsCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<String>(childId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BehavioralEventsCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('type: $type, ')
          ..write('severity: $severity, ')
          ..write('description: $description, ')
          ..write('timestamp: $timestamp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ChildrenTable children = $ChildrenTable(this);
  late final $AlertsTable alerts = $AlertsTable(this);
  late final $ActivityLogsTable activityLogs = $ActivityLogsTable(this);
  late final $BehavioralEventsTable behavioralEvents =
      $BehavioralEventsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [children, alerts, activityLogs, behavioralEvents];
}

typedef $$ChildrenTableCreateCompanionBuilder = ChildrenCompanion Function({
  required String id,
  required String name,
  Value<int> riskLevel,
  Value<DateTime?> lastActive,
  Value<int> rowid,
});
typedef $$ChildrenTableUpdateCompanionBuilder = ChildrenCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> riskLevel,
  Value<DateTime?> lastActive,
  Value<int> rowid,
});

final class $$ChildrenTableReferences
    extends BaseReferences<_$AppDatabase, $ChildrenTable, Child> {
  $$ChildrenTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AlertsTable, List<Alert>> _alertsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.alerts,
          aliasName: $_aliasNameGenerator(db.children.id, db.alerts.childId));

  $$AlertsTableProcessedTableManager get alertsRefs {
    final manager = $$AlertsTableTableManager($_db, $_db.alerts)
        .filter((f) => f.childId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_alertsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ActivityLogsTable, List<ActivityLogEntry>>
      _activityLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.activityLogs,
          aliasName:
              $_aliasNameGenerator(db.children.id, db.activityLogs.childId));

  $$ActivityLogsTableProcessedTableManager get activityLogsRefs {
    final manager = $$ActivityLogsTableTableManager($_db, $_db.activityLogs)
        .filter((f) => f.childId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_activityLogsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$BehavioralEventsTable, List<BehavioralEventData>>
      _behavioralEventsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.behavioralEvents,
              aliasName: $_aliasNameGenerator(
                  db.children.id, db.behavioralEvents.childId));

  $$BehavioralEventsTableProcessedTableManager get behavioralEventsRefs {
    final manager =
        $$BehavioralEventsTableTableManager($_db, $_db.behavioralEvents)
            .filter((f) => f.childId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_behavioralEventsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ChildrenTableFilterComposer
    extends Composer<_$AppDatabase, $ChildrenTable> {
  $$ChildrenTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get riskLevel => $composableBuilder(
      column: $table.riskLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastActive => $composableBuilder(
      column: $table.lastActive, builder: (column) => ColumnFilters(column));

  Expression<bool> alertsRefs(
      Expression<bool> Function($$AlertsTableFilterComposer f) f) {
    final $$AlertsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.alerts,
        getReferencedColumn: (t) => t.childId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AlertsTableFilterComposer(
              $db: $db,
              $table: $db.alerts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> activityLogsRefs(
      Expression<bool> Function($$ActivityLogsTableFilterComposer f) f) {
    final $$ActivityLogsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.activityLogs,
        getReferencedColumn: (t) => t.childId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ActivityLogsTableFilterComposer(
              $db: $db,
              $table: $db.activityLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> behavioralEventsRefs(
      Expression<bool> Function($$BehavioralEventsTableFilterComposer f) f) {
    final $$BehavioralEventsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.behavioralEvents,
        getReferencedColumn: (t) => t.childId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BehavioralEventsTableFilterComposer(
              $db: $db,
              $table: $db.behavioralEvents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ChildrenTableOrderingComposer
    extends Composer<_$AppDatabase, $ChildrenTable> {
  $$ChildrenTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get riskLevel => $composableBuilder(
      column: $table.riskLevel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastActive => $composableBuilder(
      column: $table.lastActive, builder: (column) => ColumnOrderings(column));
}

class $$ChildrenTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChildrenTable> {
  $$ChildrenTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get riskLevel =>
      $composableBuilder(column: $table.riskLevel, builder: (column) => column);

  GeneratedColumn<DateTime> get lastActive => $composableBuilder(
      column: $table.lastActive, builder: (column) => column);

  Expression<T> alertsRefs<T extends Object>(
      Expression<T> Function($$AlertsTableAnnotationComposer a) f) {
    final $$AlertsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.alerts,
        getReferencedColumn: (t) => t.childId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AlertsTableAnnotationComposer(
              $db: $db,
              $table: $db.alerts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> activityLogsRefs<T extends Object>(
      Expression<T> Function($$ActivityLogsTableAnnotationComposer a) f) {
    final $$ActivityLogsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.activityLogs,
        getReferencedColumn: (t) => t.childId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ActivityLogsTableAnnotationComposer(
              $db: $db,
              $table: $db.activityLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> behavioralEventsRefs<T extends Object>(
      Expression<T> Function($$BehavioralEventsTableAnnotationComposer a) f) {
    final $$BehavioralEventsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.behavioralEvents,
        getReferencedColumn: (t) => t.childId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BehavioralEventsTableAnnotationComposer(
              $db: $db,
              $table: $db.behavioralEvents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ChildrenTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChildrenTable,
    Child,
    $$ChildrenTableFilterComposer,
    $$ChildrenTableOrderingComposer,
    $$ChildrenTableAnnotationComposer,
    $$ChildrenTableCreateCompanionBuilder,
    $$ChildrenTableUpdateCompanionBuilder,
    (Child, $$ChildrenTableReferences),
    Child,
    PrefetchHooks Function(
        {bool alertsRefs, bool activityLogsRefs, bool behavioralEventsRefs})> {
  $$ChildrenTableTableManager(_$AppDatabase db, $ChildrenTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChildrenTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChildrenTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChildrenTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> riskLevel = const Value.absent(),
            Value<DateTime?> lastActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChildrenCompanion(
            id: id,
            name: name,
            riskLevel: riskLevel,
            lastActive: lastActive,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<int> riskLevel = const Value.absent(),
            Value<DateTime?> lastActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChildrenCompanion.insert(
            id: id,
            name: name,
            riskLevel: riskLevel,
            lastActive: lastActive,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ChildrenTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {alertsRefs = false,
              activityLogsRefs = false,
              behavioralEventsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (alertsRefs) db.alerts,
                if (activityLogsRefs) db.activityLogs,
                if (behavioralEventsRefs) db.behavioralEvents
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (alertsRefs)
                    await $_getPrefetchedData<Child, $ChildrenTable, Alert>(
                        currentTable: table,
                        referencedTable:
                            $$ChildrenTableReferences._alertsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ChildrenTableReferences(db, table, p0).alertsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.childId == item.id),
                        typedResults: items),
                  if (activityLogsRefs)
                    await $_getPrefetchedData<Child, $ChildrenTable,
                            ActivityLogEntry>(
                        currentTable: table,
                        referencedTable: $$ChildrenTableReferences
                            ._activityLogsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ChildrenTableReferences(db, table, p0)
                                .activityLogsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.childId == item.id),
                        typedResults: items),
                  if (behavioralEventsRefs)
                    await $_getPrefetchedData<Child, $ChildrenTable,
                            BehavioralEventData>(
                        currentTable: table,
                        referencedTable: $$ChildrenTableReferences
                            ._behavioralEventsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ChildrenTableReferences(db, table, p0)
                                .behavioralEventsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.childId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ChildrenTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChildrenTable,
    Child,
    $$ChildrenTableFilterComposer,
    $$ChildrenTableOrderingComposer,
    $$ChildrenTableAnnotationComposer,
    $$ChildrenTableCreateCompanionBuilder,
    $$ChildrenTableUpdateCompanionBuilder,
    (Child, $$ChildrenTableReferences),
    Child,
    PrefetchHooks Function(
        {bool alertsRefs, bool activityLogsRefs, bool behavioralEventsRefs})>;
typedef $$AlertsTableCreateCompanionBuilder = AlertsCompanion Function({
  required String id,
  required String childId,
  required String title,
  required String message,
  required DateTime timestamp,
  Value<bool> isAcknowledged,
  required int severity,
  Value<String> category,
  Value<int> rowid,
});
typedef $$AlertsTableUpdateCompanionBuilder = AlertsCompanion Function({
  Value<String> id,
  Value<String> childId,
  Value<String> title,
  Value<String> message,
  Value<DateTime> timestamp,
  Value<bool> isAcknowledged,
  Value<int> severity,
  Value<String> category,
  Value<int> rowid,
});

final class $$AlertsTableReferences
    extends BaseReferences<_$AppDatabase, $AlertsTable, Alert> {
  $$AlertsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChildrenTable _childIdTable(_$AppDatabase db) => db.children
      .createAlias($_aliasNameGenerator(db.alerts.childId, db.children.id));

  $$ChildrenTableProcessedTableManager get childId {
    final $_column = $_itemColumn<String>('child_id')!;

    final manager = $$ChildrenTableTableManager($_db, $_db.children)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AlertsTableFilterComposer
    extends Composer<_$AppDatabase, $AlertsTable> {
  $$AlertsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isAcknowledged => $composableBuilder(
      column: $table.isAcknowledged,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get severity => $composableBuilder(
      column: $table.severity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  $$ChildrenTableFilterComposer get childId {
    final $$ChildrenTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childId,
        referencedTable: $db.children,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChildrenTableFilterComposer(
              $db: $db,
              $table: $db.children,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AlertsTableOrderingComposer
    extends Composer<_$AppDatabase, $AlertsTable> {
  $$AlertsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAcknowledged => $composableBuilder(
      column: $table.isAcknowledged,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get severity => $composableBuilder(
      column: $table.severity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  $$ChildrenTableOrderingComposer get childId {
    final $$ChildrenTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childId,
        referencedTable: $db.children,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChildrenTableOrderingComposer(
              $db: $db,
              $table: $db.children,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AlertsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlertsTable> {
  $$AlertsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<bool> get isAcknowledged => $composableBuilder(
      column: $table.isAcknowledged, builder: (column) => column);

  GeneratedColumn<int> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  $$ChildrenTableAnnotationComposer get childId {
    final $$ChildrenTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childId,
        referencedTable: $db.children,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChildrenTableAnnotationComposer(
              $db: $db,
              $table: $db.children,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AlertsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AlertsTable,
    Alert,
    $$AlertsTableFilterComposer,
    $$AlertsTableOrderingComposer,
    $$AlertsTableAnnotationComposer,
    $$AlertsTableCreateCompanionBuilder,
    $$AlertsTableUpdateCompanionBuilder,
    (Alert, $$AlertsTableReferences),
    Alert,
    PrefetchHooks Function({bool childId})> {
  $$AlertsTableTableManager(_$AppDatabase db, $AlertsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlertsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlertsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlertsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> childId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> message = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<bool> isAcknowledged = const Value.absent(),
            Value<int> severity = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AlertsCompanion(
            id: id,
            childId: childId,
            title: title,
            message: message,
            timestamp: timestamp,
            isAcknowledged: isAcknowledged,
            severity: severity,
            category: category,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String childId,
            required String title,
            required String message,
            required DateTime timestamp,
            Value<bool> isAcknowledged = const Value.absent(),
            required int severity,
            Value<String> category = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AlertsCompanion.insert(
            id: id,
            childId: childId,
            title: title,
            message: message,
            timestamp: timestamp,
            isAcknowledged: isAcknowledged,
            severity: severity,
            category: category,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$AlertsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({childId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (childId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.childId,
                    referencedTable: $$AlertsTableReferences._childIdTable(db),
                    referencedColumn:
                        $$AlertsTableReferences._childIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AlertsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AlertsTable,
    Alert,
    $$AlertsTableFilterComposer,
    $$AlertsTableOrderingComposer,
    $$AlertsTableAnnotationComposer,
    $$AlertsTableCreateCompanionBuilder,
    $$AlertsTableUpdateCompanionBuilder,
    (Alert, $$AlertsTableReferences),
    Alert,
    PrefetchHooks Function({bool childId})>;
typedef $$ActivityLogsTableCreateCompanionBuilder = ActivityLogsCompanion
    Function({
  required String id,
  required String childId,
  required int screenTime,
  required DateTime timestamp,
  required String category,
  Value<String?> appName,
  Value<int> rowid,
});
typedef $$ActivityLogsTableUpdateCompanionBuilder = ActivityLogsCompanion
    Function({
  Value<String> id,
  Value<String> childId,
  Value<int> screenTime,
  Value<DateTime> timestamp,
  Value<String> category,
  Value<String?> appName,
  Value<int> rowid,
});

final class $$ActivityLogsTableReferences extends BaseReferences<_$AppDatabase,
    $ActivityLogsTable, ActivityLogEntry> {
  $$ActivityLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChildrenTable _childIdTable(_$AppDatabase db) =>
      db.children.createAlias(
          $_aliasNameGenerator(db.activityLogs.childId, db.children.id));

  $$ChildrenTableProcessedTableManager get childId {
    final $_column = $_itemColumn<String>('child_id')!;

    final manager = $$ChildrenTableTableManager($_db, $_db.children)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ActivityLogsTableFilterComposer
    extends Composer<_$AppDatabase, $ActivityLogsTable> {
  $$ActivityLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get screenTime => $composableBuilder(
      column: $table.screenTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get appName => $composableBuilder(
      column: $table.appName, builder: (column) => ColumnFilters(column));

  $$ChildrenTableFilterComposer get childId {
    final $$ChildrenTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childId,
        referencedTable: $db.children,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChildrenTableFilterComposer(
              $db: $db,
              $table: $db.children,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ActivityLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivityLogsTable> {
  $$ActivityLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get screenTime => $composableBuilder(
      column: $table.screenTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get appName => $composableBuilder(
      column: $table.appName, builder: (column) => ColumnOrderings(column));

  $$ChildrenTableOrderingComposer get childId {
    final $$ChildrenTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childId,
        referencedTable: $db.children,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChildrenTableOrderingComposer(
              $db: $db,
              $table: $db.children,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ActivityLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivityLogsTable> {
  $$ActivityLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get screenTime => $composableBuilder(
      column: $table.screenTime, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get appName =>
      $composableBuilder(column: $table.appName, builder: (column) => column);

  $$ChildrenTableAnnotationComposer get childId {
    final $$ChildrenTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childId,
        referencedTable: $db.children,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChildrenTableAnnotationComposer(
              $db: $db,
              $table: $db.children,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ActivityLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ActivityLogsTable,
    ActivityLogEntry,
    $$ActivityLogsTableFilterComposer,
    $$ActivityLogsTableOrderingComposer,
    $$ActivityLogsTableAnnotationComposer,
    $$ActivityLogsTableCreateCompanionBuilder,
    $$ActivityLogsTableUpdateCompanionBuilder,
    (ActivityLogEntry, $$ActivityLogsTableReferences),
    ActivityLogEntry,
    PrefetchHooks Function({bool childId})> {
  $$ActivityLogsTableTableManager(_$AppDatabase db, $ActivityLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivityLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> childId = const Value.absent(),
            Value<int> screenTime = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String?> appName = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ActivityLogsCompanion(
            id: id,
            childId: childId,
            screenTime: screenTime,
            timestamp: timestamp,
            category: category,
            appName: appName,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String childId,
            required int screenTime,
            required DateTime timestamp,
            required String category,
            Value<String?> appName = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ActivityLogsCompanion.insert(
            id: id,
            childId: childId,
            screenTime: screenTime,
            timestamp: timestamp,
            category: category,
            appName: appName,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ActivityLogsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({childId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (childId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.childId,
                    referencedTable:
                        $$ActivityLogsTableReferences._childIdTable(db),
                    referencedColumn:
                        $$ActivityLogsTableReferences._childIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ActivityLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ActivityLogsTable,
    ActivityLogEntry,
    $$ActivityLogsTableFilterComposer,
    $$ActivityLogsTableOrderingComposer,
    $$ActivityLogsTableAnnotationComposer,
    $$ActivityLogsTableCreateCompanionBuilder,
    $$ActivityLogsTableUpdateCompanionBuilder,
    (ActivityLogEntry, $$ActivityLogsTableReferences),
    ActivityLogEntry,
    PrefetchHooks Function({bool childId})>;
typedef $$BehavioralEventsTableCreateCompanionBuilder
    = BehavioralEventsCompanion Function({
  required String id,
  required String childId,
  required String type,
  required String severity,
  required String description,
  required DateTime timestamp,
  Value<int> rowid,
});
typedef $$BehavioralEventsTableUpdateCompanionBuilder
    = BehavioralEventsCompanion Function({
  Value<String> id,
  Value<String> childId,
  Value<String> type,
  Value<String> severity,
  Value<String> description,
  Value<DateTime> timestamp,
  Value<int> rowid,
});

final class $$BehavioralEventsTableReferences extends BaseReferences<
    _$AppDatabase, $BehavioralEventsTable, BehavioralEventData> {
  $$BehavioralEventsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ChildrenTable _childIdTable(_$AppDatabase db) =>
      db.children.createAlias(
          $_aliasNameGenerator(db.behavioralEvents.childId, db.children.id));

  $$ChildrenTableProcessedTableManager get childId {
    final $_column = $_itemColumn<String>('child_id')!;

    final manager = $$ChildrenTableTableManager($_db, $_db.children)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$BehavioralEventsTableFilterComposer
    extends Composer<_$AppDatabase, $BehavioralEventsTable> {
  $$BehavioralEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get severity => $composableBuilder(
      column: $table.severity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  $$ChildrenTableFilterComposer get childId {
    final $$ChildrenTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childId,
        referencedTable: $db.children,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChildrenTableFilterComposer(
              $db: $db,
              $table: $db.children,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BehavioralEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $BehavioralEventsTable> {
  $$BehavioralEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get severity => $composableBuilder(
      column: $table.severity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  $$ChildrenTableOrderingComposer get childId {
    final $$ChildrenTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childId,
        referencedTable: $db.children,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChildrenTableOrderingComposer(
              $db: $db,
              $table: $db.children,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BehavioralEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BehavioralEventsTable> {
  $$BehavioralEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  $$ChildrenTableAnnotationComposer get childId {
    final $$ChildrenTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childId,
        referencedTable: $db.children,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChildrenTableAnnotationComposer(
              $db: $db,
              $table: $db.children,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BehavioralEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BehavioralEventsTable,
    BehavioralEventData,
    $$BehavioralEventsTableFilterComposer,
    $$BehavioralEventsTableOrderingComposer,
    $$BehavioralEventsTableAnnotationComposer,
    $$BehavioralEventsTableCreateCompanionBuilder,
    $$BehavioralEventsTableUpdateCompanionBuilder,
    (BehavioralEventData, $$BehavioralEventsTableReferences),
    BehavioralEventData,
    PrefetchHooks Function({bool childId})> {
  $$BehavioralEventsTableTableManager(
      _$AppDatabase db, $BehavioralEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BehavioralEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BehavioralEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BehavioralEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> childId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> severity = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BehavioralEventsCompanion(
            id: id,
            childId: childId,
            type: type,
            severity: severity,
            description: description,
            timestamp: timestamp,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String childId,
            required String type,
            required String severity,
            required String description,
            required DateTime timestamp,
            Value<int> rowid = const Value.absent(),
          }) =>
              BehavioralEventsCompanion.insert(
            id: id,
            childId: childId,
            type: type,
            severity: severity,
            description: description,
            timestamp: timestamp,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BehavioralEventsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({childId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (childId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.childId,
                    referencedTable:
                        $$BehavioralEventsTableReferences._childIdTable(db),
                    referencedColumn:
                        $$BehavioralEventsTableReferences._childIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$BehavioralEventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BehavioralEventsTable,
    BehavioralEventData,
    $$BehavioralEventsTableFilterComposer,
    $$BehavioralEventsTableOrderingComposer,
    $$BehavioralEventsTableAnnotationComposer,
    $$BehavioralEventsTableCreateCompanionBuilder,
    $$BehavioralEventsTableUpdateCompanionBuilder,
    (BehavioralEventData, $$BehavioralEventsTableReferences),
    BehavioralEventData,
    PrefetchHooks Function({bool childId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ChildrenTableTableManager get children =>
      $$ChildrenTableTableManager(_db, _db.children);
  $$AlertsTableTableManager get alerts =>
      $$AlertsTableTableManager(_db, _db.alerts);
  $$ActivityLogsTableTableManager get activityLogs =>
      $$ActivityLogsTableTableManager(_db, _db.activityLogs);
  $$BehavioralEventsTableTableManager get behavioralEvents =>
      $$BehavioralEventsTableTableManager(_db, _db.behavioralEvents);
}
