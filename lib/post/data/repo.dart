import 'package:collection/collection.dart';
import 'package:e1547/domain/domain.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/stream/stream.dart';

class PostRepo {
  PostRepo({required this.persona, required this.client, required this.cache});

  final Persona persona;
  final PostClient client;
  final CachedQuery cache;

  final String queryKey = 'posts';

  late final _postCache = cache.bridge<Post, int>(
    queryKey,
    fetch: (id) => get(id: id),
  );

  Future<Post> get({required int id, CancelToken? cancelToken}) =>
      client.get(id: id, cancelToken: cancelToken);

  Query<Post> useGet({required int id, bool? vendored}) => Query(
    cache: cache,
    key: [queryKey, id],
    queryFn: () => get(id: id),
    config: _postCache.getConfig(vendored: vendored),
  );

  Future<List<Post>> page({
    int? page,
    int? limit,
    QueryMap? query,
    CancelToken? cancelToken,
  }) => client
      .page(page: page, limit: limit, query: query, cancelToken: cancelToken)
      .map(_filter);

  InfiniteQuery<List<int>, int> usePage({required QueryMap? query}) =>
      InfiniteQuery<List<int>, int>(
        cache: cache,
        key: [queryKey, query],
        getNextArg: (state) => state.nextPage,
        queryFn: (key) =>
            page(page: key, query: query).then(_postCache.savePage),
      );

  Future<List<Post>> hot({
    int? page,
    int? limit,
    QueryMap? query,
    CancelToken? cancelToken,
  }) => client
      .page(
        page: page,
        limit: limit,
        query: {...?query, 'tags': '${query?['tags'] ?? ''} order:rank'.trim()},
        cancelToken: cancelToken,
      )
      .map(_filter);

  InfiniteQuery<List<int>, int> useHot({QueryMap? query}) =>
      InfiniteQuery<List<int>, int>(
        cache: cache,
        key: [queryKey, 'hot', query],
        getNextArg: (state) => state.nextPage,
        queryFn: (key) =>
            hot(page: key, query: query).then(_postCache.savePage),
      );

  Future<List<Post>> byTags({
    required List<String> tags,
    int? page,
    int? limit,
    CancelToken? cancelToken,
  }) => client
      .byTags(tags: tags, page: page, limit: limit, cancelToken: cancelToken)
      .map(_filter);

  InfiniteQuery<List<int>, int> useByTags({required List<String> tags}) =>
      InfiniteQuery<List<int>, int>(
        cache: cache,
        key: [queryKey, 'by_tags', tags],
        getNextArg: (state) => state.nextPage,
        queryFn: (page) =>
            byTags(tags: tags, page: page).then(_postCache.savePage),
      );

  /// Filters out "broken" posts.
  /// Flash posts are considered to be broken by default, since we will not be able to display them.
  /// Censored posts, which have contentious tags and are unavailable to anonymous users, are also considered broken.
  /// Posts which are not deleted but have no file are censored.
  List<Post> _filter(List<Post> posts) => posts
      .whereNot((post) => !post.isDeleted && post.file == null)
      .whereNot((post) => post.ext == 'swf')
      .toList();

  Future<List<Post>> byIds({
    required List<int> ids,
    int? limit,
    CancelToken? cancelToken,
  }) => client
      .byIds(ids: ids, limit: limit, cancelToken: cancelToken)
      .map(_filter);

  Query<List<Post>> useByIds({required List<int> ids, int? limit}) => Query(
    cache: cache,
    key: [queryKey, 'ids', ids, limit],
    queryFn: () => byIds(ids: ids, limit: limit),
  );

  Future<List<Post>> idsPage({
    required List<int> ids,
    required int page,
    int? perPage,
    CancelToken? cancelToken,
  }) async {
    perPage ??= persona.traits.value.perPage ?? 75;
    final startIndex = (page - 1) * perPage;
    final endIndex = (startIndex + perPage).clamp(0, ids.length);
    final pageIds = ids.sublist(startIndex, endIndex);
    return byIds(ids: pageIds, limit: perPage, cancelToken: cancelToken);
  }

  InfiniteQuery<List<int>, int> useIdsPage({required List<int> ids}) =>
      InfiniteQuery<List<int>, int>(
        cache: cache,
        key: [queryKey, 'ids', ids],
        getNextArg: (state) => state.nextPage,
        queryFn: (page) =>
            idsPage(ids: ids, page: page).then(_postCache.savePage),
      );

  Future<void> update({required int id, required Map<String, String?> data}) =>
      client.update(id, data);

  Mutation<void, Map<String, String?>> useUpdate({required int id}) => Mutation(
    mutationFn: (data) => _postCache.optimistic(
      id,
      (post) => post, // TODO: Apply optimistic updates based on data
      () => update(id: id, data: data),
    ),
  );

  Future<void> vote({
    required int id,
    required bool upvote,
    required bool replace,
  }) => client.vote(id: id, upvote: upvote, replace: replace);

  Mutation<void, VoteRequest> useVote({required int id}) => Mutation(
    mutationFn: (p) {
      final (:upvote, :replace) = p;
      return _postCache.optimistic(
        id,
        (post) => post.copyWith(vote: post.vote.withVote(upvote, replace)),
        () => vote(id: id, upvote: upvote, replace: replace),
      );
    },
  );
}
