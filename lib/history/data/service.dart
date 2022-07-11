import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class HistoriesService extends ChangeNotifier {
  final Settings settings;
  final Client client;

  HistoriesService({required this.settings, required this.client, String? path})
      : _database = HistoriesDatabase.connect(path: path) {
    client.addListener(notifyListeners);
    settings.writeHistory.addListener(notifyListeners);
  }

  final HistoriesDatabase _database;
  set enabled(bool value) => settings.writeHistory.value = value;
  bool get enabled => settings.writeHistory.value;
  String get host => client.host;

  Future<History> get(int id) async => _database.get(id);

  Future<List<History>> page({
    int page = 1,
    int limit = 80,
    String? linkRegex,
    DateTime? day,
  }) async =>
      _database.page(
        host: client.host,
        page: page,
        limit: limit,
        linkRegex: linkRegex,
        day: day,
      );

  Future<int> get length => _database.length(host: client.host);

  Future<void> add(HistoryRequest item) async {
    if (!enabled) {
      return;
    }
    if ((await _database.getRecent(host: client.host)).any((e) =>
        e.link == item.link &&
        e.title == item.title &&
        e.subtitle == item.subtitle &&
        const DeepCollectionEquality().equals(e.thumbnails, item.thumbnails))) {
      return;
    }
    // TODO: enable this? check performance impact!
    // await trim();
    return _database.add(client.host, item);
  }

  Future<void> addAll(List<HistoryRequest> items) async {
    // TODO: implement this
    throw UnimplementedError();
  }

  Future<void> remove(History item) async => _database.remove(item);

  Future<void> removeAll(List<History> items) async =>
      _database.removeAll(items);

  List<String> _getThumbnails(List<Post>? posts) =>
      posts
          ?.where((e) => !e.isDeniedBy(denylistController.items))
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

  Future<void> addPool(Pool pool, {List<Post>? posts}) async => add(
        HistoryRequest(
          visitedAt: DateTime.now(),
          link: pool.link,
          thumbnails: _getThumbnails(posts),
          title: pool.name,
          subtitle: pool.description,
        ),
      );

  Future<void> addTag(String tag, {String? alias, List<Post>? posts}) async =>
      add(
        HistoryRequest(
          visitedAt: DateTime.now(),
          link: Tagset.parse(tag).link,
          thumbnails: _getThumbnails(posts),
          title: alias,
        ),
      );

  // TODO: create setting to regulate this
  Future<void> trim() async => _database.trim(
      host: client.host, maxAmount: 3000, maxAge: const Duration(days: 30));
}

class HistoriesProvider extends SelectiveChangeNotifierProvider2<Settings,
    Client, HistoriesService> {
  HistoriesProvider({String? path})
      : super(
          create: (context, settings, client) => HistoriesService(
            path: path,
            settings: settings,
            client: client,
          ),
          dispose: (context, value) => value.dispose(),
        );
}
