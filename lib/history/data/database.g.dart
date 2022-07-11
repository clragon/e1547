// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: type=lint
class HistoryCompanion extends UpdateCompanion<History> {
  final Value<int> id;
  final Value<String> host;
  final Value<DateTime> visitedAt;
  final Value<String> link;
  final Value<List<String>> thumbnails;
  final Value<String?> title;
  final Value<String?> subtitle;
  const HistoryCompanion({
    this.id = const Value.absent(),
    this.host = const Value.absent(),
    this.visitedAt = const Value.absent(),
    this.link = const Value.absent(),
    this.thumbnails = const Value.absent(),
    this.title = const Value.absent(),
    this.subtitle = const Value.absent(),
  });
  HistoryCompanion.insert({
    this.id = const Value.absent(),
    required String host,
    required DateTime visitedAt,
    required String link,
    required List<String> thumbnails,
    this.title = const Value.absent(),
    this.subtitle = const Value.absent(),
  })  : host = Value(host),
        visitedAt = Value(visitedAt),
        link = Value(link),
        thumbnails = Value(thumbnails);
  static Insertable<History> custom({
    Expression<int>? id,
    Expression<String>? host,
    Expression<DateTime>? visitedAt,
    Expression<String>? link,
    Expression<List<String>>? thumbnails,
    Expression<String?>? title,
    Expression<String?>? subtitle,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (host != null) 'host': host,
      if (visitedAt != null) 'visited_at': visitedAt,
      if (link != null) 'link': link,
      if (thumbnails != null) 'thumbnails': thumbnails,
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
    });
  }

  HistoryCompanion copyWith(
      {Value<int>? id,
      Value<String>? host,
      Value<DateTime>? visitedAt,
      Value<String>? link,
      Value<List<String>>? thumbnails,
      Value<String?>? title,
      Value<String?>? subtitle}) {
    return HistoryCompanion(
      id: id ?? this.id,
      host: host ?? this.host,
      visitedAt: visitedAt ?? this.visitedAt,
      link: link ?? this.link,
      thumbnails: thumbnails ?? this.thumbnails,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (host.present) {
      map['host'] = Variable<String>(host.value);
    }
    if (visitedAt.present) {
      map['visited_at'] = Variable<DateTime>(visitedAt.value);
    }
    if (link.present) {
      map['link'] = Variable<String>(link.value);
    }
    if (thumbnails.present) {
      final converter = $HistoriesTableTable.$converter0;
      map['thumbnails'] =
          Variable<String>(converter.mapToSql(thumbnails.value)!);
    }
    if (title.present) {
      map['title'] = Variable<String?>(title.value);
    }
    if (subtitle.present) {
      map['subtitle'] = Variable<String?>(subtitle.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryCompanion(')
          ..write('id: $id, ')
          ..write('host: $host, ')
          ..write('visitedAt: $visitedAt, ')
          ..write('link: $link, ')
          ..write('thumbnails: $thumbnails, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle')
          ..write(')'))
        .toString();
  }
}

class _$HistoryInsertable implements Insertable<History> {
  History _object;

  _$HistoryInsertable(this._object);

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return HistoryCompanion(
      id: Value(_object.id),
      visitedAt: Value(_object.visitedAt),
      link: Value(_object.link),
      thumbnails: Value(_object.thumbnails),
      title: Value(_object.title),
      subtitle: Value(_object.subtitle),
    ).toColumns(false);
  }
}

extension HistoryToInsertable on History {
  _$HistoryInsertable toInsertable() {
    return _$HistoryInsertable(this);
  }
}

class $HistoriesTableTable extends HistoriesTable
    with TableInfo<$HistoriesTableTable, History> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoriesTableTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _hostMeta = const VerificationMeta('host');
  @override
  late final GeneratedColumn<String?> host = GeneratedColumn<String?>(
      'host', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _visitedAtMeta = const VerificationMeta('visitedAt');
  @override
  late final GeneratedColumn<DateTime?> visitedAt = GeneratedColumn<DateTime?>(
      'visited_at', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _linkMeta = const VerificationMeta('link');
  @override
  late final GeneratedColumn<String?> link = GeneratedColumn<String?>(
      'link', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _thumbnailsMeta = const VerificationMeta('thumbnails');
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String?>
      thumbnails = GeneratedColumn<String?>('thumbnails', aliasedName, false,
              type: const StringType(), requiredDuringInsert: true)
          .withConverter<List<String>>($HistoriesTableTable.$converter0);
  final VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String?> title = GeneratedColumn<String?>(
      'title', aliasedName, true,
      type: const StringType(), requiredDuringInsert: false);
  final VerificationMeta _subtitleMeta = const VerificationMeta('subtitle');
  @override
  late final GeneratedColumn<String?> subtitle = GeneratedColumn<String?>(
      'subtitle', aliasedName, true,
      type: const StringType(), requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, host, visitedAt, link, thumbnails, title, subtitle];
  @override
  String get aliasedName => _alias ?? 'histories_table';
  @override
  String get actualTableName => 'histories_table';
  @override
  VerificationContext validateIntegrity(Insertable<History> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('host')) {
      context.handle(
          _hostMeta, host.isAcceptableOrUnknown(data['host']!, _hostMeta));
    } else if (isInserting) {
      context.missing(_hostMeta);
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
    context.handle(_thumbnailsMeta, const VerificationResult.success());
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  History map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return History(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      visitedAt: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}visited_at'])!,
      link: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}link'])!,
      thumbnails: $HistoriesTableTable.$converter0.mapToDart(const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}thumbnails']))!,
      title: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}title']),
      subtitle: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}subtitle']),
    );
  }

  @override
  $HistoriesTableTable createAlias(String alias) {
    return $HistoriesTableTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converter0 =
      const StringListConverter();
}

abstract class _$HistoriesDatabase extends GeneratedDatabase {
  _$HistoriesDatabase(QueryExecutor e)
      : super(SqlTypeSystem.defaultInstance, e);
  _$HistoriesDatabase.connect(DatabaseConnection c) : super.connect(c);
  late final $HistoriesTableTable historiesTable = $HistoriesTableTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [historiesTable];
}
