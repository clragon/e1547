// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:drift/src/runtime/api/runtime_api.dart' as i1;
import 'package:e1547/identity/data/database.drift.dart' as i2;
import 'package:drift/internal/modular.dart' as i3;
import 'package:e1547/traits/data/database.drift.dart' as i4;
import 'package:e1547/traits/data/traits.dart' as i5;
import 'package:e1547/traits/data/database.dart' as i6;
import 'package:e1547/interface/data/sql.dart' as i7;

mixin $TraitsDaoMixin on i0.DatabaseAccessor<i1.GeneratedDatabase> {
  i2.$IdentitiesTableTable get identitiesTable =>
      i3.ReadDatabaseContainer(attachedDatabase).resultSet('identities_table');
  i4.$TraitsTableTable get traitsTable =>
      i3.ReadDatabaseContainer(attachedDatabase).resultSet('traits_table');
}

class $TraitsTableTable extends i6.TraitsTable
    with i0.TableInfo<$TraitsTableTable, i5.Traits> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TraitsTableTable(this.attachedDatabase, [this._alias]);
  static const i0.VerificationMeta _idMeta = const i0.VerificationMeta('id');
  @override
  late final i0.GeneratedColumn<int> id = i0.GeneratedColumn<int>(
      'id', aliasedName, false,
      type: i0.DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: i0.GeneratedColumn.constraintIsAlways(
          'REFERENCES identities_table (id) ON UPDATE CASCADE ON DELETE CASCADE'));
  static const i0.VerificationMeta _denylistMeta =
      const i0.VerificationMeta('denylist');
  @override
  late final i0.GeneratedColumnWithTypeConverter<List<String>, String>
      denylist = i0.GeneratedColumn<String>('denylist', aliasedName, false,
              type: i0.DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<List<String>>(i4.$TraitsTableTable.$converterdenylist);
  static const i0.VerificationMeta _homeTagsMeta =
      const i0.VerificationMeta('homeTags');
  @override
  late final i0.GeneratedColumn<String> homeTags = i0.GeneratedColumn<String>(
      'home_tags', aliasedName, false,
      type: i0.DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<i0.GeneratedColumn> get $columns => [id, denylist, homeTags];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'traits_table';
  @override
  i0.VerificationContext validateIntegrity(i0.Insertable<i5.Traits> instance,
      {bool isInserting = false}) {
    final context = i0.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    context.handle(_denylistMeta, const i0.VerificationResult.success());
    if (data.containsKey('home_tags')) {
      context.handle(_homeTagsMeta,
          homeTags.isAcceptableOrUnknown(data['home_tags']!, _homeTagsMeta));
    } else if (isInserting) {
      context.missing(_homeTagsMeta);
    }
    return context;
  }

  @override
  Set<i0.GeneratedColumn> get $primaryKey => {id};
  @override
  i5.Traits map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i5.Traits(
      id: attachedDatabase.typeMapping
          .read(i0.DriftSqlType.int, data['${effectivePrefix}id'])!,
      denylist: i4.$TraitsTableTable.$converterdenylist.fromSql(attachedDatabase
          .typeMapping
          .read(i0.DriftSqlType.string, data['${effectivePrefix}denylist'])!),
      homeTags: attachedDatabase.typeMapping
          .read(i0.DriftSqlType.string, data['${effectivePrefix}home_tags'])!,
    );
  }

  @override
  $TraitsTableTable createAlias(String alias) {
    return $TraitsTableTable(attachedDatabase, alias);
  }

  static i0.TypeConverter<List<String>, String> $converterdenylist =
      i7.JsonSqlConverter.list<String>();
}

class TraitsCompanion extends i0.UpdateCompanion<i5.Traits> {
  final i0.Value<int> id;
  final i0.Value<List<String>> denylist;
  final i0.Value<String> homeTags;
  const TraitsCompanion({
    this.id = const i0.Value.absent(),
    this.denylist = const i0.Value.absent(),
    this.homeTags = const i0.Value.absent(),
  });
  TraitsCompanion.insert({
    this.id = const i0.Value.absent(),
    required List<String> denylist,
    required String homeTags,
  })  : denylist = i0.Value(denylist),
        homeTags = i0.Value(homeTags);
  static i0.Insertable<i5.Traits> custom({
    i0.Expression<int>? id,
    i0.Expression<String>? denylist,
    i0.Expression<String>? homeTags,
  }) {
    return i0.RawValuesInsertable({
      if (id != null) 'id': id,
      if (denylist != null) 'denylist': denylist,
      if (homeTags != null) 'home_tags': homeTags,
    });
  }

  i4.TraitsCompanion copyWith(
      {i0.Value<int>? id,
      i0.Value<List<String>>? denylist,
      i0.Value<String>? homeTags}) {
    return i4.TraitsCompanion(
      id: id ?? this.id,
      denylist: denylist ?? this.denylist,
      homeTags: homeTags ?? this.homeTags,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (id.present) {
      map['id'] = i0.Variable<int>(id.value);
    }
    if (denylist.present) {
      final converter = i4.$TraitsTableTable.$converterdenylist;

      map['denylist'] = i0.Variable<String>(converter.toSql(denylist.value));
    }
    if (homeTags.present) {
      map['home_tags'] = i0.Variable<String>(homeTags.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TraitsCompanion(')
          ..write('id: $id, ')
          ..write('denylist: $denylist, ')
          ..write('homeTags: $homeTags')
          ..write(')'))
        .toString();
  }
}

class _$TraitsInsertable implements i0.Insertable<i5.Traits> {
  i5.Traits _object;
  _$TraitsInsertable(this._object);
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    return i4.TraitsCompanion(
      id: i0.Value(_object.id),
      denylist: i0.Value(_object.denylist),
      homeTags: i0.Value(_object.homeTags),
    ).toColumns(false);
  }
}

extension TraitsToInsertable on i5.Traits {
  _$TraitsInsertable toInsertable() {
    return _$TraitsInsertable(this);
  }
}
