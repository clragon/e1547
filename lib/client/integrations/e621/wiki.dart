import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/wiki/wiki.dart';

class E621WikisClient extends WikisClient {
  E621WikisClient({required this.dio});

  final Dio dio;

  @override
  Future<Wiki> wiki({
    required String id,
    bool? force,
    CancelToken? cancelToken,
  }) =>
      dio
          .get(
            '/wiki_pages/$id.json',
            options: forceOptions(force),
            cancelToken: cancelToken,
          )
          .then(
            (response) => E621Wiki.fromJson(response.data),
          );

  @override
  Future<List<Wiki>> wikis({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) =>
      dio
          .get(
            '/wiki_pages.json',
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
              (p0) => E621Wiki.fromJson(p0),
            ),
          );
}

extension E621Wiki on Wiki {
  // TODO: Wiki has too many properties.
  static Wiki fromJson(dynamic json) => Wiki.fromJson(json);
}
