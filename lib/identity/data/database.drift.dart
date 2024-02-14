// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:drift/src/runtime/api/runtime_api.dart' as i1;
import 'package:e1547/identity/data/database.drift.dart' as i2;
import 'package:drift/internal/modular.dart' as i3;
import 'package:e1547/identity/data/identity.dart' as i4;
import 'package:e1547/client/data/factory.dart' as i5;
import 'package:e1547/identity/data/database.dart' as i6;
import 'package:e1547/interface/data/sql.dart' as i7;

mixin $IdentitiesDaoMixin on i0.DatabaseAccessor<i1.GeneratedDatabase> {
  i2.$IdentitiesTableTable get identitiesTable =>
      i3.ReadDatabaseContainer(attachedDatabase).resultSet('identities_table');
}

class $IdentitiesTableTable extends i6.IdentitiesTable
    with i0.TableInfo<$IdentitiesTableTable, i4.Identity> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IdentitiesTableTable(this.attachedDatabase, [this._alias]);
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
  static const i0.VerificationMeta _typeMeta =
      const i0.VerificationMeta('type');
  @override
  late final i0.GeneratedColumnWithTypeConverter<i5.ClientType, String> type =
      i0.GeneratedColumn<String>('type', aliasedName, false,
              type: i0.DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<i5.ClientType>(
              i2.$IdentitiesTableTable.$convertertype);
  static const i0.VerificationMeta _usernameMeta =
      const i0.VerificationMeta('username');
  @override
  late final i0.GeneratedColumnWithTypeConverter<String?, String> username =
      i0.GeneratedColumn<String>('username', aliasedName, false,
              type: i0.DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<String?>(i2.$IdentitiesTableTable.$converterusername);
  static const i0.VerificationMeta _headersMeta =
      const i0.VerificationMeta('headers');
  @override
  late final i0.GeneratedColumnWithTypeConverter<Map<String, String>?, String>
      headers = i0.GeneratedColumn<String>('headers', aliasedName, true,
              type: i0.DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Map<String, String>?>(
              i2.$IdentitiesTableTable.$converterheadersn);
  @override
  List<i0.GeneratedColumn> get $columns => [id, host, type, username, headers];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'identities_table';
  @override
  i0.VerificationContext validateIntegrity(i0.Insertable<i4.Identity> instance,
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
    context.handle(_typeMeta, const i0.VerificationResult.success());
    context.handle(_usernameMeta, const i0.VerificationResult.success());
    context.handle(_headersMeta, const i0.VerificationResult.success());
    return context;
  }

  @override
  Set<i0.GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<i0.GeneratedColumn>> get uniqueKeys => [
        {host, username},
      ];
  @override
  i4.Identity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i4.Identity(
      id: attachedDatabase.typeMapping
          .read(i0.DriftSqlType.int, data['${effectivePrefix}id'])!,
      host: attachedDatabase.typeMapping
          .read(i0.DriftSqlType.string, data['${effectivePrefix}host'])!,
      type: i2.$IdentitiesTableTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(i0.DriftSqlType.string, data['${effectivePrefix}type'])!),
      username: i2.$IdentitiesTableTable.$converterusername.fromSql(
          attachedDatabase.typeMapping.read(
              i0.DriftSqlType.string, data['${effectivePrefix}username'])!),
      headers: i2.$IdentitiesTableTable.$converterheadersn.fromSql(
          attachedDatabase.typeMapping
              .read(i0.DriftSqlType.string, data['${effectivePrefix}headers'])),
    );
  }

  @override
  $IdentitiesTableTable createAlias(String alias) {
    return $IdentitiesTableTable(attachedDatabase, alias);
  }

  static i0.JsonTypeConverter2<i5.ClientType, String, String> $convertertype =
      const i0.EnumNameConverter<i5.ClientType>(i5.ClientType.values);
  static i0.TypeConverter<String?, String> $converterusername =
      const i6.NullToEmptyStringSqlConverter();
  static i0.TypeConverter<Map<String, String>, String> $converterheaders =
      i7.JsonSqlConverter.map<String>();
  static i0.TypeConverter<Map<String, String>?, String?> $converterheadersn =
      i0.NullAwareTypeConverter.wrap($converterheaders);
}

class IdentityCompanion extends i0.UpdateCompanion<i4.Identity> {
  final i0.Value<int> id;
  final i0.Value<String> host;
  final i0.Value<i5.ClientType> type;
  final i0.Value<String?> username;
  final i0.Value<Map<String, String>?> headers;
  const IdentityCompanion({
    this.id = const i0.Value.absent(),
    this.host = const i0.Value.absent(),
    this.type = const i0.Value.absent(),
    this.username = const i0.Value.absent(),
    this.headers = const i0.Value.absent(),
  });
  IdentityCompanion.insert({
    this.id = const i0.Value.absent(),
    required String host,
    required i5.ClientType type,
    required String? username,
    this.headers = const i0.Value.absent(),
  })  : host = i0.Value(host),
        type = i0.Value(type),
        username = i0.Value(username);
  static i0.Insertable<i4.Identity> custom({
    i0.Expression<int>? id,
    i0.Expression<String>? host,
    i0.Expression<String>? type,
    i0.Expression<String>? username,
    i0.Expression<String>? headers,
  }) {
    return i0.RawValuesInsertable({
      if (id != null) 'id': id,
      if (host != null) 'host': host,
      if (type != null) 'type': type,
      if (username != null) 'username': username,
      if (headers != null) 'headers': headers,
    });
  }

  i2.IdentityCompanion copyWith(
      {i0.Value<int>? id,
      i0.Value<String>? host,
      i0.Value<i5.ClientType>? type,
      i0.Value<String?>? username,
      i0.Value<Map<String, String>?>? headers}) {
    return i2.IdentityCompanion(
      id: id ?? this.id,
      host: host ?? this.host,
      type: type ?? this.type,
      username: username ?? this.username,
      headers: headers ?? this.headers,
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
    if (type.present) {
      map['type'] = i0.Variable<String>(
          i2.$IdentitiesTableTable.$convertertype.toSql(type.value));
    }
    if (username.present) {
      map['username'] = i0.Variable<String>(
          i2.$IdentitiesTableTable.$converterusername.toSql(username.value));
    }
    if (headers.present) {
      map['headers'] = i0.Variable<String>(
          i2.$IdentitiesTableTable.$converterheadersn.toSql(headers.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IdentityCompanion(')
          ..write('id: $id, ')
          ..write('host: $host, ')
          ..write('type: $type, ')
          ..write('username: $username, ')
          ..write('headers: $headers')
          ..write(')'))
        .toString();
  }
}

class _$IdentityInsertable implements i0.Insertable<i4.Identity> {
  i4.Identity _object;
  _$IdentityInsertable(this._object);
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    return i2.IdentityCompanion(
      id: i0.Value(_object.id),
      host: i0.Value(_object.host),
      type: i0.Value(_object.type),
      username: i0.Value(_object.username),
      headers: i0.Value(_object.headers),
    ).toColumns(false);
  }
}

extension IdentityToInsertable on i4.Identity {
  _$IdentityInsertable toInsertable() {
    return _$IdentityInsertable(this);
  }
}
