import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';

class DanbooruPostsClient extends PostsClient {
  DanbooruPostsClient({required this.dio});

  final Dio dio;

  @override
  Set<Enum> get features => {};

  @override
  Future<Post> get(
    int postId, {
    bool? force,
    CancelToken? cancelToken,
  }) =>
      dio
          .get(
            '/posts/$postId.json',
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
  Future<List<Post>> byIds(
      {required List<int> ids,
      int? limit,
      bool? force,
      CancelToken? cancelToken}) {
    // TODO: implement byIds
    throw UnimplementedError();
  }

  @override
  Future<List<Post>> byTags({
    required List<String> tags,
    int? page,
    int? limit,
    bool? force,
    CancelToken? cancelToken,
  }) {
    // TODO: implement byTags
    throw UnimplementedError();
  }
}

extension DanbooruPost on Post {
  static Post fromJson(dynamic json) => pick(json).letOrThrow(
        (pick) => Post(
          id: pick('id').asIntOrThrow(),
          file: pick('large_file_url').asStringOrNull(),
          sample: pick('file_url').asStringOrNull(),
          preview: pick('preview_file_url').asStringOrNull(),
          width: pick('image_width').asIntOrThrow(),
          height: pick('image_height').asIntOrThrow(),
          ext: pick('file_ext').asStringOrThrow(),
          size: pick('file_size').asIntOrThrow(),
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
          isDeleted: pick('is_deleted').asBoolOrThrow(),
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
          commentCount:
              // TODO: not available. alternative endpoint?
              // TODO: last_commented_at could indicate whether comments are not 0
              0, // pick('comment_count').asIntOrThrow(),

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
