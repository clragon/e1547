// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// DriftDatabaseGenerator
// **************************************************************************

// ignore_for_file: type=lint
class FollowCompanion extends UpdateCompanion<Follow> {
  final Value<int> id;
  final Value<String> host;
  final Value<String> tags;
  final Value<String?> title;
  final Value<String?> alias;
  final Value<FollowType> type;
  final Value<int?> latest;
  final Value<int?> unseen;
  final Value<String?> thumbnail;
  final Value<DateTime?> updated;

  const FollowCompanion({
    this.id = const Value.absent(),
    this.host = const Value.absent(),
    this.tags = const Value.absent(),
    this.title = const Value.absent(),
    this.alias = const Value.absent(),
    this.type = const Value.absent(),
    this.latest = const Value.absent(),
    this.unseen = const Value.absent(),
    this.thumbnail = const Value.absent(),
    this.updated = const Value.absent(),
  });
  FollowCompanion.insert({
    this.id = const Value.absent(),
    required String host,
    required String tags,
    this.title = const Value.absent(),
    this.alias = const Value.absent(),
    required FollowType type,
    this.latest = const Value.absent(),
    this.unseen = const Value.absent(),
    this.thumbnail = const Value.absent(),
    this.updated = const Value.absent(),
  })  : host = Value(host),
        tags = Value(tags),
        type = Value(type);
  static Insertable<Follow> custom({
    Expression<int>? id,
    Expression<String>? host,
    Expression<String>? tags,
    Expression<String>? title,
    Expression<String>? alias,
    Expression<String>? type,
    Expression<int>? latest,
    Expression<int>? unseen,
    Expression<String>? thumbnail,
    Expression<DateTime>? updated,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (host != null) 'host': host,
      if (tags != null) 'tags': tags,
      if (title != null) 'title': title,
      if (alias != null) 'alias': alias,
      if (type != null) 'type': type,
      if (latest != null) 'latest': latest,
      if (unseen != null) 'unseen': unseen,
      if (thumbnail != null) 'thumbnail': thumbnail,
      if (updated != null) 'updated': updated,
    });
  }

  FollowCompanion copyWith(
      {Value<int>? id,
      Value<String>? host,
      Value<String>? tags,
      Value<String?>? title,
      Value<String?>? alias,
      Value<FollowType>? type,
      Value<int?>? latest,
      Value<int?>? unseen,
      Value<String?>? thumbnail,
      Value<DateTime?>? updated}) {
    return FollowCompanion(
      id: id ?? this.id,
      host: host ?? this.host,
      tags: tags ?? this.tags,
      title: title ?? this.title,
      alias: alias ?? this.alias,
      type: type ?? this.type,
      latest: latest ?? this.latest,
      unseen: unseen ?? this.unseen,
      thumbnail: thumbnail ?? this.thumbnail,
      updated: updated ?? this.updated,
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
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (alias.present) {
      map['alias'] = Variable<String>(alias.value);
    }
    if (type.present) {
      final converter = $FollowsTableTable.$converter0;
      map['type'] = Variable<String>(converter.toSql(type.value));
    }
    if (latest.present) {
      map['latest'] = Variable<int>(latest.value);
    }
    if (unseen.present) {
      map['unseen'] = Variable<int>(unseen.value);
    }
    if (thumbnail.present) {
      map['thumbnail'] = Variable<String>(thumbnail.value);
    }
    if (updated.present) {
      map['updated'] = Variable<DateTime>(updated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FollowCompanion(')
          ..write('id: $id, ')
          ..write('host: $host, ')
          ..write('tags: $tags, ')
          ..write('title: $title, ')
          ..write('alias: $alias, ')
          ..write('type: $type, ')
          ..write('latest: $latest, ')
          ..write('unseen: $unseen, ')
          ..write('thumbnail: $thumbnail, ')
          ..write('updated: $updated')
          ..write(')'))
        .toString();
  }
}

class _$FollowInsertable implements Insertable<Follow> {
  Follow _object;

  _$FollowInsertable(this._object);

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return FollowCompanion(
      id: Value(_object.id),
      tags: Value(_object.tags),
      title: Value(_object.title),
      alias: Value(_object.alias),
      type: Value(_object.type),
      latest: Value(_object.latest),
      unseen: Value(_object.unseen),
      thumbnail: Value(_object.thumbnail),
      updated: Value(_object.updated),
    ).toColumns(false);
  }
}

extension FollowToInsertable on Follow {
  _$FollowInsertable toInsertable() {
    return _$FollowInsertable(this);
  }
}

class $FollowsTableTable extends FollowsTable
    with TableInfo<$FollowsTableTable, Follow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FollowsTableTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _hostMeta = const VerificationMeta('host');
  @override
  late final GeneratedColumn<String> host = GeneratedColumn<String>(
      'host', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  final VerificationMeta _aliasMeta = const VerificationMeta('alias');
  @override
  late final GeneratedColumn<String> alias = GeneratedColumn<String>(
      'alias', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  final VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumnWithTypeConverter<FollowType, String> type =
      GeneratedColumn<String>('type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<FollowType>($FollowsTableTable.$converter0);
  final VerificationMeta _latestMeta = const VerificationMeta('latest');
  @override
  late final GeneratedColumn<int> latest = GeneratedColumn<int>(
      'latest', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  final VerificationMeta _unseenMeta = const VerificationMeta('unseen');
  @override
  late final GeneratedColumn<int> unseen = GeneratedColumn<int>(
      'unseen', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  final VerificationMeta _thumbnailMeta = const VerificationMeta('thumbnail');
  @override
  late final GeneratedColumn<String> thumbnail = GeneratedColumn<String>(
      'thumbnail', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  final VerificationMeta _updatedMeta = const VerificationMeta('updated');
  @override
  late final GeneratedColumn<DateTime> updated = GeneratedColumn<DateTime>(
      'updated', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, host, tags, title, alias, type, latest, unseen, thumbnail, updated];
  @override
  String get aliasedName => _alias ?? 'follows_table';
  @override
  String get actualTableName => 'follows_table';
  @override
  VerificationContext validateIntegrity(Insertable<Follow> instance,
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
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    } else if (isInserting) {
      context.missing(_tagsMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('alias')) {
      context.handle(
          _aliasMeta, alias.isAcceptableOrUnknown(data['alias']!, _aliasMeta));
    }
    context.handle(_typeMeta, const VerificationResult.success());
    if (data.containsKey('latest')) {
      context.handle(_latestMeta,
          latest.isAcceptableOrUnknown(data['latest']!, _latestMeta));
    }
    if (data.containsKey('unseen')) {
      context.handle(_unseenMeta,
          unseen.isAcceptableOrUnknown(data['unseen']!, _unseenMeta));
    }
    if (data.containsKey('thumbnail')) {
      context.handle(_thumbnailMeta,
          thumbnail.isAcceptableOrUnknown(data['thumbnail']!, _thumbnailMeta));
    }
    if (data.containsKey('updated')) {
      context.handle(_updatedMeta,
          updated.isAcceptableOrUnknown(data['updated']!, _updatedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {host, tags},
      ];
  @override
  Follow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Follow(
      id: attachedDatabase.options.types
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      tags: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!,
      title: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      alias: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}alias']),
      type: $FollowsTableTable.$converter0.fromSql(attachedDatabase
          .options.types
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!),
      latest: attachedDatabase.options.types
          .read(DriftSqlType.int, data['${effectivePrefix}latest']),
      unseen: attachedDatabase.options.types
          .read(DriftSqlType.int, data['${effectivePrefix}unseen']),
      thumbnail: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}thumbnail']),
      updated: attachedDatabase.options.types
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated']),
    );
  }

  @override
  $FollowsTableTable createAlias(String alias) {
    return $FollowsTableTable(attachedDatabase, alias);
  }

  static TypeConverter<FollowType, String> $converter0 =
      const StringEnumConverter(FollowType.values);
}

abstract class _$FollowsDatabase extends GeneratedDatabase {
  _$FollowsDatabase(QueryExecutor e) : super(e);
  _$FollowsDatabase.connect(DatabaseConnection c) : super.connect(c);
  late final $FollowsTableTable followsTable = $FollowsTableTable(this);
  @override
  Iterable<TableInfo<Table, dynamic>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [followsTable];
}
