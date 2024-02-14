// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:drift/src/runtime/api/runtime_api.dart' as i1;
import 'package:e1547/follow/data/database.drift.dart' as i2;
import 'package:drift/internal/modular.dart' as i3;
import 'package:e1547/identity/data/database.drift.dart' as i4;
import 'package:e1547/follow/data/follow.dart' as i5;
import 'package:e1547/follow/data/database.dart' as i6;

mixin $FollowsDaoMixin on i0.DatabaseAccessor<i1.GeneratedDatabase> {
  i2.$FollowsTableTable get followsTable =>
      i3.ReadDatabaseContainer(attachedDatabase).resultSet('follows_table');
  i4.$IdentitiesTableTable get identitiesTable =>
      i3.ReadDatabaseContainer(attachedDatabase).resultSet('identities_table');
  i2.$FollowsIdentitiesTableTable get followsIdentitiesTable =>
      i3.ReadDatabaseContainer(attachedDatabase)
          .resultSet('follows_identities_table');
}

class $FollowsTableTable extends i6.FollowsTable
    with i0.TableInfo<$FollowsTableTable, i5.Follow> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FollowsTableTable(this.attachedDatabase, [this._alias]);
  static const i0.VerificationMeta _idMeta = const i0.VerificationMeta('id');
  @override
  late final i0.GeneratedColumn<int> id = i0.GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: i0.DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          i0.GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
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
  late final i0.GeneratedColumnWithTypeConverter<i5.FollowType, String> type =
      i0.GeneratedColumn<String>('type', aliasedName, false,
              type: i0.DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<i5.FollowType>(i2.$FollowsTableTable.$convertertype);
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
      [id, tags, title, alias, type, latest, unseen, thumbnail, updated];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'follows_table';
  @override
  i0.VerificationContext validateIntegrity(i0.Insertable<i5.Follow> instance,
      {bool isInserting = false}) {
    final context = i0.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
  i5.Follow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i5.Follow(
      id: attachedDatabase.typeMapping
          .read(i0.DriftSqlType.int, data['${effectivePrefix}id'])!,
      tags: attachedDatabase.typeMapping
          .read(i0.DriftSqlType.string, data['${effectivePrefix}tags'])!,
      title: attachedDatabase.typeMapping
          .read(i0.DriftSqlType.string, data['${effectivePrefix}title']),
      alias: attachedDatabase.typeMapping
          .read(i0.DriftSqlType.string, data['${effectivePrefix}alias']),
      type: i2.$FollowsTableTable.$convertertype.fromSql(attachedDatabase
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
  $FollowsTableTable createAlias(String alias) {
    return $FollowsTableTable(attachedDatabase, alias);
  }

  static i0.JsonTypeConverter2<i5.FollowType, String, String> $convertertype =
      const i0.EnumNameConverter<i5.FollowType>(i5.FollowType.values);
}

class FollowCompanion extends i0.UpdateCompanion<i5.Follow> {
  final i0.Value<int> id;
  final i0.Value<String> tags;
  final i0.Value<String?> title;
  final i0.Value<String?> alias;
  final i0.Value<i5.FollowType> type;
  final i0.Value<int?> latest;
  final i0.Value<int?> unseen;
  final i0.Value<String?> thumbnail;
  final i0.Value<DateTime?> updated;
  const FollowCompanion({
    this.id = const i0.Value.absent(),
    this.tags = const i0.Value.absent(),
    this.title = const i0.Value.absent(),
    this.alias = const i0.Value.absent(),
    this.type = const i0.Value.absent(),
    this.latest = const i0.Value.absent(),
    this.unseen = const i0.Value.absent(),
    this.thumbnail = const i0.Value.absent(),
    this.updated = const i0.Value.absent(),
  });
  FollowCompanion.insert({
    this.id = const i0.Value.absent(),
    required String tags,
    this.title = const i0.Value.absent(),
    this.alias = const i0.Value.absent(),
    required i5.FollowType type,
    this.latest = const i0.Value.absent(),
    this.unseen = const i0.Value.absent(),
    this.thumbnail = const i0.Value.absent(),
    this.updated = const i0.Value.absent(),
  })  : tags = i0.Value(tags),
        type = i0.Value(type);
  static i0.Insertable<i5.Follow> custom({
    i0.Expression<int>? id,
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

  i2.FollowCompanion copyWith(
      {i0.Value<int>? id,
      i0.Value<String>? tags,
      i0.Value<String?>? title,
      i0.Value<String?>? alias,
      i0.Value<i5.FollowType>? type,
      i0.Value<int?>? latest,
      i0.Value<int?>? unseen,
      i0.Value<String?>? thumbnail,
      i0.Value<DateTime?>? updated}) {
    return i2.FollowCompanion(
      id: id ?? this.id,
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
          i2.$FollowsTableTable.$convertertype.toSql(type.value));
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
    return (StringBuffer('FollowCompanion(')
          ..write('id: $id, ')
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

class _$FollowInsertable implements i0.Insertable<i5.Follow> {
  i5.Follow _object;
  _$FollowInsertable(this._object);
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    return i2.FollowCompanion(
      id: i0.Value(_object.id),
      tags: i0.Value(_object.tags),
      title: i0.Value(_object.title),
      alias: i0.Value(_object.alias),
      type: i0.Value(_object.type),
      latest: i0.Value(_object.latest),
      unseen: i0.Value(_object.unseen),
      thumbnail: i0.Value(_object.thumbnail),
      updated: i0.Value(_object.updated),
    ).toColumns(false);
  }
}

extension FollowToInsertable on i5.Follow {
  _$FollowInsertable toInsertable() {
    return _$FollowInsertable(this);
  }
}

class $FollowsIdentitiesTableTable extends i6.FollowsIdentitiesTable
    with i0.TableInfo<$FollowsIdentitiesTableTable, i2.FollowIdentity> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FollowsIdentitiesTableTable(this.attachedDatabase, [this._alias]);
  static const i0.VerificationMeta _identityMeta =
      const i0.VerificationMeta('identity');
  @override
  late final i0.GeneratedColumn<int> identity = i0.GeneratedColumn<int>(
      'identity', aliasedName, false,
      type: i0.DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: i0.GeneratedColumn.constraintIsAlways(
          'REFERENCES identities_table (id) ON UPDATE NO ACTION ON DELETE NO ACTION'));
  static const i0.VerificationMeta _followMeta =
      const i0.VerificationMeta('follow');
  @override
  late final i0.GeneratedColumn<int> follow = i0.GeneratedColumn<int>(
      'follow', aliasedName, false,
      type: i0.DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: i0.GeneratedColumn.constraintIsAlways(
          'REFERENCES follows_table (id) ON UPDATE CASCADE ON DELETE CASCADE'));
  @override
  List<i0.GeneratedColumn> get $columns => [identity, follow];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'follows_identities_table';
  @override
  i0.VerificationContext validateIntegrity(
      i0.Insertable<i2.FollowIdentity> instance,
      {bool isInserting = false}) {
    final context = i0.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('identity')) {
      context.handle(_identityMeta,
          identity.isAcceptableOrUnknown(data['identity']!, _identityMeta));
    } else if (isInserting) {
      context.missing(_identityMeta);
    }
    if (data.containsKey('follow')) {
      context.handle(_followMeta,
          follow.isAcceptableOrUnknown(data['follow']!, _followMeta));
    } else if (isInserting) {
      context.missing(_followMeta);
    }
    return context;
  }

  @override
  Set<i0.GeneratedColumn> get $primaryKey => {identity, follow};
  @override
  i2.FollowIdentity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i2.FollowIdentity(
      identity: attachedDatabase.typeMapping
          .read(i0.DriftSqlType.int, data['${effectivePrefix}identity'])!,
      follow: attachedDatabase.typeMapping
          .read(i0.DriftSqlType.int, data['${effectivePrefix}follow'])!,
    );
  }

  @override
  $FollowsIdentitiesTableTable createAlias(String alias) {
    return $FollowsIdentitiesTableTable(attachedDatabase, alias);
  }
}

class FollowIdentity extends i0.DataClass
    implements i0.Insertable<i2.FollowIdentity> {
  final int identity;
  final int follow;
  const FollowIdentity({required this.identity, required this.follow});
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['identity'] = i0.Variable<int>(identity);
    map['follow'] = i0.Variable<int>(follow);
    return map;
  }

  i2.FollowIdentityCompanion toCompanion(bool nullToAbsent) {
    return i2.FollowIdentityCompanion(
      identity: i0.Value(identity),
      follow: i0.Value(follow),
    );
  }

  factory FollowIdentity.fromJson(Map<String, dynamic> json,
      {i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return FollowIdentity(
      identity: serializer.fromJson<int>(json['identity']),
      follow: serializer.fromJson<int>(json['follow']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'identity': serializer.toJson<int>(identity),
      'follow': serializer.toJson<int>(follow),
    };
  }

  i2.FollowIdentity copyWith({int? identity, int? follow}) => i2.FollowIdentity(
        identity: identity ?? this.identity,
        follow: follow ?? this.follow,
      );
  @override
  String toString() {
    return (StringBuffer('FollowIdentity(')
          ..write('identity: $identity, ')
          ..write('follow: $follow')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(identity, follow);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i2.FollowIdentity &&
          other.identity == this.identity &&
          other.follow == this.follow);
}

class FollowIdentityCompanion extends i0.UpdateCompanion<i2.FollowIdentity> {
  final i0.Value<int> identity;
  final i0.Value<int> follow;
  final i0.Value<int> rowid;
  const FollowIdentityCompanion({
    this.identity = const i0.Value.absent(),
    this.follow = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  FollowIdentityCompanion.insert({
    required int identity,
    required int follow,
    this.rowid = const i0.Value.absent(),
  })  : identity = i0.Value(identity),
        follow = i0.Value(follow);
  static i0.Insertable<i2.FollowIdentity> custom({
    i0.Expression<int>? identity,
    i0.Expression<int>? follow,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (identity != null) 'identity': identity,
      if (follow != null) 'follow': follow,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i2.FollowIdentityCompanion copyWith(
      {i0.Value<int>? identity, i0.Value<int>? follow, i0.Value<int>? rowid}) {
    return i2.FollowIdentityCompanion(
      identity: identity ?? this.identity,
      follow: follow ?? this.follow,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (identity.present) {
      map['identity'] = i0.Variable<int>(identity.value);
    }
    if (follow.present) {
      map['follow'] = i0.Variable<int>(follow.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FollowIdentityCompanion(')
          ..write('identity: $identity, ')
          ..write('follow: $follow, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}
