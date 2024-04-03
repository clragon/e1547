import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';

class MoebooruPostService extends PostService {
  MoebooruPostService({
    required this.dio,
  });

  final Dio dio;

  @override
  Set<Enum> get features => {};

  @override
  Future<Post> get({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  }) =>
      dio
          .get(
        '/post.json',
        queryParameters: {
          'tags': 'id:$id',
        },
        options: forceOptions(force),
        cancelToken: cancelToken,
      )
          .then(
        (response) {
          List<dynamic> posts = response.data;
          if (posts.isEmpty) {
            throw DioException(
              requestOptions: response.requestOptions,
              response: Response(
                requestOptions: response.requestOptions,
                statusCode: 404,
                statusMessage: 'Not Found',
              ),
              error: 'Not Found',
            );
          }
          return MoebooruPost.fromJson(posts.first);
        },
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
            '/post.json',
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
                .map((e) => MoebooruPost.fromJson(e))
                .toList(),
          );
}

extension MoebooruPost on Post {
  static Post fromJson(Map<String, dynamic> json) => pick(json).letOrThrow(
        (pick) => Post(
          id: pick('id').asIntOrThrow(),
          file: pick('file_url').asStringOrNull(),
          sample: pick('sample_url').asStringOrNull(),
          preview: pick('preview_url').asStringOrNull(),
          width: pick('width').asIntOrThrow(),
          height: pick('height').asIntOrThrow(),
          ext: pick('file_ext').asStringOrThrow(),
          size: pick('file_size').asIntOrThrow(),
          variants: null,
          tags: {
            'unknown': pick('tags').asStringOrThrow().split(' ').toList(),
          },
          uploaderId: pick('creator_id').asIntOrThrow(),
          createdAt: DateTime.fromMillisecondsSinceEpoch(
              pick('created_at').asIntOrThrow()),
          updatedAt: DateTime.fromMillisecondsSinceEpoch(
              pick('updated_at').asIntOrThrow()),
          vote: VoteInfo(score: 0), // TODO: this is not available
          isDeleted: false,
          rating: pick('rating').letOrThrow(
              (pick) => switch (pick.asStringOrThrow().toLowerCase()) {
                    's' => Rating.s,
                    'q' => Rating.q,
                    'e' => Rating.e,
                    _ => throw PickException(
                        'Invalid rating: ${pick.asStringOrThrow()}',
                      ),
                  }),
          favCount: 0, // TODO: this is not available
          isFavorited: false, // TODO: this is not available
          commentCount: null,
          hasComments: pick('last_commented_at').asIntOrThrow() != 0,
          description: '',
          sources: [pick('source').asStringOrThrow()],
          pools: null,
          relationships: Relationships(
            parentId: pick('parent_id').asIntOrNull(),
            hasChildren: pick('has_children').asBoolOrThrow(),
            hasActiveChildren: null,
            children: [],
          ),
        ),
      );
}
