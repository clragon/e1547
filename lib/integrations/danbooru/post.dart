import 'dart:math';

import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';

class DanbooruPostService extends PostService {
  DanbooruPostService({
    required this.dio,
    required this.identity,
  });

  final Dio dio;
  final Identity identity;

  @override
  Set<Enum> get features => {
        PostFeature.hot,
        PostFeature.favorite,
      };

  @override
  Future<Post> get({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  }) =>
      dio
          .get(
            '/posts/$id.json',
            options: forceOptions(force),
            cancelToken: cancelToken,
          )
          .then(
            (response) => DanbooruPost.fromJson(response.data),
          );

  @override
  Future<List<Post>> page({
    int? page,
    int? limit,
    QueryMap? query,
    bool? ordered,
    bool? orderPoolsByOldest,
    bool? orderFavoritesByAdded,
    bool? force,
    CancelToken? cancelToken,
  }) =>
      dio
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
            (response) => (response.data as List<dynamic>)
                .map(DanbooruPost.fromJson)
                .toList(),
          );

  @override
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
        'tags':
            (TagMap.parse(query?['tags'] ?? '')..['order'] = 'rank').toString(),
      },
      limit: limit,
      force: force,
      cancelToken: cancelToken,
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
        ordered: false,
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
  Future<List<Post>> byFavoriter({
    required String username,
    int? page,
    int? limit,
    bool? force,
    CancelToken? cancelToken,
  }) =>
      this.page(
        page: page,
        query: {'tags': 'ordfav:$username'},
        limit: limit,
        ordered: false,
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
        query: {'tags': 'user:$username'},
        limit: limit,
        ordered: false,
        force: force,
        cancelToken: cancelToken,
      );

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
    return this.page(
      page: page,
      limit: limit,
      query: {
        ...?query,
        'tags': (TagMap.parse(query?['tags'] ?? '')
              ..[orderByAdded ? 'ordfav' : 'fav'] = identity.username)
            .toString()
      },
      force: force,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<void> addFavorite(int postId) =>
      dio.post('/favorites.json', queryParameters: {'post_id': postId});

  @override
  Future<void> removeFavorite(int postId) =>
      dio.delete('/favorites/$postId.json');
}

extension DanbooruPost on Post {
  static Post fromJson(dynamic json) => pick(json).letOrThrow(
        (pick) => Post(
          id: pick('id').asIntOrThrow(),
          file: pick('file_url').asStringOrNull(),
          sample: () {
            final sample = pick('large_file_url').asStringOrNull();
            if (sample == null) return null;
            if (sample.endsWith('webm') || sample.endsWith('mp4')) {
              // TODO: use media_asset.variants best picture instead
              return pick('preview_file_url').asStringOrNull();
            }
            return sample;
          }(),
          preview: pick('preview_file_url').asStringOrNull(),
          width: pick('image_width').asIntOrThrow(),
          height: pick('image_height').asIntOrThrow(),
          ext: pick('file_ext').asStringOrThrow(),
          size: pick('file_size').asIntOrThrow(),
          variants: pick('media_asset', 'variants').asListOrNull((p0) {
            final value = p0.asMapOrThrow();
            return MapEntry(
                '${value['width']}x${value['height']}', value['url']);
          })?.fold<Map<String, String>>({}, (acc, e) => acc..[e.key] = e.value),
          tags: {
            'general':
                pick('tag_string_general').asStringOrThrow().split(' ').trim(),
            'character': pick('tag_string_character')
                .asStringOrThrow()
                .split(' ')
                .trim(),
            'copyright': pick('tag_string_copyright')
                .asStringOrThrow()
                .split(' ')
                .trim(),
            'artist':
                pick('tag_string_artist').asStringOrThrow().split(' ').trim(),
            'meta': pick('tag_string_meta').asStringOrThrow().split(' ').trim(),
          },
          uploaderId: pick('uploader_id').asIntOrThrow(),
          createdAt: pick('created_at').asDateTimeOrThrow(),
          updatedAt: pick('updated_at').asDateTimeOrThrow(),
          vote: VoteInfo(score: pick('score').asIntOrThrow()),
          // despite the model containing this field, images are not actually deleted
          // this "soft delete" is not well represented in the UI, so we ignore it
          isDeleted: false, // pick('is_deleted').asBoolOrThrow(),
          rating: pick('rating').letOrThrow(
              (pick) => switch (pick.asStringOrThrow().toLowerCase()) {
                    's' || 'g' => Rating.s,
                    'q' => Rating.q,
                    'e' => Rating.e,
                    _ => throw PickException(
                        'Invalid rating: ${pick.asStringOrThrow()}',
                      ),
                  }),
          favCount: pick('fav_count').asIntOrThrow(),
          isFavorited:
              // TODO: does not seem to be available. maybe only for logged in users?
              false, // pick('is_favorited').asBoolOrThrow(),
          commentCount: null,
          hasComments: pick('last_commented_at').asDateTimeOrNull() != null,
          description:
              // TODO: danbooru does not have a description field
              '', // pick('description').asStringOrThrow(),
          sources: [pick('source').asStringOrThrow()],
          pools: null,
          relationships: Relationships(
            parentId: pick('parent_id').asIntOrNull(),
            hasChildren: pick('has_children').asBoolOrThrow(),
            hasActiveChildren: pick('has_active_children').asBoolOrThrow(),
            children: [],
          ),
        ),
      );
}
