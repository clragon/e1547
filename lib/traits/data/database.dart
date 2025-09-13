import 'package:drift/drift.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/stream/stream.dart';
import 'package:e1547/traits/data/database.drift.dart';
import 'package:e1547/traits/traits.dart';

@UseRowClass(Traits, generateInsertable: true)
class TraitsTable extends Table {
  IntColumn get id => integer().references(
    IdentitiesTable,
    #id,
    onUpdate: KeyAction.cascade,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get userId => integer().nullable()();
  TextColumn get denylist => text().map(JsonSqlConverter.list<String>())();
  TextColumn get homeTags => text()();
  TextColumn get avatar => text().nullable()();
  IntColumn get perPage => integer().nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

@DriftAccessor(tables: [IdentitiesTable, TraitsTable])
class TraitsRepository extends DatabaseAccessor<GeneratedDatabase>
    with $TraitsRepositoryMixin {
  TraitsRepository(super.db);

  StreamFuture<Traits?> getOrNull(int id) {
    return (select(
      traitsTable,
    )..where((t) => t.id.equals(id))).watchSingleOrNull().future;
  }

  StreamFuture<Traits> get(int id) =>
      getOrNull(id).stream.map((event) => event!).future;

  Future<Traits> add(TraitsRequest value) {
    return into(traitsTable).insertReturning(
      TraitsCompanion(
        id: Value(value.identity),
        denylist: Value(value.denylist),
        homeTags: Value(value.homeTags),
      ),
    );
  }

  Future<void> remove(Traits value) =>
      (delete(traitsTable)..where((t) => t.id.equals(value.id))).go();

  Future<void> replace(Traits value) =>
      update(traitsTable).replace(value.toInsertable());
}
