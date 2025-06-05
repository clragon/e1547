import 'dart:math';

import 'package:collection/collection.dart';
import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';

class PostService {
  PostService({
    required this.dio,
    required this.identity,
    required this.poolsService,
  });

  final Dio dio;
  final Identity identity;
  final PoolService poolsService;

  Future<Post> get({required int id, bool? force, CancelToken? cancelToken}) =>
      dio
          .get(
            '/posts/$id.json',
            options: forceOptions(force),
            cancelToken: cancelToken,
          )
          .then((response) => E621Post.fromJson(response.data['post']));

  Future<List<Post>> page({
    int? page,
    int? limit,
    QueryMap? query,
    // This needs to be rearchitected.
    // - maybe extra function, e.g. pageOrdered?
    // - maybe extra PostPageOrder class?
    // - maybe special query parameters?
    bool? ordered,
    bool? orderPoolsByOldest,
    bool? orderFavoritesByAdded,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    ordered ??= true;
    String? tags = query?['tags'];
    if (ordered && tags != null) {
      Map<RegExp, Future<List<Post>> Function(RegExpMatch match)> redirects = {
        poolRegex(): (match) => byPool(
          id: int.parse(match.namedGroup('id')!),
          page: page,
          orderByOldest: orderPoolsByOldest ?? true,
          force: force,
          cancelToken: cancelToken,
        ),
        if ((orderFavoritesByAdded ?? false) && identity.username != null)
          favRegex(identity.username!): (match) =>
              favorites(page: page, limit: limit, force: force),
      };

      for (final entry in redirects.entries) {
        RegExpMatch? match = entry.key.firstMatch(tags);
        if (match != null) {
          return entry.value(match);
        }
      }
    }

    return dio
        .get(
          '/posts.json',
          queryParameters: {'page': page, 'limit': limit, ...?query},
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then(
          (response) => (response.data['posts'] as List<dynamic>)
              .map<Post>(E621Post.fromJson)
              .whereNot(
                (e) => (e.file == null && !e.isDeleted) || e.ext == 'swf',
              )
              .toList(),
        );
  }

  Future<List<Post>> byHot({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) {
    return this.page(
      page: page,
      query: {
        ...?query,
        'tags': (TagMap(query?['tags'])..['order'] = 'rank'),
      }.toQuery(),
      limit: limit,
      force: force,
      cancelToken: cancelToken,
    );
  }

  Future<List<Post>> byIds({
    required List<int> ids,
    int? limit,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    limit = max(0, min(limit ?? 75, 100));

    List<List<int>> chunks = [];
    for (int i = 0; i < ids.length; i += limit) {
      chunks.add(ids.sublist(i, min(i + limit, ids.length)));
    }

    List<Post> result = [];
    for (final chunk in chunks) {
      if (chunk.isEmpty) continue;
      String filter = 'id:${chunk.join(',')}';
      List<Post> part = await page(
        query: {'tags': filter},
        limit: limit,
        ordered: false,
        force: force,
        cancelToken: cancelToken,
      );
      Map<int, Post> table = {for (Post e in part) e.id: e};
      part =
          (chunk.map((e) => table[e]).toList()..removeWhere((e) => e == null))
              .cast<Post>();
      result.addAll(part);
    }
    return result;
  }

  Future<List<Post>> byTags({
    required List<String> tags,
    int? page,
    int? limit,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    page ??= 1;
    tags.removeWhere((e) => e.contains(' ') || e.contains(':'));
    if (tags.isEmpty) return [];
    int max = 40;
    int pages = (tags.length / max).ceil();
    int chunkSize = (tags.length / pages).ceil();

    int tagPage = page % pages != 0 ? page % pages : pages;
    int sitePage = (page / pages).ceil();

    List<String> chunk = tags
        .sublist((tagPage - 1) * chunkSize)
        .take(chunkSize)
        .toList();
    String filter = chunk.map((e) => '~$e').join(' ');
    return this.page(
      page: sitePage,
      query: {'tags': filter},
      limit: limit,
      ordered: false,
      force: force,
      cancelToken: cancelToken,
    );
  }

  Future<List<Post>> byFavoriter({
    required String username,
    int? page,
    int? limit,
    bool? force,
    CancelToken? cancelToken,
  }) => this.page(
    page: page,
    query: {'tags': 'fav:$username'},
    limit: limit,
    ordered: false,
    force: force,
    cancelToken: cancelToken,
  );

  Future<List<Post>> byUploader({
    required String username,
    int? page,
    int? limit,
    bool? force,
    CancelToken? cancelToken,
  }) => this.page(
    page: page,
    query: {'tags': 'user:$username'},
    limit: limit,
    ordered: false,
    force: force,
    cancelToken: cancelToken,
  );

  Future<List<Post>> byPool({
    required int id,
    int? page,
    int? limit,
    bool orderByOldest = true,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    page ??= 1;
    // TODO: store per page count in Traits
    int limit = 75;
    Pool pool = await poolsService.get(
      id: id,
      force: force,
      cancelToken: cancelToken,
    );
    List<int> ids = pool.postIds;
    if (!orderByOldest) ids = ids.reversed.toList();
    int lower = (page - 1) * limit;
    if (lower > ids.length) return [];
    ids = ids.sublist(lower).take(limit).toList();
    return byIds(
      ids: ids,
      limit: limit,
      force: force,
      cancelToken: cancelToken,
    );
  }

  Future<void> update(int postId, Map<String, String?> body) async {
    await dio.cache?.deleteFromPath(
      RegExp(RegExp.escape('/posts/$postId.json')),
    );
    await dio.put('/posts/$postId.json', data: FormData.fromMap(body));
  }

  // TODO: votes should be their own service
  Future<void> vote(int postId, bool upvote, bool replace) async {
    await dio.cache?.deleteFromPath(
      RegExp(RegExp.escape('/posts/$postId.json')),
    );
    await dio.post(
      '/posts/$postId/votes.json',
      queryParameters: {'score': upvote ? 1 : -1, 'no_unvote': replace},
    );
  }

  // TODO: favorites should be their own service
  Future<List<Post>> favorites({
    int? page,
    int? limit,
    QueryMap? query,
    bool? orderByAdded,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    if (identity.username == null) {
      throw NoUserLoginException();
    }
    orderByAdded ??= true;
    String tags = query?['tags'] ?? '';
    if (tags.isEmpty && orderByAdded) {
      Map<String, dynamic> body = await dio
          .get(
            '/favorites.json',
            queryParameters: {'page': page, 'limit': limit, ...?query},
            options: forceOptions(force),
            cancelToken: cancelToken,
          )
          .then((response) => response.data);

      List<Post> result = List.from(body['posts'].map(E621Post.fromJson));
      result.removeWhere((e) => e.isDeleted || e.file == null);
      return result;
    } else {
      return this.page(
        page: page,
        query: {
          ...?query,
          'tags': (TagMap(tags)..['fav'] = identity.username).toString(),
        },
        ordered: false,
        force: force,
        cancelToken: cancelToken,
      );
    }
  }

  Future<void> addFavorite(int postId) async {
    await dio.cache?.deleteFromPath(
      RegExp(RegExp.escape('/posts/$postId.json')),
    );
    await dio.post('/favorites.json', queryParameters: {'post_id': postId});
  }

  Future<void> removeFavorite(int postId) async {
    await dio.cache?.deleteFromPath(
      RegExp(RegExp.escape('/posts/$postId.json')),
    );
    await dio.delete('/favorites/$postId.json');
  }
}

extension E621Post on Post {
  static Post fromJson(dynamic json) => pick(json).letOrThrow(
    (pick) => Post(
      id: pick('id').asIntOrThrow(),
      file: pick('file').letOrThrow((pick) => pick('url').asStringOrNull()),
      sample: pick('sample').letOrThrow((pick) => pick('url').asStringOrNull()),
      preview: pick(
        'preview',
      ).letOrThrow((pick) => pick('url').asStringOrNull()),
      width: pick('file').letOrThrow((pick) => pick('width').asIntOrThrow()),
      height: pick('file').letOrThrow((pick) => pick('height').asIntOrThrow()),
      ext: pick('file').letOrThrow((pick) => pick('ext').asStringOrThrow()),
      size: pick('file').letOrThrow((pick) => pick('size').asIntOrThrow()),
      variants: pick.letOrThrow((pick) {
        final sample = pick('sample');
        // TODO: remove this once "original" includes width and height
        final file = pick('file');
        final alternates = sample('alternates');

        if (alternates.asMapOrNull()?.isEmpty ?? true) return null;

        return {
          '${file('width').asIntOrThrow()}x${file('height').asIntOrThrow()}':
              ?alternates('original', 'url').asStringOrNull(),
          ...Map.fromEntries(
            alternates('samples').asMapOrEmpty().entries.map(
              (e) => MapEntry(
                '${e.value['width']}x${e.value['height']}',
                e.value['url'],
              ),
            ),
          ),
        };
      }),
      tags: pick('tags').letOrThrow(
        (pick) => pick.asMapOrThrow<String, List<dynamic>>().map(
          (key, value) => MapEntry(key, List.from(value)),
        ),
      ),
      uploaderId: pick('uploader_id').asIntOrThrow(),
      createdAt: pick('created_at').asDateTimeOrThrow(),
      updatedAt: pick('updated_at').asDateTimeOrNull(),
      vote: VoteInfo(
        score: pick('score').letOrThrow((pick) => pick('total').asIntOrThrow()),
      ),
      isDeleted: pick(
        'flags',
      ).letOrThrow((pick) => pick('deleted').asBoolOrThrow()),
      rating: pick(
        'rating',
      ).letOrThrow((pick) => Rating.values.asNameMap()[pick.asString()]!),
      favCount: pick('fav_count').asIntOrThrow(),
      isFavorited: pick('is_favorited').asBoolOrThrow(),
      commentCount: pick('comment_count').asIntOrThrow(),
      description: pick('description').asStringOrThrow(),
      sources: pick('sources').asListOrThrow((pick) => pick.asStringOrThrow()),
      pools: pick('pools').asListOrThrow((pick) => pick.asIntOrThrow()),
      relationships: pick('relationships').letOrThrow(
        (pick) => Relationships.fromJson(pick.asMapOrThrow<String, dynamic>()),
      ),
    ),
  );
}
