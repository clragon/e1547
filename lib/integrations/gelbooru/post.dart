import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:intl/intl.dart';

class GelbooruPostService extends PostService {
  GelbooruPostService({
    required this.dio,
    required this.identity,
  });

  final Dio dio;
  final Identity identity;

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
            '/index.php',
            queryParameters: {
              'page': 'dapi',
              's': 'post',
              'json': '1',
              'q': 'index',
              'id': id,
            },
            options: forceOptions(force),
            cancelToken: cancelToken,
          )
          .then(
            (response) => GelbooruPost.fromJson(response.data),
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
            '/index.php',
            queryParameters: {
              'page': 'dapi',
              's': 'post',
              'json': '1',
              'q': 'index',
              'pid': (page ?? 1) - 1,
              'limit': limit,
              ...?query,
            },
            options: forceOptions(force),
            cancelToken: cancelToken,
          )
          .then(
            (response) =>
                (response.data['post'] as List<dynamic>?)
                    ?.map(GelbooruPost.fromJson)
                    .toList() ??
                [],
          );
}

extension GelbooruPost on Post {
  static Post fromJson(dynamic json) => pick(json).letOrThrow(
        (pick) => Post(
          id: pick('id').asIntOrThrow(),
          file: pick('file_url').asStringOrThrow(),
          sample: () {
            String url = pick('sample_url').asStringOrThrow();
            if (url.isEmpty) {
              url = pick('file_url').asStringOrThrow();
            }
            if (url.endsWith('.webm') || url.endsWith('.mp4')) {
              url = pick('preview_url').asStringOrThrow();
            }
            if (url.isEmpty) return null;
            return url;
          }(),
          preview: pick('preview_url').asStringOrThrow(),
          width: pick('width').asIntOrThrow(),
          height: pick('height').asIntOrThrow(),
          ext: Uri.tryParse(pick('file_url').asStringOrNull() ?? '')
                  ?.pathSegments
                  .last
                  .split('.')
                  .last ??
              '',
          size: 0,
          variants: null,
          tags: {
            'general': pick('tags').asStringOrThrow().split(' ').trim(),
          },
          uploaderId: pick('creator_id').asIntOrThrow(),
          createdAt: () {
            // intl doesnt support formating/parsing RFC 822 as of now
            List<String> parts =
                pick('created_at').asStringOrThrow().split(' ');
            String datePart = '${parts.take(4).join(' ')} ${parts.last}';
            String timeZoneOffset = parts[4];

            DateFormat dateFormat = DateFormat('EEE MMM dd HH:mm:ss yyyy');
            DateTime dateTime = dateFormat.parse(datePart, true);

            int hours = int.parse(timeZoneOffset.substring(0, 3));
            int minutes =
                int.parse(timeZoneOffset[0] + timeZoneOffset.substring(3));
            Duration timeZoneDuration =
                Duration(hours: hours, minutes: minutes);

            return dateTime.subtract(timeZoneDuration);
          }(),
          updatedAt: null,
          vote: VoteInfo(score: pick('score').asIntOrThrow()),
          isDeleted: false, // pick('is_deleted').asBoolOrThrow(),
          rating: pick('rating').letOrThrow(
              (pick) => switch (pick.asStringOrThrow().toLowerCase()) {
                    'general' => Rating.s,
                    'sensitive' || 'questionable' => Rating.q,
                    'explicit' => Rating.e,
                    _ => throw PickException(
                        'Invalid rating: ${pick.asStringOrThrow()}',
                      ),
                  }),
          favCount:
              // TODO: this is not available in gelbooru
              0, // pick('fav_count').asIntOrThrow() ,
          isFavorited:
              // TODO: is this available in gelbooru?
              false, // pick('is_favorited').asBoolOrThrow(),
          commentCount: null,
          hasComments: pick('has_comments').asBoolOrThrow(),
          description: pick('title').asStringOrThrow(),
          sources: [pick('source').asStringOrThrow()],
          pools: null,
          relationships: Relationships(
            parentId: () {
              int? id = pick('parent_id').asIntOrNull();
              if (id == 0) return null;
              return id;
            }(),
            hasChildren: pick('has_children').asBoolOrThrow(),
            hasActiveChildren: null,
            children: [],
          ),
        ),
      );
}
