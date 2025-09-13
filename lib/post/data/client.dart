import 'dart:math';

import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';

class PostClient {
  PostClient({required this.dio});

  final Dio dio;

  Future<Post> get({required int id, CancelToken? cancelToken}) => dio
      .get(
        '/posts/$id.json',
        cancelToken: cancelToken,
        options: forceOptions(true),
      )
      .then(unwrapResponse('post'))
      .then((response) => E621Post.fromJson(response.data));

  Future<List<Post>> page({
    int? page,
    int? limit,
    QueryMap? query,
    CancelToken? cancelToken,
  }) => dio
      .get(
        '/posts.json',
        queryParameters: {'page': page, 'limit': limit, ...?query}.toQuery(),
        cancelToken: cancelToken,
        options: forceOptions(true),
      )
      .then(unwrapResponse('posts'))
      .then((response) => response.data.map<Post>(E621Post.fromJson).toList());

  Future<List<Post>> byIds({
    required List<int> ids,
    int? limit,
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
      cancelToken: cancelToken,
    );
  }

  // TODO: Replace this urgently.
  Future<void> update(int postId, Map<String, String?> body) =>
      dio.put('/posts/$postId.json', data: FormData.fromMap(body));

  Future<void> vote({
    required int id,
    required bool upvote,
    required bool replace,
  }) => dio.post(
    '/posts/$id/votes.json',
    queryParameters: {'score': upvote ? 1 : -1, 'no_unvote': replace},
  );
}

extension E621Post on Post {
  static Post fromJson(dynamic json) => pick(json).letOrThrow(
    (post) => Post(
      id: post('id').asIntOrThrow(),
      file: post('file').letOrThrow((file) => file('url').asStringOrNull()),
      sample: post(
        'sample',
      ).letOrThrow((sample) => sample('url').asStringOrNull()),
      preview: post(
        'preview',
      ).letOrThrow((preview) => preview('url').asStringOrNull()),
      width: post('file').letOrThrow((file) => file('width').asIntOrThrow()),
      height: post('file').letOrThrow((file) => file('height').asIntOrThrow()),
      ext: post('file').letOrThrow((file) => file('ext').asStringOrThrow()),
      size: post('file').letOrThrow((file) => file('size').asIntOrThrow()),
      variants: post('sample', 'alternates').letOrNull((alternates) {
        if (alternates.asMapOrNull()?.isEmpty ?? true) return null;
        return {
          '${alternates('original', 'width').asIntOrThrow()}x${alternates('original', 'height').asIntOrThrow()}':
              alternates('original', 'url').asStringOrNull(),
          ...alternates(
            'samples',
          ).asMapOrEmpty().values.fold<Map<String, String?>>({}, (acc, e) {
            final w = pick(e, 'width').asIntOrNull();
            final h = pick(e, 'height').asIntOrNull();
            final url = pick(e, 'url').asStringOrNull();
            if (w != null && h != null && url != null) {
              acc['${w}x$h'] = url;
            }
            return acc;
          }),
        };
      }),
      tags: post('tags').letOrThrow(
        (pick) => pick.asMapOrThrow<String, List<dynamic>>().map(
          (key, value) => MapEntry(key, List.from(value)),
        ),
      ),
      uploaderId: post('uploader_id').asIntOrThrow(),
      createdAt: post('created_at').asDateTimeOrThrow(),
      updatedAt: post('updated_at').asDateTimeOrNull(),
      vote: VoteInfo(
        score: post('score').letOrThrow((pick) => pick('total').asIntOrThrow()),
      ),
      isDeleted: post(
        'flags',
      ).letOrThrow((pick) => pick('deleted').asBoolOrThrow()),
      rating: post(
        'rating',
      ).letOrThrow((pick) => Rating.values.asNameMap()[pick.asString()]!),
      favCount: post('fav_count').asIntOrThrow(),
      isFavorited: post('is_favorited').asBoolOrThrow(),
      commentCount: post('comment_count').asIntOrThrow(),
      description: post('description').asStringOrThrow(),
      sources: post('sources').asListOrThrow((pick) => pick.asStringOrThrow()),
      pools: post('pools').asListOrThrow((pick) => pick.asIntOrThrow()),
      relationships: post('relationships').letOrThrow(
        (pick) => Relationships.fromJson(pick.asMapOrThrow<String, dynamic>()),
      ),
    ),
  );
}
