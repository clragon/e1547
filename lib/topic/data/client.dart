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
      .then(unwrapRailsArray)
      .then(
        (response) => (response.data as List)
            .map<Topic>((e) => E621Topic.fromJson(e))
            .toList(),
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
