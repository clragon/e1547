import 'dart:async';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/topic/topic.dart';
import 'package:e1547/traits/traits.dart';
import 'package:e1547/user/user.dart';
import 'package:e1547/wiki/wiki.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:notified_preferences/notified_preferences.dart';
import 'package:rxdart/rxdart.dart';

class HistoryClient with Disposable {
  HistoryClient({
    required this.database,
    required this.preferences,
    required this.identity,
    required this.traits,
  }) : repository = HistoryRepository(database: database);

  final GeneratedDatabase database;
  final Identity identity;
  final ValueNotifier<Traits> traits;
  // TODO: this is jank
  final SharedPreferences preferences;
  final HistoryRepository repository;

  Future<History> get({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  }) => repository.get(id);

  Future<List<History>> page({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) {
    final search = HistoryQuery.maybeFrom(query);
    return repository.page(
      identity: identity.id,
      page: page,
      limit: limit,
      day: search?.date,
      link: search?.link?.infixRegex,
      category: search?.categories,
      type: search?.types,
      title: search?.title?.infixRegex,
      subtitle: search?.subtitle?.infixRegex,
    );
  }

  Future<void> add(HistoryRequest request) =>
      repository.add(request, identity.id);

  Future<void> addMaybe(HistoryRequest request) async {
    if (!enabled) return;
    return repository.transaction(() async {
      if (await repository.isDuplicate(request)) return;
      if (trimming) {
        await repository.trim(
          maxAmount: trimAmount,
          maxAge: trimAge,
          identity: identity.id,
        );
      }
      if (!enabled) return;
      return add(request);
    });
  }

  // section
  // These helper methods hardcoded URLs which is a problem.
  // We need to figure out a way to make them dynamic.

  Future<void> addPost({required Post post}) => addMaybe(
    HistoryRequest(
      visitedAt: DateTime.now(),
      link: post.link,
      category: HistoryCategory.items,
      type: HistoryType.posts,
      subtitle: post.description.nullWhenEmpty,
      thumbnails: _getThumbnails([post]),
    ),
  );

  Future<void> addPostSearch({required QueryMap query, List<Post>? posts}) =>
      addMaybe(
        HistoryRequest(
          visitedAt: DateTime.now(),
          link: Uri(path: '/posts', queryParameters: query).toString(),
          category: HistoryCategory.searches,
          type: HistoryType.posts,
          thumbnails: _getThumbnails(posts),
        ),
      );

  Future<void> addPool({required Pool pool, List<Post>? posts}) => addMaybe(
    HistoryRequest(
      visitedAt: DateTime.now(),
      link: pool.link,
      category: HistoryCategory.items,
      type: HistoryType.pools,
      title: pool.name,
      subtitle: pool.description.nullWhenEmpty,
      thumbnails: _getThumbnails(posts),
    ),
  );

  Future<void> addPoolSearch({
    required QueryMap query,
    List<Pool>? pools,
    List<Post>? posts,
  }) => addMaybe(
    HistoryRequest(
      visitedAt: DateTime.now(),
      link: Uri(path: '/pools', queryParameters: query).toString(),
      category: HistoryCategory.searches,
      type: HistoryType.pools,
      subtitle: pools?.isNotEmpty ?? false
          ? _composeSearchSubtitle({
              for (final value in pools!)
                // TODO: this should be part of the client parser
                value.link: value.name.replaceAll('_', ' '),
            })
          : null,
      thumbnails: [
        if (pools != null)
          ..._getThumbnails(
            posts
                ?.where(
                  (a) => pools
                      .whereNot((e) => e.postIds.isEmpty)
                      .any((b) => b.postIds.first == a.id),
                )
                .toList(),
          ),
      ],
    ),
  );

  Future<void> addTopic({required Topic topic, List<Reply>? replies}) =>
      addMaybe(
        HistoryRequest(
          visitedAt: DateTime.now(),
          link: '/forum_topics/${topic.id}',
          category: HistoryCategory.items,
          type: HistoryType.topics,
          title: topic.title,
          subtitle: replies?.first.body,
        ),
      );

  Future<void> addTopicSearch({required QueryMap query, List<Topic>? topics}) =>
      addMaybe(
        HistoryRequest(
          visitedAt: DateTime.now(),
          link: Uri(path: '/forum_topics', queryParameters: query).toString(),
          category: HistoryCategory.searches,
          type: HistoryType.topics,
          subtitle: topics?.isNotEmpty ?? false
              ? _composeSearchSubtitle({
                  for (final value in topics!) value.link: value.title,
                })
              : null,
        ),
      );

  Future<void> addUser({required User user, Post? avatar}) => addMaybe(
    HistoryRequest(
      visitedAt: DateTime.now(),
      link: '/users/${user.name}',
      category: HistoryCategory.items,
      type: HistoryType.users,
      thumbnails: [if (avatar?.sample != null) avatar!.sample!],
    ),
  );

  Future<void> addWiki({required Wiki wiki}) => addMaybe(
    HistoryRequest(
      visitedAt: DateTime.now(),
      link: '/wiki_pages/${wiki.title}',
      category: HistoryCategory.items,
      type: HistoryType.wikis,
      subtitle: wiki.body.nullWhenEmpty,
    ),
  );

  Future<void> addWikiSearch({required QueryMap query, List<Wiki>? wikis}) =>
      addMaybe(
        HistoryRequest(
          visitedAt: DateTime.now(),
          link: Uri(path: '/wiki_pages', queryParameters: query).toString(),
          category: HistoryCategory.searches,
          type: HistoryType.wikis,
          subtitle: wikis?.isNotEmpty ?? false
              ? _composeSearchSubtitle({
                  for (final value in wikis!) value.link: value.title,
                })
              : null,
        ),
      );

  List<String> _getThumbnails(List<Post>? posts) =>
      posts
          ?.whereNot((e) => e.isDeniedBy(traits.value.denylist))
          .map((e) => e.sample ?? e.preview)
          .nonNulls
          .take(4)
          .toList() ??
      [];

  String _composeSearchSubtitle(Map<String, String> items) => items.entries
      .take(5)
      .map((e) => '* "${e.value.replaceAll(r'"', '\'')}":${e.key}')
      .join('\n');

  // endsection

  Future<void> remove(int id) => removeAll([id]);

  Future<void> removeAll(List<int>? ids) =>
      repository.removeAll(ids, identity: identity.id);

  Future<int> count() => repository.length(identity: identity.id);

  Future<List<DateTime>> days() => repository.days(identity: identity.id);

  bool get enabled => _enabled;
  set enabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
    _enabledStream.add(value);
    preferences.setBool('writeHistory', value);
  }

  // TODO: this should be a trait, not a setting
  late bool _enabled = preferences.getBool('writeHistory') ?? true;

  Stream<bool> get enabledStream => _enabledStream.stream;
  final StreamController<bool> _enabledStream = BehaviorSubject<bool>();

  // TODO: this should be a trait, not a setting
  late bool _trimming = preferences.getBool('trimHistory') ?? false;

  bool get trimming => _trimming;
  set trimming(bool value) {
    if (_trimming == value) return;
    _trimming = value;
    _trimmingStream.add(value);
    preferences.setBool('trimHistory', value);
  }

  Stream<bool> get trimmingStream => _trimmingStream.stream;
  final StreamController<bool> _trimmingStream = BehaviorSubject<bool>();

  int get trimAmount => 5000;

  Duration get trimAge => const Duration(days: 30 * 3);

  @override
  void dispose() {
    _enabledStream.close();
    _trimmingStream.close();
    super.dispose();
  }
}
