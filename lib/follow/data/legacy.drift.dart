// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:e1547/follow/data/legacy.drift.dart' as i1;
import 'package:e1547/follow/data/follow.dart' as i2;
import 'package:e1547/follow/data/legacy.dart' as i3;

abstract class $OldFollowsDatabase extends i0.GeneratedDatabase {
  $OldFollowsDatabase(i0.QueryExecutor e) : super(e);
  late final i1.$OldFollowsTableTable oldFollowsTable =
      i1.$OldFollowsTableTable(this);
  @override
  Iterable<i0.TableInfo<i0.Table, Object?>> get allTables =>
      allSchemaEntities.whereType<i0.TableInfo<i0.Table, Object?>>();
  @override
  List<i0.DatabaseSchemaEntity> get allSchemaEntities => [oldFollowsTable];
}

class $OldFollowsTableTable extends i3.OldFollowsTable
    with i0.TableInfo<$OldFollowsTableTable, i1.OldFollowsTableData> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OldFollowsTableTable(this.attachedDatabase, [this._alias]);
  static const i0.VerificationMeta _idMeta = const i0.VerificationMeta('id');
  @override
  late final i0.GeneratedColumn<int> id = i0.GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: i0.DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          i0.GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const i0.VerificationMeta _hostMeta =
      const i0.VerificationMeta('host');
  @override
  late final i0.GeneratedColumn<String> host = i0.GeneratedColumn<String>(
      'host', aliasedName, false,
      type: i0.DriftSqlType.string, requiredDuringInsert: true);
  static const i0.VerificationMeta _tagsMeta =
      const i0.VerificationMeta('tags');
  @override
  late final i0.GeneratedColumn<String> tags = i0.GeneratedColumn<String>(
      'tags', aliasedName, false,
      type: i0.DriftSqlType.string, requiredDuringInsert: true);
  static const i0.VerificationMeta _titleMeta =
      const i0.VerificationMeta('title');
  @override
  late final i0.GeneratedColumn<String> title = i0.GeneratedColumn<String>(
      'title', aliasedName, true,
      type: i0.DriftSqlType.string, requiredDuringInsert: false);
  static const i0.VerificationMeta _aliasMeta =
      const i0.VerificationMeta('alias');
  @override
  late final i0.GeneratedColumn<String> alias = i0.GeneratedColumn<String>(
      'alias', aliasedName, true,
      type: i0.DriftSqlType.string, requiredDuringInsert: false);
  static const i0.VerificationMeta _typeMeta =
      const i0.VerificationMeta('type');
  @override
  late final i0.GeneratedColumnWithTypeConverter<i2.FollowType, String> type =
      i0.GeneratedColumn<String>('type', aliasedName, false,
              type: i0.DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<i2.FollowType>(
              i1.$OldFollowsTableTable.$convertertype);
  static const i0.VerificationMeta _latestMeta =
      const i0.VerificationMeta('latest');
  @override
  late final i0.GeneratedColumn<int> latest = i0.GeneratedColumn<int>(
      'latest', aliasedName, true,
      type: i0.DriftSqlType.int, requiredDuringInsert: false);
  static const i0.VerificationMeta _unseenMeta =
      const i0.VerificationMeta('unseen');
  @override
  late final i0.GeneratedColumn<int> unseen = i0.GeneratedColumn<int>(
      'unseen', aliasedName, true,
      type: i0.DriftSqlType.int, requiredDuringInsert: false);
  static const i0.VerificationMeta _thumbnailMeta =
      const i0.VerificationMeta('thumbnail');
  @override
  late final i0.GeneratedColumn<String> thumbnail = i0.GeneratedColumn<String>(
      'thumbnail', aliasedName, true,
      type: i0.DriftSqlType.string, requiredDuringInsert: false);
  static const i0.VerificationMeta _updatedMeta =
      const i0.VerificationMeta('updated');
  @override
  late final i0.GeneratedColumn<DateTime> updated =
      i0.GeneratedColumn<DateTime>('updated', aliasedName, true,
          type: i0.DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<i0.GeneratedColumn> get $columns =>
      [id, host, tags, title, alias, type, latest, unseen, thumbnail, updated];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'follows_table';
  @override
  i0.VerificationContext validateIntegrity(
      i0.Insertable<i1.OldFollowsTableData> instance,
      {bool isInserting = false}) {
    final context = i0.VerificationContext();
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
    context.handle(_typeMeta, const i0.VerificationResult.success());
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
  Set<i0.GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<i0.GeneratedColumn>> get uniqueKeys => [
        {host, tags},
      ];
  @override
  i1.OldFollowsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i1.OldFollowsTableData(
      id: attachedDatabase.typeMapping
          .read(i0.DriftSqlType.int, data['${effectivePrefix}id'])!,
      host: attachedDatabase.typeMapping
          .read(i0.DriftSqlType.string, data['${effectivePrefix}host'])!,
      tags: attachedDatabase.typeMapping
          .read(i0.DriftSqlType.string, data['${effectivePrefix}tags'])!,
      title: attachedDatabase.typeMapping
          .read(i0.DriftSqlType.string, data['${effectivePrefix}title']),
      alias: attachedDatabase.typeMapping
          .read(i0.DriftSqlType.string, data['${effectivePrefix}alias']),
      type: i1.$OldFollowsTableTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(i0.DriftSqlType.string, data['${effectivePrefix}type'])!),
      latest: attachedDatabase.typeMapping
          .read(i0.DriftSqlType.int, data['${effectivePrefix}latest']),
      unseen: attachedDatabase.typeMapping
          .read(i0.DriftSqlType.int, data['${effectivePrefix}unseen']),
      thumbnail: attachedDatabase.typeMapping
          .read(i0.DriftSqlType.string, data['${effectivePrefix}thumbnail']),
      updated: attachedDatabase.typeMapping
          .read(i0.DriftSqlType.dateTime, data['${effectivePrefix}updated']),
    );
  }

  @override
  $OldFollowsTableTable createAlias(String alias) {
    return $OldFollowsTableTable(attachedDatabase, alias);
  }

  static i0.JsonTypeConverter2<i2.FollowType, String, String> $convertertype =
      const i0.EnumNameConverter<i2.FollowType>(i2.FollowType.values);
}

class OldFollowsTableData extends i0.DataClass
    implements i0.Insertable<i1.OldFollowsTableData> {
  final int id;
  final String host;
  final String tags;
  final String? title;
  final String? alias;
  final i2.FollowType type;
  final int? latest;
  final int? unseen;
  final String? thumbnail;
  final DateTime? updated;
  const OldFollowsTableData(
      {required this.id,
      required this.host,
      required this.tags,
      this.title,
      this.alias,
      required this.type,
      this.latest,
      this.unseen,
      this.thumbnail,
      this.updated});
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['id'] = i0.Variable<int>(id);
    map['host'] = i0.Variable<String>(host);
    map['tags'] = i0.Variable<String>(tags);
    if (!nullToAbsent || title != null) {
      map['title'] = i0.Variable<String>(title);
    }
    if (!nullToAbsent || alias != null) {
      map['alias'] = i0.Variable<String>(alias);
    }
    {
      map['type'] = i0.Variable<String>(
          i1.$OldFollowsTableTable.$convertertype.toSql(type));
    }
    if (!nullToAbsent || latest != null) {
      map['latest'] = i0.Variable<int>(latest);
    }
    if (!nullToAbsent || unseen != null) {
      map['unseen'] = i0.Variable<int>(unseen);
    }
    if (!nullToAbsent || thumbnail != null) {
      map['thumbnail'] = i0.Variable<String>(thumbnail);
    }
    if (!nullToAbsent || updated != null) {
      map['updated'] = i0.Variable<DateTime>(updated);
    }
    return map;
  }

  i1.OldFollowsTableDataCompanion toCompanion(bool nullToAbsent) {
    return i1.OldFollowsTableDataCompanion(
      id: i0.Value(id),
      host: i0.Value(host),
      tags: i0.Value(tags),
      title: title == null && nullToAbsent
          ? const i0.Value.absent()
          : i0.Value(title),
      alias: alias == null && nullToAbsent
          ? const i0.Value.absent()
          : i0.Value(alias),
      type: i0.Value(type),
      latest: latest == null && nullToAbsent
          ? const i0.Value.absent()
          : i0.Value(latest),
      unseen: unseen == null && nullToAbsent
          ? const i0.Value.absent()
          : i0.Value(unseen),
      thumbnail: thumbnail == null && nullToAbsent
          ? const i0.Value.absent()
          : i0.Value(thumbnail),
      updated: updated == null && nullToAbsent
          ? const i0.Value.absent()
          : i0.Value(updated),
    );
  }

  factory OldFollowsTableData.fromJson(Map<String, dynamic> json,
      {i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return OldFollowsTableData(
      id: serializer.fromJson<int>(json['id']),
      host: serializer.fromJson<String>(json['host']),
      tags: serializer.fromJson<String>(json['tags']),
      title: serializer.fromJson<String?>(json['title']),
      alias: serializer.fromJson<String?>(json['alias']),
      type: i1.$OldFollowsTableTable.$convertertype
          .fromJson(serializer.fromJson<String>(json['type'])),
      latest: serializer.fromJson<int?>(json['latest']),
      unseen: serializer.fromJson<int?>(json['unseen']),
      thumbnail: serializer.fromJson<String?>(json['thumbnail']),
      updated: serializer.fromJson<DateTime?>(json['updated']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'host': serializer.toJson<String>(host),
      'tags': serializer.toJson<String>(tags),
      'title': serializer.toJson<String?>(title),
      'alias': serializer.toJson<String?>(alias),
      'type': serializer
          .toJson<String>(i1.$OldFollowsTableTable.$convertertype.toJson(type)),
      'latest': serializer.toJson<int?>(latest),
      'unseen': serializer.toJson<int?>(unseen),
      'thumbnail': serializer.toJson<String?>(thumbnail),
      'updated': serializer.toJson<DateTime?>(updated),
    };
  }

  i1.OldFollowsTableData copyWith(
          {int? id,
          String? host,
          String? tags,
          i0.Value<String?> title = const i0.Value.absent(),
          i0.Value<String?> alias = const i0.Value.absent(),
          i2.FollowType? type,
          i0.Value<int?> latest = const i0.Value.absent(),
          i0.Value<int?> unseen = const i0.Value.absent(),
          i0.Value<String?> thumbnail = const i0.Value.absent(),
          i0.Value<DateTime?> updated = const i0.Value.absent()}) =>
      i1.OldFollowsTableData(
        id: id ?? this.id,
        host: host ?? this.host,
        tags: tags ?? this.tags,
        title: title.present ? title.value : this.title,
        alias: alias.present ? alias.value : this.alias,
        type: type ?? this.type,
        latest: latest.present ? latest.value : this.latest,
        unseen: unseen.present ? unseen.value : this.unseen,
        thumbnail: thumbnail.present ? thumbnail.value : this.thumbnail,
        updated: updated.present ? updated.value : this.updated,
      );
  @override
  String toString() {
    return (StringBuffer('OldFollowsTableData(')
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

  @override
  int get hashCode => Object.hash(
      id, host, tags, title, alias, type, latest, unseen, thumbnail, updated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i1.OldFollowsTableData &&
          other.id == this.id &&
          other.host == this.host &&
          other.tags == this.tags &&
          other.title == this.title &&
          other.alias == this.alias &&
          other.type == this.type &&
          other.latest == this.latest &&
          other.unseen == this.unseen &&
          other.thumbnail == this.thumbnail &&
          other.updated == this.updated);
}

class OldFollowsTableDataCompanion
    extends i0.UpdateCompanion<i1.OldFollowsTableData> {
  final i0.Value<int> id;
  final i0.Value<String> host;
  final i0.Value<String> tags;
  final i0.Value<String?> title;
  final i0.Value<String?> alias;
  final i0.Value<i2.FollowType> type;
  final i0.Value<int?> latest;
  final i0.Value<int?> unseen;
  final i0.Value<String?> thumbnail;
  final i0.Value<DateTime?> updated;
  const OldFollowsTableDataCompanion({
    this.id = const i0.Value.absent(),
    this.host = const i0.Value.absent(),
    this.tags = const i0.Value.absent(),
    this.title = const i0.Value.absent(),
    this.alias = const i0.Value.absent(),
    this.type = const i0.Value.absent(),
    this.latest = const i0.Value.absent(),
    this.unseen = const i0.Value.absent(),
    this.thumbnail = const i0.Value.absent(),
    this.updated = const i0.Value.absent(),
  });
  OldFollowsTableDataCompanion.insert({
    this.id = const i0.Value.absent(),
    required String host,
    required String tags,
    this.title = const i0.Value.absent(),
    this.alias = const i0.Value.absent(),
    required i2.FollowType type,
    this.latest = const i0.Value.absent(),
    this.unseen = const i0.Value.absent(),
    this.thumbnail = const i0.Value.absent(),
    this.updated = const i0.Value.absent(),
  })  : host = i0.Value(host),
        tags = i0.Value(tags),
        type = i0.Value(type);
  static i0.Insertable<i1.OldFollowsTableData> custom({
    i0.Expression<int>? id,
    i0.Expression<String>? host,
    i0.Expression<String>? tags,
    i0.Expression<String>? title,
    i0.Expression<String>? alias,
    i0.Expression<String>? type,
    i0.Expression<int>? latest,
    i0.Expression<int>? unseen,
    i0.Expression<String>? thumbnail,
    i0.Expression<DateTime>? updated,
  }) {
    return i0.RawValuesInsertable({
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

  i1.OldFollowsTableDataCompanion copyWith(
      {i0.Value<int>? id,
      i0.Value<String>? host,
      i0.Value<String>? tags,
      i0.Value<String?>? title,
      i0.Value<String?>? alias,
      i0.Value<i2.FollowType>? type,
      i0.Value<int?>? latest,
      i0.Value<int?>? unseen,
      i0.Value<String?>? thumbnail,
      i0.Value<DateTime?>? updated}) {
    return i1.OldFollowsTableDataCompanion(
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
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (id.present) {
      map['id'] = i0.Variable<int>(id.value);
    }
    if (host.present) {
      map['host'] = i0.Variable<String>(host.value);
    }
    if (tags.present) {
      map['tags'] = i0.Variable<String>(tags.value);
    }
    if (title.present) {
      map['title'] = i0.Variable<String>(title.value);
    }
    if (alias.present) {
      map['alias'] = i0.Variable<String>(alias.value);
    }
    if (type.present) {
      map['type'] = i0.Variable<String>(
          i1.$OldFollowsTableTable.$convertertype.toSql(type.value));
    }
    if (latest.present) {
      map['latest'] = i0.Variable<int>(latest.value);
    }
    if (unseen.present) {
      map['unseen'] = i0.Variable<int>(unseen.value);
    }
    if (thumbnail.present) {
      map['thumbnail'] = i0.Variable<String>(thumbnail.value);
    }
    if (updated.present) {
      map['updated'] = i0.Variable<DateTime>(updated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OldFollowsTableDataCompanion(')
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
