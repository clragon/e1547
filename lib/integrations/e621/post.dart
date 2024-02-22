import 'dart:math';

import 'package:collection/collection.dart';
import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/ticket/ticket.dart';

class E621PostsClient extends PostsClient {
  E621PostsClient({
    required this.dio,
    required this.identity,
  });

  final Dio dio;
  final Identity identity;

  @override
  Set<Enum> get features => {
        PostFeature.update,
        PostFeature.favorite,
        PostFeature.report,
        PostFeature.flag,
      };

  @override
  Future<Post> get(int postId, {bool? force, CancelToken? cancelToken}) => dio
      .get(
        '/posts/$postId.json',
        options: forceOptions(force),
        cancelToken: cancelToken,
      )
      .then(
        (response) => E621Post.fromJson(response.data['post']),
      );

  @override
  Future<List<Post>> page({
    int? page,
    int? limit,
    QueryMap? query,
    /*
    bool? ordered,
    bool? orderPoolsByOldest,
    bool? orderFavoritesByAdded,
     */
    bool? force,
    CancelToken? cancelToken,
  }) async {
    // TODO: function redirections are not real
    /*
    ordered ??= true;
    String? tags = query?['tags'];
    if (ordered && tags != null) {
      Map<RegExp, Future<List<Post>> Function(RegExpMatch match)> redirects = {
        poolRegex(): (match) => postsByPool(
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
     */

    return dio
        .get(
          '/posts.json',
          queryParameters: {
            'page': page,
            'limit': limit,
            ...?query,
          },
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then(
          (response) => pick(pick(response.data).asMapOrThrow()['posts'])
              .asListOrThrow(E621Post.fromJson)
              .whereNot(
                (e) => (e.file == null && !e.isDeleted) || e.ext == 'swf',
              )
              .toList(),
        );
  }

  @override
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
        // ordered: false,
        force: force,
        cancelToken: cancelToken,
      );
      Map<int, Post> table = {for (Post e in part) e.id: e};
      part = (chunk.map((e) => table[e]).toList()
            ..removeWhere((e) => e == null))
          .cast<Post>();
      result.addAll(part);
    }
    return result;
  }

  @override
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

    List<String> chunk =
        tags.sublist((tagPage - 1) * chunkSize).take(chunkSize).toList();
    String filter = chunk.map((e) => '~$e').join(' ');
    return this.page(
      page: sitePage,
      query: QueryMap()..['tags'] = filter,
      limit: limit,
      // ordered: false,
      force: force,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<List<Post>> byFavoriter({
    required String username,
    int? page,
    int? limit,
    bool? force,
    CancelToken? cancelToken,
  }) =>
      this.page(
        page: page,
        query: QueryMap()..['tags'] = 'fav:$username',
        limit: limit,
        // ordered: false,
        force: force,
        cancelToken: cancelToken,
      );

  @override
  Future<List<Post>> byUploader({
    required String username,
    int? page,
    int? limit,
    bool? force,
    CancelToken? cancelToken,
  }) =>
      this.page(
        page: page,
        query: QueryMap()..['tags'] = 'user:$username',
        limit: limit,
        // ordered: false,
        force: force,
        cancelToken: cancelToken,
      );

  @override
  Future<void> update(int postId, Map<String, String?> body) async {
    // TODO: Implement cache invalidation
    /*
    await cache?.deleteFromPath(
      RegExp(RegExp.escape('/posts/$postId.json')),
    );
     */

    await dio.put('/posts/$postId.json', data: FormData.fromMap(body));
  }

  @override
  Future<void> vote(int postId, bool upvote, bool replace) async {
    /*
    await cache?.deleteFromPath(RegExp(RegExp.escape('/posts/$postId.json')));
     */
    await dio.post('/posts/$postId/votes.json', queryParameters: {
      'score': upvote ? 1 : -1,
      'no_unvote': replace,
    });
  }

  @override
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
            queryParameters: {
              'page': page,
              'limit': limit,
              ...?query,
            },
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
          'tags': (TagMap.parse(tags)..['fav'] = identity.username).toString(),
        },
        // ordered: false,
        force: force,
        cancelToken: cancelToken,
      );
    }
  }

  @override
  Future<void> addFavorite(int postId) async {
    // TODO: Implement cache invalidation
    // await cache?.deleteFromPath(RegExp(RegExp.escape('/posts/$postId.json')));
    await dio.post('/favorites.json', queryParameters: {'post_id': postId});
  }

  @override
  Future<void> removeFavorite(int postId) async {
    // TODO: Implement cache invalidation
    // await cache?.deleteFromPath(RegExp(RegExp.escape('/posts/$postId.json')));
    await dio.delete('/favorites/$postId.json');
  }

  @override
  Future<void> remove(int postId, int reportId, String reason) async {
    await dio.post(
      '/tickets',
      queryParameters: {
        'ticket[reason]': reason,
        'ticket[report_reason]': reportId,
        'ticket[disp_id]': postId,
        'ticket[qtype]': 'post',
      },
      options: Options(
        validateStatus: (status) => status == 302,
      ),
    );
  }

  @override
  Future<void> addFlag(int postId, String flag, {int? parent}) async {
    await dio.post(
      '/post_flags.json',
      queryParameters: {
        'post_flag[post_id]': postId,
        'post_flag[reason_name]': flag,
        if (flag == 'inferior' && parent != null)
          'post_flag[parent_id]': parent,
      },
    );
  }

  @override
  Future<List<PostFlag>> flags({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) =>
      dio
          .get(
            '/post_flags.json',
            queryParameters: {
              'page': page,
              'limit': limit,
              ...?query,
            },
            options: forceOptions(force),
            cancelToken: cancelToken,
          )
          .then(
            (response) => pick(response.data).asListOrThrow(
              (p0) => PostFlag.fromJson(p0.asMapOrThrow()),
            ),
          );
}

extension E621Post on Post {
  static Post fromJson(dynamic json) => pick(json).letOrThrow(
        (pick) => Post(
          id: pick('id').asIntOrThrow(),
          file: pick('file').letOrThrow((pick) => pick('url').asStringOrNull()),
          sample:
              pick('sample').letOrThrow((pick) => pick('url').asStringOrNull()),
          preview: pick('preview')
              .letOrThrow((pick) => pick('url').asStringOrNull()),
          width:
              pick('file').letOrThrow((pick) => pick('width').asIntOrThrow()),
          height:
              pick('file').letOrThrow((pick) => pick('height').asIntOrThrow()),
          ext: pick('file').letOrThrow((pick) => pick('ext').asStringOrThrow()),
          size: pick('file').letOrThrow((pick) => pick('size').asIntOrThrow()),
          tags: pick('tags').letOrThrow(
            (pick) => pick.asMapOrThrow<String, List<dynamic>>().map(
                  (key, value) => MapEntry(key, List.from(value)),
                ),
          ),
          uploaderId: pick('uploader_id').asIntOrThrow(),
          createdAt: pick('created_at').asDateTimeOrThrow(),
          updatedAt: pick('updated_at').asDateTimeOrThrow(),
          vote: VoteInfo(
            score: pick('score')
                .letOrThrow((pick) => pick('total').asIntOrThrow()),
          ),
          isDeleted: pick('flags')
              .letOrThrow((pick) => pick('deleted').asBoolOrThrow()),
          rating: pick('rating').letOrThrow(
              (pick) => Rating.values.asNameMap()[pick.asString()]!),
          favCount: pick('fav_count').asIntOrThrow(),
          isFavorited: pick('is_favorited').asBoolOrThrow(),
          commentCount: pick('comment_count').asIntOrThrow(),
          description: pick('description').asStringOrThrow(),
          sources:
              pick('sources').asListOrThrow((pick) => pick.asStringOrThrow()),
          pools: pick('pools').asListOrThrow((pick) => pick.asIntOrThrow()),
          relationships: pick('relationships').letOrThrow((pick) =>
              Relationships.fromJson(pick.asMapOrThrow<String, dynamic>())),
        ),
      );
}
