// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:e1547/history/data/legacy.drift.dart' as i1;
import 'package:e1547/history/data/legacy.dart' as i2;
import 'package:e1547/interface/data/sql.dart' as i3;

abstract class $OldHistoriesDatabase extends i0.GeneratedDatabase {
  $OldHistoriesDatabase(i0.QueryExecutor e) : super(e);
  late final i1.$OldHistoriesTableTable oldHistoriesTable =
      i1.$OldHistoriesTableTable(this);
  @override
  Iterable<i0.TableInfo<i0.Table, Object?>> get allTables =>
      allSchemaEntities.whereType<i0.TableInfo<i0.Table, Object?>>();
  @override
  List<i0.DatabaseSchemaEntity> get allSchemaEntities => [oldHistoriesTable];
}

class $OldHistoriesTableTable extends i2.OldHistoriesTable
    with i0.TableInfo<$OldHistoriesTableTable, i1.OldHistoriesTableData> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OldHistoriesTableTable(this.attachedDatabase, [this._alias]);
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
              i1.$OldHistoriesTableTable.$converterthumbnails);
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
      [id, host, visitedAt, link, thumbnails, title, subtitle];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'histories_table';
  @override
  i0.VerificationContext validateIntegrity(
      i0.Insertable<i1.OldHistoriesTableData> instance,
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
  i1.OldHistoriesTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i1.OldHistoriesTableData(
      id: attachedDatabase.typeMapping
          .read(i0.DriftSqlType.int, data['${effectivePrefix}id'])!,
      host: attachedDatabase.typeMapping
          .read(i0.DriftSqlType.string, data['${effectivePrefix}host'])!,
      visitedAt: attachedDatabase.typeMapping.read(
          i0.DriftSqlType.dateTime, data['${effectivePrefix}visited_at'])!,
      link: attachedDatabase.typeMapping
          .read(i0.DriftSqlType.string, data['${effectivePrefix}link'])!,
      thumbnails: i1.$OldHistoriesTableTable.$converterthumbnails.fromSql(
          attachedDatabase.typeMapping.read(
              i0.DriftSqlType.string, data['${effectivePrefix}thumbnails'])!),
      title: attachedDatabase.typeMapping
          .read(i0.DriftSqlType.string, data['${effectivePrefix}title']),
      subtitle: attachedDatabase.typeMapping
          .read(i0.DriftSqlType.string, data['${effectivePrefix}subtitle']),
    );
  }

  @override
  $OldHistoriesTableTable createAlias(String alias) {
    return $OldHistoriesTableTable(attachedDatabase, alias);
  }

  static i0.TypeConverter<List<String>, String> $converterthumbnails =
      i3.JsonSqlConverter.list<String>();
}

class OldHistoriesTableData extends i0.DataClass
    implements i0.Insertable<i1.OldHistoriesTableData> {
  final int id;
  final String host;
  final DateTime visitedAt;
  final String link;
  final List<String> thumbnails;
  final String? title;
  final String? subtitle;
  const OldHistoriesTableData(
      {required this.id,
      required this.host,
      required this.visitedAt,
      required this.link,
      required this.thumbnails,
      this.title,
      this.subtitle});
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['id'] = i0.Variable<int>(id);
    map['host'] = i0.Variable<String>(host);
    map['visited_at'] = i0.Variable<DateTime>(visitedAt);
    map['link'] = i0.Variable<String>(link);
    {
      map['thumbnails'] = i0.Variable<String>(
          i1.$OldHistoriesTableTable.$converterthumbnails.toSql(thumbnails));
    }
    if (!nullToAbsent || title != null) {
      map['title'] = i0.Variable<String>(title);
    }
    if (!nullToAbsent || subtitle != null) {
      map['subtitle'] = i0.Variable<String>(subtitle);
    }
    return map;
  }

  i1.OldHistoriesTableDataCompanion toCompanion(bool nullToAbsent) {
    return i1.OldHistoriesTableDataCompanion(
      id: i0.Value(id),
      host: i0.Value(host),
      visitedAt: i0.Value(visitedAt),
      link: i0.Value(link),
      thumbnails: i0.Value(thumbnails),
      title: title == null && nullToAbsent
          ? const i0.Value.absent()
          : i0.Value(title),
      subtitle: subtitle == null && nullToAbsent
          ? const i0.Value.absent()
          : i0.Value(subtitle),
    );
  }

  factory OldHistoriesTableData.fromJson(Map<String, dynamic> json,
      {i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return OldHistoriesTableData(
      id: serializer.fromJson<int>(json['id']),
      host: serializer.fromJson<String>(json['host']),
      visitedAt: serializer.fromJson<DateTime>(json['visitedAt']),
      link: serializer.fromJson<String>(json['link']),
      thumbnails: serializer.fromJson<List<String>>(json['thumbnails']),
      title: serializer.fromJson<String?>(json['title']),
      subtitle: serializer.fromJson<String?>(json['subtitle']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'host': serializer.toJson<String>(host),
      'visitedAt': serializer.toJson<DateTime>(visitedAt),
      'link': serializer.toJson<String>(link),
      'thumbnails': serializer.toJson<List<String>>(thumbnails),
      'title': serializer.toJson<String?>(title),
      'subtitle': serializer.toJson<String?>(subtitle),
    };
  }

  i1.OldHistoriesTableData copyWith(
          {int? id,
          String? host,
          DateTime? visitedAt,
          String? link,
          List<String>? thumbnails,
          i0.Value<String?> title = const i0.Value.absent(),
          i0.Value<String?> subtitle = const i0.Value.absent()}) =>
      i1.OldHistoriesTableData(
        id: id ?? this.id,
        host: host ?? this.host,
        visitedAt: visitedAt ?? this.visitedAt,
        link: link ?? this.link,
        thumbnails: thumbnails ?? this.thumbnails,
        title: title.present ? title.value : this.title,
        subtitle: subtitle.present ? subtitle.value : this.subtitle,
      );
  @override
  String toString() {
    return (StringBuffer('OldHistoriesTableData(')
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

  @override
  int get hashCode =>
      Object.hash(id, host, visitedAt, link, thumbnails, title, subtitle);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i1.OldHistoriesTableData &&
          other.id == this.id &&
          other.host == this.host &&
          other.visitedAt == this.visitedAt &&
          other.link == this.link &&
          other.thumbnails == this.thumbnails &&
          other.title == this.title &&
          other.subtitle == this.subtitle);
}

class OldHistoriesTableDataCompanion
    extends i0.UpdateCompanion<i1.OldHistoriesTableData> {
  final i0.Value<int> id;
  final i0.Value<String> host;
  final i0.Value<DateTime> visitedAt;
  final i0.Value<String> link;
  final i0.Value<List<String>> thumbnails;
  final i0.Value<String?> title;
  final i0.Value<String?> subtitle;
  const OldHistoriesTableDataCompanion({
    this.id = const i0.Value.absent(),
    this.host = const i0.Value.absent(),
    this.visitedAt = const i0.Value.absent(),
    this.link = const i0.Value.absent(),
    this.thumbnails = const i0.Value.absent(),
    this.title = const i0.Value.absent(),
    this.subtitle = const i0.Value.absent(),
  });
  OldHistoriesTableDataCompanion.insert({
    this.id = const i0.Value.absent(),
    required String host,
    required DateTime visitedAt,
    required String link,
    required List<String> thumbnails,
    this.title = const i0.Value.absent(),
    this.subtitle = const i0.Value.absent(),
  })  : host = i0.Value(host),
        visitedAt = i0.Value(visitedAt),
        link = i0.Value(link),
        thumbnails = i0.Value(thumbnails);
  static i0.Insertable<i1.OldHistoriesTableData> custom({
    i0.Expression<int>? id,
    i0.Expression<String>? host,
    i0.Expression<DateTime>? visitedAt,
    i0.Expression<String>? link,
    i0.Expression<String>? thumbnails,
    i0.Expression<String>? title,
    i0.Expression<String>? subtitle,
  }) {
    return i0.RawValuesInsertable({
      if (id != null) 'id': id,
      if (host != null) 'host': host,
      if (visitedAt != null) 'visited_at': visitedAt,
      if (link != null) 'link': link,
      if (thumbnails != null) 'thumbnails': thumbnails,
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
    });
  }

  i1.OldHistoriesTableDataCompanion copyWith(
      {i0.Value<int>? id,
      i0.Value<String>? host,
      i0.Value<DateTime>? visitedAt,
      i0.Value<String>? link,
      i0.Value<List<String>>? thumbnails,
      i0.Value<String?>? title,
      i0.Value<String?>? subtitle}) {
    return i1.OldHistoriesTableDataCompanion(
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
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (id.present) {
      map['id'] = i0.Variable<int>(id.value);
    }
    if (host.present) {
      map['host'] = i0.Variable<String>(host.value);
    }
    if (visitedAt.present) {
      map['visited_at'] = i0.Variable<DateTime>(visitedAt.value);
    }
    if (link.present) {
      map['link'] = i0.Variable<String>(link.value);
    }
    if (thumbnails.present) {
      map['thumbnails'] = i0.Variable<String>(i1
          .$OldHistoriesTableTable.$converterthumbnails
          .toSql(thumbnails.value));
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
    return (StringBuffer('OldHistoriesTableDataCompanion(')
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
