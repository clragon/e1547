import 'dart:io';

import 'package:drift/drift.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/history/data/database.drift.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';

// ignore: always_use_package_imports
import 'legacy.drift.dart';

class OldHistoriesTable extends Table {
  @override
  String? get tableName => 'histories_table';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get host => text()();
  DateTimeColumn get visitedAt => dateTime()();
  TextColumn get link => text()();
  TextColumn get thumbnails => text().map(JsonSqlConverter.list<String>())();
  TextColumn get title => text().nullable()();
  TextColumn get subtitle => text().nullable()();
}

@DriftDatabase(tables: [OldHistoriesTable])
class OldHistoriesDatabase extends $OldHistoriesDatabase {
  OldHistoriesDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            String linkRegex = r'/posts\?tags=(?<tags>.+)';

            List<OldHistoriesTableData> entries =
                await (select(oldHistoriesTable)
                      ..where((tbl) =>
                          tbl.link.regexp(linkRegex, caseSensitive: false)))
                    .get();

            for (final entry in entries) {
              String tags =
                  RegExp(linkRegex).firstMatch(entry.link)!.namedGroup('tags')!;

              try {
                String decoded = Uri.decodeQueryComponent(tags);
                if (decoded != tags) {
                  tags = decoded;
                }
              }
              // ignore: avoid_catching_errors
              on ArgumentError {
                // url is not encoded
              }

              String link = Uri(
                path: '/posts',
                queryParameters: {'tags': tags},
              ).toString();

              await (update(oldHistoriesTable)
                    ..where((tbl) => tbl.id.equals(entry.id)))
                  .write(OldHistoriesTableDataCompanion(
                link: Value(link),
              ));
            }
          }
        },
      );
}

@Deprecated('Migration will be removed in a future major version')
Future<void> migrateHistory(
    DatabaseConnection? historyDb, AppStorage storage) async {
  if (historyDb == null) return;
  OldHistoriesDatabase oldDb = OldHistoriesDatabase(historyDb);
  AppDatabase db = storage.sqlite;

  List<String> hosts = await (oldDb.selectOnly(oldDb.oldHistoriesTable)
        ..addColumns([oldDb.oldHistoriesTable.host])
        ..groupBy([oldDb.oldHistoriesTable.host]))
      .map((row) => row.read(oldDb.oldHistoriesTable.host)!)
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
        headers: TagMap({
          HttpHeaders.authorizationHeader: credentials?.basicAuth,
        }),
      ),
    );

    await service.activate(identity.id);

    HistoriesDao historiesService = HistoriesDao(
      database: db,
      identity: identity.id,
    );

    List<OldHistoriesTableData> entries =
        await (oldDb.select(oldDb.oldHistoriesTable)
              ..where((tbl) => tbl.host.equals(host)))
            .get();

    List<HistoryCompanion> requests = [];
    for (final history in entries) {
      requests.add(
        HistoryCompanion.insert(
          link: history.link,
          visitedAt: history.visitedAt,
          thumbnails: history.thumbnails,
          title: Value(history.title),
          subtitle: Value(history.subtitle),
        ),
      );
    }

    await historiesService.batch((batch) {
      batch.insertAllOnConflictUpdate(
        historiesService.historiesTable,
        requests,
      );
    });

    Expression<bool> noLink = historiesService.historiesTable.id.isNotInQuery(
      historiesService.historiesIdentitiesTable.selectOnly()
        ..addColumns([historiesService.historiesIdentitiesTable.history]),
    );

    List<int> ids = await (historiesService.historiesTable.selectOnly()
          ..addColumns([historiesService.historiesTable.id])
          ..where(noLink))
        .map((row) => row.read(historiesService.historiesTable.id)!)
        .get();

    List<HistoryIdentityCompanion> links = [];
    for (final id in ids) {
      links.add(
        HistoryIdentityCompanion.insert(
          identity: identity.id,
          history: id,
        ),
      );
    }

    await historiesService.batch((batch) {
      batch.insertAllOnConflictUpdate(
        historiesService.historiesIdentitiesTable,
        links,
      );
    });
  }

  await oldDb.close();
  service.dispose();
}
