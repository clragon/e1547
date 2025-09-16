import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/topic/topic.dart';

class TopicClient {
  TopicClient({required this.dio});

  final Dio dio;

  Future<List<Topic>> page({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) => dio
      .get(
        '/forum_topics.json',
        queryParameters: {'page': page, 'limit': limit, ...?query},
        options: forceOptions(force),
        cancelToken: cancelToken,
      )
      .then(
        (response) => pick(
          response.data,
        ).asListOrEmpty((p0) => E621Topic.fromJson(p0.asMapOrThrow())),
      );

  Future<Topic> get({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  }) async => dio
      .get(
        '/forum_topics/$id.json',
        options: forceOptions(force),
        cancelToken: cancelToken,
      )
      .then((response) => E621Topic.fromJson(response.data));
}
