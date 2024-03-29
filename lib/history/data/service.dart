import 'package:collection/collection.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/topic/topic.dart';
import 'package:e1547/traits/traits.dart';
import 'package:e1547/user/user.dart';
import 'package:e1547/wiki/wiki.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

abstract class HistoryService {
  ValueNotifier<Traits> get traits;

  Future<History> get({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<List<History>> page({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<void> add(HistoryRequest request);

  Future<void> addMaybe(HistoryRequest request) async {
    if (!enabled) return;
    return add(request);
  }

  // section
  // These helper methods hardcoded URLs which is a problem.
  // We need to figure out a way to make them dynamic.

  Future<void> addPost({required Post post}) => addMaybe(
        HistoryRequest(
          visitedAt: DateTime.now(),
          link: post.link,
          thumbnails: _getThumbnails([post]),
          subtitle: post.description.nullWhenEmpty,
        ),
      );

  Future<void> addPostSearch({
    required QueryMap query,
    List<Post>? posts,
  }) =>
      addMaybe(
        HistoryRequest(
          visitedAt: DateTime.now(),
          link: Uri(
            path: '/posts',
            queryParameters: query,
          ).toString(),
          thumbnails: _getThumbnails(posts),
        ),
      );

  Future<void> addPool({
    required Pool pool,
    List<Post>? posts,
  }) =>
      addMaybe(
        HistoryRequest(
          visitedAt: DateTime.now(),
          link: pool.link,
          thumbnails: _getThumbnails(posts),
          title: pool.name,
          subtitle: pool.description.nullWhenEmpty,
        ),
      );

  Future<void> addPoolSearch({
    required QueryMap query,
    List<Pool>? pools,
    List<Post>? posts,
  }) =>
      addMaybe(
        HistoryRequest(
          visitedAt: DateTime.now(),
          link: Uri(
            path: '/pools',
            queryParameters: query,
          ).toString(),
          thumbnails: [
            if (pools != null)
              ..._getThumbnails(
                posts
                    ?.where((a) => pools
                        .whereNot((e) => e.postIds.isEmpty)
                        .any((b) => b.postIds.first == a.id))
                    .toList(),
              )
          ],
          subtitle: pools?.isNotEmpty ?? false
              ? _composeSearchSubtitle({
                  for (final value in pools!)
                    value.link: value.name.replaceAll('_', ' ')
                })
              : null,
        ),
      );

  Future<void> addTopic({
    required Topic topic,
    List<Reply>? replies,
  }) =>
      addMaybe(
        HistoryRequest(
          visitedAt: DateTime.now(),
          link: '/forum_topics/${topic.id}',
          title: topic.title,
          subtitle: replies?.first.body,
        ),
      );

  Future<void> addTopicSearch({
    required QueryMap query,
    List<Topic>? topics,
  }) =>
      addMaybe(
        HistoryRequest(
          visitedAt: DateTime.now(),
          link: Uri(
            path: '/forum_topics',
            queryParameters: query,
          ).toString(),
          subtitle: topics?.isNotEmpty ?? false
              ? _composeSearchSubtitle(
                  {for (final value in topics!) value.link: value.title},
                )
              : null,
        ),
      );

  Future<void> addUser({required User user, Post? avatar}) => addMaybe(
        HistoryRequest(
          visitedAt: DateTime.now(),
          link: '/users/${user.name}',
          thumbnails: [if (avatar?.sample != null) avatar!.sample!],
        ),
      );

  Future<void> addWiki({required Wiki wiki}) => addMaybe(
        HistoryRequest(
          visitedAt: DateTime.now(),
          link: '/wiki_pages/${wiki.title}',
          subtitle: wiki.body.nullWhenEmpty,
        ),
      );

  Future<void> addWikiSearch({
    required QueryMap query,
    List<Wiki>? wikis,
  }) =>
      addMaybe(
        HistoryRequest(
          visitedAt: DateTime.now(),
          link: Uri(
            path: '/wiki_pages',
            queryParameters: query,
          ).toString(),
          subtitle: wikis?.isNotEmpty ?? false
              ? _composeSearchSubtitle(
                  {for (final value in wikis!) value.link: value.title})
              : null,
        ),
      );

  List<String> _getThumbnails(List<Post>? posts) =>
      posts
          ?.whereNot((e) => e.isDeniedBy(traits.value.denylist))
          .map((e) => e.sample)
          .whereNotNull()
          .take(4)
          .toList() ??
      [];

  String _composeSearchSubtitle(Map<String, String> items) => items.entries
      .take(5)
      .map((e) => '* "${e.value.replaceAll(r'"', '\'')}":${e.key}')
      .join('\n');

  // endsection

  Future<void> remove(int id) => removeAll([id]);

  Future<void> removeAll(List<int>? ids);

  Future<int> count();

  Future<List<DateTime>> days();

  bool get enabled;
  set enabled(bool value);

  Stream<bool> get enabledStream;

  bool get trimming;
  set trimming(bool value);

  Stream<bool> get trimmingStream;

  int get trimAmount;
  Duration get trimAge;
}

extension type HistoryQuery._(QueryMap self) implements QueryMap {
  factory HistoryQuery({
    DateTime? date,
    String? link,
    String? title,
    String? subtitle,
    List<HistoryCategory>? categories,
    List<HistoryType>? types,
  }) {
    return HistoryQuery._({
      'search[date]': date != null ? _dateFormat.format(date) : null,
      'search[link]': link,
      'search[title]': title,
      'search[subtitle]': subtitle,
      'search[category]': categories?.map((e) => e.name).join(','),
      'search[type]': types?.map((e) => e.name).join(','),
    }.toQuery());
  }

  HistoryQuery.from(QueryMap map) : this._(map);

  static HistoryQuery? maybeFrom(QueryMap? map) {
    if (map == null) return null;
    return HistoryQuery.from(map);
  }

  HistoryQuery copy() => HistoryQuery.from(Map.of(self));

  static DateFormat get _dateFormat => DateFormat('yyyy-MM-dd');

  DateTime? get date {
    try {
      return _dateFormat.parse(self['search[date]'] ?? '');
    } on FormatException {
      return null;
    }
  }

  set date(DateTime? value) => setOrRemove(
      'search[date]', value != null ? _dateFormat.format(value) : null);

  String? get link => self['search[link]'];

  set link(String? value) => setOrRemove('search[link]', value);

  String? get title => self['search[title]'];

  set title(String? value) => setOrRemove('search[title]', value);

  String? get subtitle => self['search[subtitle]'];

  set subtitle(String? value) => setOrRemove('search[subtitle]', value);

  List<HistoryCategory>? get categories => self['search[category]']
      ?.split(',')
      .map((e) => HistoryCategory.values.asNameMap()[e])
      .whereType<HistoryCategory>()
      .toList();

  set categories(List<HistoryCategory>? value) =>
      setOrRemove('search[category]', value?.map((e) => e.name).join(','));

  List<HistoryType>? get types => self['search[type]']
      ?.split(',')
      .map((e) => HistoryType.values.asNameMap()[e])
      .whereType<HistoryType>()
      .toList();

  set types(List<HistoryType>? value) =>
      setOrRemove('search[type]', value?.map((e) => e.name).join(','));
}

enum HistoryCategory {
  items,
  searches,
}

enum HistoryType {
  posts,
  pools,
  topics,
  users,
  wikis,
}
