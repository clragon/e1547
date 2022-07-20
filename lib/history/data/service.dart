import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';
import 'package:mutex/mutex.dart';

class HistoriesService extends ChangeNotifier {
  final Settings settings;
  final Client client;
  final DenylistService denylist;

  final HistoriesDatabase _database;

  set enabled(bool value) => settings.writeHistory.value = value;
  bool get enabled => settings.writeHistory.value;
  set trimming(bool value) => settings.trimHistory.value = value;
  bool get trimming => settings.trimHistory.value;
  String get host => client.host;

  final int trimAmount = 3000;
  final Duration trimAge = const Duration(days: 90);

  final Mutex _lock = Mutex();

  HistoriesService({
    required this.settings,
    required this.client,
    required this.denylist,
    String? path,
  }) : _database = HistoriesDatabase.connect(path: path) {
    client.addListener(notifyListeners);
    settings.writeHistory.addListener(notifyListeners);
    settings.trimHistory.addListener(notifyListeners);
  }

  @override
  void dispose() {
    client.removeListener(notifyListeners);
    settings.writeHistory.removeListener(notifyListeners);
    settings.trimHistory.removeListener(notifyListeners);
    super.dispose();
  }

  Future<int> length() async => _database.length(host: host);
  Stream<int> watchLength() => _database.watchLength(host: host);

  Future<List<DateTime>> dates() async => _database.dates(host: host);

  Future<History> get(int id) async => _database.get(id);
  Stream<History> watch(int id) => _database.watch(id);

  Future<List<History>> getAll({
    String? linkRegex,
    DateTime? day,
  }) async =>
      _database.getAll(
        host: host,
        linkRegex: linkRegex,
        day: day,
      );

  Stream<List<History>> watchAll({
    String? linkRegex,
    DateTime? day,
  }) =>
      _database.watchAll(
        host: host,
        linkRegex: linkRegex,
        day: day,
      );

  Future<List<History>> page({
    int page = 1,
    int limit = 80,
    String? linkRegex,
    DateTime? day,
  }) async =>
      _database.page(
        host: host,
        page: page,
        limit: limit,
        linkRegex: linkRegex,
        day: day,
      );

  Future<void> add(HistoryRequest item) async => _lock.protect(
        () async {
          if (!enabled) {
            return;
          }
          if ((await _database.getRecent(host: host)).any((e) =>
              e.link == item.link &&
              e.title == item.title &&
              e.subtitle == item.subtitle &&
              const DeepCollectionEquality()
                  .equals(e.thumbnails, item.thumbnails))) {
            return;
          }
          await trim();
          return _database.add(host, item);
        },
      );

  Future<void> addAll(List<HistoryRequest> items) async =>
      _lock.protect(() async => _database.addAll(host, items));

  Future<void> remove(History item) async =>
      _lock.protect(() async => _database.remove(item));

  Future<void> removeAll(List<History> items) async =>
      _lock.protect(() async => _database.removeAll(items));

  List<String> _getThumbnails(List<Post>? posts) =>
      posts
          ?.where((e) => !e.isDeniedBy(denylist.items))
          .map((e) => e.sample.url)
          .where((e) => e != null)
          .cast<String>()
          .take(4)
          .toList() ??
      [];

  Future<void> addPost(Post post) async => add(
        HistoryRequest(
          visitedAt: DateTime.now(),
          link: post.link,
          thumbnails: _getThumbnails([post]),
        ),
      );

  Future<void> addPostSearch(
    String search, {
    String? alias,
    List<Post>? posts,
  }) async =>
      add(
        HistoryRequest(
          visitedAt: DateTime.now(),
          link: Tagset.parse(search).link,
          thumbnails: _getThumbnails(posts),
          title: alias,
        ),
      );

  Future<void> addPool(Pool pool, {List<Post>? posts}) async => add(
        HistoryRequest(
          visitedAt: DateTime.now(),
          link: pool.link,
          thumbnails: _getThumbnails(posts),
          title: pool.name,
          subtitle: pool.description,
        ),
      );

  Future<void> addPoolSearch(
    String search, {
    List<Pool>? pools,
  }) async =>
      add(
        HistoryRequest(
          visitedAt: DateTime.now(),
          link: Uri(path: '/pools', queryParameters: {
            'search[name_matches]': search,
          }).toString(),
        ),
      );

  Future<void> addUser(User user, {Post? avatar}) async => add(
        HistoryRequest(
          visitedAt: DateTime.now(),
          link: '/users/${user.name}',
          thumbnails: [if (avatar?.sample.url != null) avatar!.sample.url!],
        ),
      );

  Future<void> trim() async =>
      _database.trim(host: client.host, maxAmount: trimAmount, maxAge: trimAge);
}

class HistoriesProvider extends SubChangeNotifierProvider3<Settings, Client,
    DenylistService, HistoriesService> {
  HistoriesProvider({String? path, super.child, super.builder})
      : super(
          create: (context, settings, client, denylist) => HistoriesService(
            path: path,
            settings: settings,
            client: client,
            denylist: denylist,
          ),
          selector: (context) => [path],
        );
}
