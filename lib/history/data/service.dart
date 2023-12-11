import 'package:collection/collection.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/topic/topic.dart';
import 'package:e1547/user/user.dart';
import 'package:e1547/wiki/wiki.dart';
import 'package:flutter/material.dart';

class HistoriesService extends HistoriesDao with ChangeNotifier {
  HistoriesService({
    required super.database,
    required super.identity,
    bool enabled = true,
    bool trimming = false,
    int trimAmount = 5000,
    Duration trimAge = const Duration(days: 90),
  })  : _enabled = enabled,
        _trimming = trimming,
        _trimAmount = trimAmount,
        _trimAge = trimAge;

  bool _enabled;

  bool get enabled => _enabled;

  set enabled(bool value) {
    if (_enabled != value) {
      _enabled = value;
      notifyListeners();
    }
  }

  bool _trimming;

  bool get trimming => _trimming;

  set trimming(bool value) {
    if (_trimming != value) {
      _trimming = value;
      notifyListeners();
    }
  }

  int _trimAmount;

  int get trimAmount => _trimAmount;

  set trimAmount(int value) {
    if (_trimAmount != value) {
      _trimAmount = value;
      notifyListeners();
    }
  }

  Duration _trimAge;

  Duration get trimAge => _trimAge;

  set trimAge(Duration value) {
    if (_trimAge != value) {
      _trimAge = value;
      notifyListeners();
    }
  }

  @override
  Future<void> add(HistoryRequest item, {int? identity}) async {
    if (!enabled) {
      return;
    }
    return transaction(() async {
      if ((await recent().first).any((e) =>
          e.link == item.link &&
          e.title == item.title &&
          e.subtitle == item.subtitle &&
          const DeepCollectionEquality()
              .equals(e.thumbnails, item.thumbnails))) {
        return;
      }
      if (trimming) {
        await trim();
      }
      return super.add(item);
    });
  }

  List<String> _getThumbnails(List<Post>? posts, {List<String>? denylist}) =>
      posts
          ?.where((e) => denylist == null || !e.isDeniedBy(denylist))
          .map((e) => e.sample.url)
          .where((e) => e != null)
          .cast<String>()
          .take(4)
          .toList() ??
      [];

  String _composeSearchSubtitle(Map<String, String> items) => items.entries
      .take(5)
      .map((e) => '* "${e.value.replaceAll(r'"', '\'')}":${e.key}')
      .join('\n');

  Future<void> addPost(
    Post post, {
    List<String>? denylist,
  }) =>
      add(
        HistoryRequest(
          visitedAt: DateTime.now(),
          link: post.link,
          thumbnails: _getThumbnails([post], denylist: denylist),
          subtitle: post.description.nullWhenEmpty,
        ),
      );

  Future<void> addPostSearch(
    Map<String, String> search, {
    List<Post>? posts,
  }) =>
      add(
        HistoryRequest(
          visitedAt: DateTime.now(),
          link: Uri(
            path: '/posts',
            queryParameters: search.isNotEmpty ? search : null,
          ).toString(),
          thumbnails: _getThumbnails(posts),
        ),
      );

  Future<void> addPool(
    Pool pool, {
    List<Post>? posts,
  }) =>
      add(
        HistoryRequest(
          visitedAt: DateTime.now(),
          link: pool.link,
          thumbnails: _getThumbnails(posts),
          title: pool.name,
          subtitle: pool.description.nullWhenEmpty,
        ),
      );

  Future<void> addPoolSearch(
    Map<String, String> search, {
    List<Pool>? pools,
  }) =>
      add(
        HistoryRequest(
          visitedAt: DateTime.now(),
          link: Uri(
            path: '/pools',
            queryParameters: search.isNotEmpty ? search : null,
          ).toString(),
          subtitle: pools?.isNotEmpty ?? false
              ? _composeSearchSubtitle({
                  for (final value in pools!) value.link: tagToName(value.name)
                })
              : null,
        ),
      );

  Future<void> addTopic(
    Topic topic, {
    List<Reply>? replies,
  }) =>
      add(
        HistoryRequest(
          visitedAt: DateTime.now(),
          link: '/forum_topics/${topic.id}',
          title: topic.title,
          subtitle: replies?.first.body,
        ),
      );

  Future<void> addTopicSearch(
    Map<String, String> search, {
    List<Topic>? topics,
  }) =>
      add(
        HistoryRequest(
          visitedAt: DateTime.now(),
          link: Uri(
            path: '/forum_topics',
            queryParameters: search.isNotEmpty ? search : null,
          ).toString(),
          subtitle: topics?.isNotEmpty ?? false
              ? _composeSearchSubtitle(
                  {for (final value in topics!) value.link: value.title},
                )
              : null,
        ),
      );

  Future<void> addUser(User user, {Post? avatar}) => add(
        HistoryRequest(
          visitedAt: DateTime.now(),
          link: '/users/${user.name}',
          thumbnails: [if (avatar?.sample.url != null) avatar!.sample.url!],
        ),
      );

  Future<void> addWiki(Wiki wiki) => add(
        HistoryRequest(
          visitedAt: DateTime.now(),
          link: '/wiki_pages/${wiki.title}',
          subtitle: wiki.body.nullWhenEmpty,
        ),
      );

  Future<void> addWikiSearch(
    String search, {
    List<Wiki>? wikis,
  }) =>
      add(
        HistoryRequest(
          visitedAt: DateTime.now(),
          link: Uri(
            path: '/wiki_pages',
            queryParameters:
                search.isNotEmpty ? {'search[title]': search} : null,
          ).toString(),
          subtitle: wikis?.isNotEmpty ?? false
              ? _composeSearchSubtitle(
                  {for (final value in wikis!) value.link: value.title})
              : null,
        ),
      );

  @override
  Future<void> trim({
    String? host,
    int? maxAmount,
    Duration? maxAge,
  }) =>
      trim(
        host: host,
        maxAmount: maxAmount ?? trimAmount,
        maxAge: maxAge ?? trimAge,
      );
}
