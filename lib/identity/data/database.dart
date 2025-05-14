import 'dart:math';

import 'package:drift/drift.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/interface/interface.dart';

class NullToEmptyStringSqlConverter extends TypeConverter<String?, String> {
  const NullToEmptyStringSqlConverter();

  @override
  String? fromSql(String fromDb) => fromDb.isEmpty ? null : fromDb;

  @override
  String toSql(String? value) => value ?? '';
}

@UseRowClass(Identity, generateInsertable: true)
class IdentitiesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get host => text()();
  TextColumn get username =>
      text().map(const NullToEmptyStringSqlConverter())();
  TextColumn get headers =>
      text().nullable().map(JsonSqlConverter.map<String>())();

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
        {host, username},
      ];
}

@DriftAccessor(tables: [IdentitiesTable])
class IdentityRepository extends DatabaseAccessor<GeneratedDatabase>
    with $IdentityRepositoryMixin {
  IdentityRepository(super.db);

  StreamFuture<int> length() {
    final Expression<int> count = identitiesTable.id.count();

    return (selectOnly(identitiesTable)..addColumns([count]))
        .map((row) => row.read(count)!)
        .watchSingle()
        .future;
  }

  StreamFuture<Identity?> getOrNull(int id) =>
      (select(identitiesTable)..where((tbl) => tbl.id.equals(id)))
          .watchSingleOrNull()
          .future;

  StreamFuture<Identity> get(int id) =>
      getOrNull(id).stream.map((e) => e!).future;

  SimpleSelectStatement<IdentitiesTable, Identity> _queryExpression({
    String? nameRegex,
    String? hostRegex,
    int? limit,
    int? offset,
  }) {
    final selectable = select(identitiesTable)
      ..orderBy([
        (t) => OrderingTerm(expression: t.host),
        (t) => OrderingTerm(expression: t.username)
      ]);
    if (nameRegex != null) {
      selectable
          .where((tbl) => tbl.username.regexp(nameRegex, caseSensitive: false));
    }
    if (hostRegex != null) {
      selectable
          .where((tbl) => tbl.host.regexp(hostRegex, caseSensitive: false));
    }
    assert(
      offset == null || limit != null,
      'Cannot specify offset without limit!',
    );
    if (limit != null) {
      selectable.limit(limit, offset: offset);
    }
    return selectable;
  }

  StreamFuture<List<Identity>> page({
    required int page,
    int? limit,
    String? nameRegex,
    String? hostRegex,
  }) {
    limit ??= 80;
    int offset = (max(1, page) - 1) * limit;
    return _queryExpression(
      nameRegex: nameRegex,
      hostRegex: hostRegex,
      limit: limit,
      offset: offset,
    ).watch().future;
  }

  StreamFuture<List<Identity>> all({
    String? nameRegex,
    String? hostRegex,
  }) {
    return _queryExpression(
      nameRegex: nameRegex,
      hostRegex: hostRegex,
    ).watch().future;
  }

  Future<Identity> add(IdentityRequest item) async =>
      into(identitiesTable).insertReturning(item.toCompanion());

  Future<void> addAll(List<IdentityRequest> items) async => batch(
        (batch) => batch.insertAll(
          identitiesTable,
          items.map((item) => item.toCompanion()),
        ),
      );

  Future<void> remove(Identity item) async =>
      (delete(identitiesTable)..where((tbl) => tbl.id.equals(item.id))).go();

  Future<void> removeAll(List<Identity> items) async => (delete(identitiesTable)
        ..where((tbl) => tbl.id.isIn(items.map((e) => e.id))))
      .go();

  Future<void> replace(Identity item) async =>
      (update(identitiesTable)..where((tbl) => tbl.id.equals(item.id)))
          .write(item.toInsertable());
}

extension IdentityRequestCompanion on IdentityRequest {
  IdentityCompanion toCompanion() => IdentityCompanion(
        host: Value(normalizeHostUrl(host)),
        username: Value(username),
        headers: Value(headers),
      );
}
