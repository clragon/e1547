// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:drift/src/runtime/api/runtime_api.dart' as i1;
import 'package:e1547/history/data/database.drift.dart' as i2;
import 'package:drift/internal/modular.dart' as i3;
import 'package:e1547/identity/data/database.drift.dart' as i4;
import 'package:e1547/history/data/history.dart' as i5;
import 'package:e1547/history/data/database.dart' as i6;
import 'package:e1547/interface/data/sql.dart' as i7;

mixin $HistoriesDaoMixin on i0.DatabaseAccessor<i1.GeneratedDatabase> {
  i2.$HistoriesTableTable get historiesTable =>
      i3.ReadDatabaseContainer(attachedDatabase).resultSet('histories_table');
  i4.$IdentitiesTableTable get identitiesTable =>
      i3.ReadDatabaseContainer(attachedDatabase).resultSet('identities_table');
  i2.$HistoriesIdentitiesTableTable get historiesIdentitiesTable =>
      i3.ReadDatabaseContainer(attachedDatabase)
          .resultSet('histories_identities_table');
}

class $HistoriesTableTable extends i6.HistoriesTable
    with i0.TableInfo<$HistoriesTableTable, i5.History> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoriesTableTable(this.attachedDatabase, [this._alias]);
  static const i0.VerificationMeta _idMeta = const i0.VerificationMeta('id');
  @override
  late final i0.GeneratedColumn<int> id = i0.GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: i0.DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          i0.GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const i0.VerificationMeta _visitedAtMeta =
      const i0.VerificationMeta('visitedAt');
  @override
  late final i0.GeneratedColumn<DateTime> visitedAt =
      i0.GeneratedColumn<DateTime>('visited_at', aliasedName, false,
          type: i0.DriftSqlType.dateTime, requiredDuringInsert: true);
  static const i0.VerificationMeta _linkMeta =
      const i0.VerificationMeta('link');
  @override
  late final i0.GeneratedColumn<String> link = i0.GeneratedColumn<String>(
      'link', aliasedName, false,
      type: i0.DriftSqlType.string, requiredDuringInsert: true);
  static const i0.VerificationMeta _thumbnailsMeta =
      const i0.VerificationMeta('thumbnails');
  @override
  late final i0.GeneratedColumnWithTypeConverter<List<String>, String>
      thumbnails = i0.GeneratedColumn<String>('thumbnails', aliasedName, false,
              type: i0.DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<List<String>>(
              i2.$HistoriesTableTable.$converterthumbnails);
  static const i0.VerificationMeta _titleMeta =
      const i0.VerificationMeta('title');
  @override
  late final i0.GeneratedColumn<String> title = i0.GeneratedColumn<String>(
      'title', aliasedName, true,
      type: i0.DriftSqlType.string, requiredDuringInsert: false);
  static const i0.VerificationMeta _subtitleMeta =
      const i0.VerificationMeta('subtitle');
  @override
  late final i0.GeneratedColumn<String> subtitle = i0.GeneratedColumn<String>(
      'subtitle', aliasedName, true,
      type: i0.DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<i0.GeneratedColumn> get $columns =>
      [id, visitedAt, link, thumbnails, title, subtitle];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'histories_table';
  @override
  i0.VerificationContext validateIntegrity(i0.Insertable<i5.History> instance,
      {bool isInserting = false}) {
    final context = i0.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('visited_at')) {
      context.handle(_visitedAtMeta,
          visitedAt.isAcceptableOrUnknown(data['visited_at']!, _visitedAtMeta));
    } else if (isInserting) {
      context.missing(_visitedAtMeta);
    }
    if (data.containsKey('link')) {
      context.handle(
          _linkMeta, link.isAcceptableOrUnknown(data['link']!, _linkMeta));
    } else if (isInserting) {
      context.missing(_linkMeta);
    }
    context.handle(_thumbnailsMeta, const i0.VerificationResult.success());
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('subtitle')) {
      context.handle(_subtitleMeta,
          subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta));
    }
    return context;
  }

  @override
  Set<i0.GeneratedColumn> get $primaryKey => {id};
  @override
  i5.History map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i5.History(
      id: attachedDatabase.typeMapping
          .read(i0.DriftSqlType.int, data['${effectivePrefix}id'])!,
      visitedAt: attachedDatabase.typeMapping.read(
          i0.DriftSqlType.dateTime, data['${effectivePrefix}visited_at'])!,
      link: attachedDatabase.typeMapping
          .read(i0.DriftSqlType.string, data['${effectivePrefix}link'])!,
      thumbnails: i2.$HistoriesTableTable.$converterthumbnails.fromSql(
          attachedDatabase.typeMapping.read(
              i0.DriftSqlType.string, data['${effectivePrefix}thumbnails'])!),
      title: attachedDatabase.typeMapping
          .read(i0.DriftSqlType.string, data['${effectivePrefix}title']),
      subtitle: attachedDatabase.typeMapping
          .read(i0.DriftSqlType.string, data['${effectivePrefix}subtitle']),
    );
  }

  @override
  $HistoriesTableTable createAlias(String alias) {
    return $HistoriesTableTable(attachedDatabase, alias);
  }

  static i0.TypeConverter<List<String>, String> $converterthumbnails =
      i7.JsonSqlConverter.list<String>();
}

class HistoryCompanion extends i0.UpdateCompanion<i5.History> {
  final i0.Value<int> id;
  final i0.Value<DateTime> visitedAt;
  final i0.Value<String> link;
  final i0.Value<List<String>> thumbnails;
  final i0.Value<String?> title;
  final i0.Value<String?> subtitle;
  const HistoryCompanion({
    this.id = const i0.Value.absent(),
    this.visitedAt = const i0.Value.absent(),
    this.link = const i0.Value.absent(),
    this.thumbnails = const i0.Value.absent(),
    this.title = const i0.Value.absent(),
    this.subtitle = const i0.Value.absent(),
  });
  HistoryCompanion.insert({
    this.id = const i0.Value.absent(),
    required DateTime visitedAt,
    required String link,
    required List<String> thumbnails,
    this.title = const i0.Value.absent(),
    this.subtitle = const i0.Value.absent(),
  })  : visitedAt = i0.Value(visitedAt),
        link = i0.Value(link),
        thumbnails = i0.Value(thumbnails);
  static i0.Insertable<i5.History> custom({
    i0.Expression<int>? id,
    i0.Expression<DateTime>? visitedAt,
    i0.Expression<String>? link,
    i0.Expression<String>? thumbnails,
    i0.Expression<String>? title,
    i0.Expression<String>? subtitle,
  }) {
    return i0.RawValuesInsertable({
      if (id != null) 'id': id,
      if (visitedAt != null) 'visited_at': visitedAt,
      if (link != null) 'link': link,
      if (thumbnails != null) 'thumbnails': thumbnails,
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
    });
  }

  i2.HistoryCompanion copyWith(
      {i0.Value<int>? id,
      i0.Value<DateTime>? visitedAt,
      i0.Value<String>? link,
      i0.Value<List<String>>? thumbnails,
      i0.Value<String?>? title,
      i0.Value<String?>? subtitle}) {
    return i2.HistoryCompanion(
      id: id ?? this.id,
      visitedAt: visitedAt ?? this.visitedAt,
      link: link ?? this.link,
      thumbnails: thumbnails ?? this.thumbnails,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (id.present) {
      map['id'] = i0.Variable<int>(id.value);
    }
    if (visitedAt.present) {
      map['visited_at'] = i0.Variable<DateTime>(visitedAt.value);
    }
    if (link.present) {
      map['link'] = i0.Variable<String>(link.value);
    }
    if (thumbnails.present) {
      map['thumbnails'] = i0.Variable<String>(
          i2.$HistoriesTableTable.$converterthumbnails.toSql(thumbnails.value));
    }
    if (title.present) {
      map['title'] = i0.Variable<String>(title.value);
    }
    if (subtitle.present) {
      map['subtitle'] = i0.Variable<String>(subtitle.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryCompanion(')
          ..write('id: $id, ')
          ..write('visitedAt: $visitedAt, ')
          ..write('link: $link, ')
          ..write('thumbnails: $thumbnails, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle')
          ..write(')'))
        .toString();
  }
}

class _$HistoryInsertable implements i0.Insertable<i5.History> {
  i5.History _object;
  _$HistoryInsertable(this._object);
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    return i2.HistoryCompanion(
      id: i0.Value(_object.id),
      visitedAt: i0.Value(_object.visitedAt),
      link: i0.Value(_object.link),
      thumbnails: i0.Value(_object.thumbnails),
      title: i0.Value(_object.title),
      subtitle: i0.Value(_object.subtitle),
    ).toColumns(false);
  }
}

extension HistoryToInsertable on i5.History {
  _$HistoryInsertable toInsertable() {
    return _$HistoryInsertable(this);
  }
}

class $HistoriesIdentitiesTableTable extends i6.HistoriesIdentitiesTable
    with i0.TableInfo<$HistoriesIdentitiesTableTable, i2.HistoryIdentity> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoriesIdentitiesTableTable(this.attachedDatabase, [this._alias]);
  static const i0.VerificationMeta _identityMeta =
      const i0.VerificationMeta('identity');
  @override
  late final i0.GeneratedColumn<int> identity = i0.GeneratedColumn<int>(
      'identity', aliasedName, false,
      type: i0.DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: i0.GeneratedColumn.constraintIsAlways(
          'REFERENCES identities_table (id) ON UPDATE NO ACTION ON DELETE NO ACTION'));
  static const i0.VerificationMeta _historyMeta =
      const i0.VerificationMeta('history');
  @override
  late final i0.GeneratedColumn<int> history = i0.GeneratedColumn<int>(
      'history', aliasedName, false,
      type: i0.DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: i0.GeneratedColumn.constraintIsAlways(
          'REFERENCES histories_table (id) ON UPDATE CASCADE ON DELETE CASCADE'));
  @override
  List<i0.GeneratedColumn> get $columns => [identity, history];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'histories_identities_table';
  @override
  i0.VerificationContext validateIntegrity(
      i0.Insertable<i2.HistoryIdentity> instance,
      {bool isInserting = false}) {
    final context = i0.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('identity')) {
      context.handle(_identityMeta,
          identity.isAcceptableOrUnknown(data['identity']!, _identityMeta));
    } else if (isInserting) {
      context.missing(_identityMeta);
    }
    if (data.containsKey('history')) {
      context.handle(_historyMeta,
          history.isAcceptableOrUnknown(data['history']!, _historyMeta));
    } else if (isInserting) {
      context.missing(_historyMeta);
    }
    return context;
  }

  @override
  Set<i0.GeneratedColumn> get $primaryKey => {identity, history};
  @override
  i2.HistoryIdentity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i2.HistoryIdentity(
      identity: attachedDatabase.typeMapping
          .read(i0.DriftSqlType.int, data['${effectivePrefix}identity'])!,
      history: attachedDatabase.typeMapping
          .read(i0.DriftSqlType.int, data['${effectivePrefix}history'])!,
    );
  }

  @override
  $HistoriesIdentitiesTableTable createAlias(String alias) {
    return $HistoriesIdentitiesTableTable(attachedDatabase, alias);
  }
}

class HistoryIdentity extends i0.DataClass
    implements i0.Insertable<i2.HistoryIdentity> {
  final int identity;
  final int history;
  const HistoryIdentity({required this.identity, required this.history});
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['identity'] = i0.Variable<int>(identity);
    map['history'] = i0.Variable<int>(history);
    return map;
  }

  i2.HistoryIdentityCompanion toCompanion(bool nullToAbsent) {
    return i2.HistoryIdentityCompanion(
      identity: i0.Value(identity),
      history: i0.Value(history),
    );
  }

  factory HistoryIdentity.fromJson(Map<String, dynamic> json,
      {i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return HistoryIdentity(
      identity: serializer.fromJson<int>(json['identity']),
      history: serializer.fromJson<int>(json['history']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'identity': serializer.toJson<int>(identity),
      'history': serializer.toJson<int>(history),
    };
  }

  i2.HistoryIdentity copyWith({int? identity, int? history}) =>
      i2.HistoryIdentity(
        identity: identity ?? this.identity,
        history: history ?? this.history,
      );
  @override
  String toString() {
    return (StringBuffer('HistoryIdentity(')
          ..write('identity: $identity, ')
          ..write('history: $history')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(identity, history);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i2.HistoryIdentity &&
          other.identity == this.identity &&
          other.history == this.history);
}

class HistoryIdentityCompanion extends i0.UpdateCompanion<i2.HistoryIdentity> {
  final i0.Value<int> identity;
  final i0.Value<int> history;
  final i0.Value<int> rowid;
  const HistoryIdentityCompanion({
    this.identity = const i0.Value.absent(),
    this.history = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  HistoryIdentityCompanion.insert({
    required int identity,
    required int history,
    this.rowid = const i0.Value.absent(),
  })  : identity = i0.Value(identity),
        history = i0.Value(history);
  static i0.Insertable<i2.HistoryIdentity> custom({
    i0.Expression<int>? identity,
    i0.Expression<int>? history,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (identity != null) 'identity': identity,
      if (history != null) 'history': history,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i2.HistoryIdentityCompanion copyWith(
      {i0.Value<int>? identity, i0.Value<int>? history, i0.Value<int>? rowid}) {
    return i2.HistoryIdentityCompanion(
      identity: identity ?? this.identity,
      history: history ?? this.history,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (identity.present) {
      map['identity'] = i0.Variable<int>(identity.value);
    }
    if (history.present) {
      map['history'] = i0.Variable<int>(history.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryIdentityCompanion(')
          ..write('identity: $identity, ')
          ..write('history: $history, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}
