import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/shared/shared.dart';

class ReplyClient {
  ReplyClient({required this.dio});

  final Dio dio;

  Future<Reply> get({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  }) async => dio
      .get(
        '/forum_posts/$id.json',
        options: forceOptions(force),
        cancelToken: cancelToken,
      )
      .then((response) => E621Reply.fromJson(response.data));

  Future<List<Reply>> page({
    required int id,
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) async => dio
      .get(
        '/forum_posts.json',
        queryParameters: {'page': page, 'limit': limit, ...?query},
        options: forceOptions(force),
        cancelToken: cancelToken,
      )
      .then(
        (response) => pick(
          response.data,
        ).asListOrEmpty((p0) => E621Reply.fromJson(p0.asMapOrThrow())),
      );

  Future<List<Reply>> byTopic({
    required int id,
    int? page,
    int? limit,
    bool? ascending,
    bool? force,
    CancelToken? cancelToken,
  }) async => this.page(
    id: id,
    page: page,
    limit: limit,
    query: {
      'search[topic_id]': id,
      'search[order]': ascending ?? false ? 'id_asc' : 'id_desc',
    }.toQuery(),
    force: force,
    cancelToken: cancelToken,
  );
}
