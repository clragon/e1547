import 'dart:io';

import 'package:drift/drift.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/follow/data/database.drift.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';

// ignore: always_use_package_imports
import 'legacy.drift.dart';

class OldFollowsTable extends Table {
  @override
  String? get tableName => 'follows_table';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get host => text()();
  TextColumn get tags => text()();
  TextColumn get title => text().nullable()();
  TextColumn get alias => text().nullable()();
  TextColumn get type => textEnum<FollowType>()();
  IntColumn get latest => integer().nullable()();
  IntColumn get unseen => integer().nullable()();
  TextColumn get thumbnail => text().nullable()();
  DateTimeColumn get updated => dateTime().nullable()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {host, tags}
      ];
}

@DriftDatabase(tables: [OldFollowsTable])
class OldFollowsDatabase extends $OldFollowsDatabase {
  OldFollowsDatabase(super.e);

  @override
  int get schemaVersion => 1;
}

@Deprecated('Migration will be removed in a future major version')
Future<void> migrateFollows(
    DatabaseConnection followDb, AppStorage storage) async {
  OldFollowsDatabase oldDb = OldFollowsDatabase(followDb);
  AppDatabase db = storage.sqlite;

  List<String> hosts = await (oldDb.selectOnly(oldDb.oldFollowsTable)
        ..addColumns([oldDb.oldFollowsTable.host])
        ..groupBy([oldDb.oldFollowsTable.host]))
      .map((row) => row.read(oldDb.oldFollowsTable.host)!)
      .get();

  Settings settings = Settings(storage.preferences);
  Credentials? credentials = settings.credentials.value;

  IdentitiesService service = IdentitiesService(database: db);

  for (final host in hosts) {
    String normalizedHost = normalizeHostUrl(host);

    Identity? identity = await service
        .page(
          page: 1,
          limit: 1,
          hostRegex: r'^' + RegExp.escape(normalizedHost) + r'$',
          nameRegex: credentials != null
              ? r'^' + RegExp.escape(credentials.username) + r'$'
              : null,
        )
        .then((e) => e.singleOrNull);

    identity ??= await service.add(
      IdentityRequest(
        host: normalizedHost,
        type: ClientType.e621,
        username: credentials?.username,
        headers: QueryMap({
          HttpHeaders.authorizationHeader: credentials?.basicAuth,
        }),
      ),
    );

    await service.activate(identity.id);

    FollowsService followsService = FollowsService(
      database: db,
      identity: identity.id,
    );

    List<OldFollowsTableData> entries =
        await (oldDb.select(oldDb.oldFollowsTable)
              ..where((tbl) => tbl.host.equals(host)))
            .get();

    List<FollowCompanion> requests = [];
    for (final follow in entries) {
      requests.add(
        FollowCompanion.insert(
          tags: follow.tags,
          title: Value(follow.title),
          alias: Value(follow.alias),
          type: follow.type,
          latest: Value(follow.latest),
          updated: Value(follow.updated),
          unseen: Value(follow.unseen),
          thumbnail: Value(follow.thumbnail),
        ),
      );
    }

    await followsService.batch((batch) =>
        batch.insertAllOnConflictUpdate(followsService.followsTable, requests));

    Expression<bool> noLink = followsService.followsTable.id.isNotInQuery(
      followsService.followsIdentitiesTable.selectOnly()
        ..addColumns([followsService.followsIdentitiesTable.follow]),
    );

    List<int> ids = await (followsService.followsTable.selectOnly()
          ..addColumns([followsService.followsTable.id])
          ..where(noLink))
        .map((row) => row.read(followsService.followsTable.id)!)
        .get();

    List<FollowIdentityCompanion> links = [];
    for (final id in ids) {
      links.add(
        FollowIdentityCompanion.insert(
          identity: identity.id,
          follow: id,
        ),
      );
    }

    await followsService.batch((batch) => batch.insertAllOnConflictUpdate(
        followsService.followsIdentitiesTable, links));
  }

  await oldDb.close();
  service.dispose();
}
