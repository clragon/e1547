import 'package:drift/drift.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/traits/traits.dart';

// ignore: always_use_package_imports
import 'database.drift.dart';

@UseRowClass(Traits, generateInsertable: true)
class TraitsTable extends Table {
  IntColumn get id => integer().references(IdentitiesTable, #id,
      onUpdate: KeyAction.cascade, onDelete: KeyAction.cascade)();
  TextColumn get denylist => text().map(JsonSqlConverter.list<String>())();
  TextColumn get homeTags => text()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

@DriftAccessor(tables: [IdentitiesTable, TraitsTable])
class TraitsDao extends DatabaseAccessor<GeneratedDatabase>
    with $TraitsDaoMixin {
  TraitsDao(super.db);

  StreamFuture<Traits> get(int id) {
    return (select(traitsTable)..where((t) => t.id.equals(id)))
        .watchSingle()
        .future;
  }

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
