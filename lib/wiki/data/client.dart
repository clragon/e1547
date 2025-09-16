import 'package:dio/dio.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/wiki/wiki.dart';

class WikiClient {
  WikiClient({required this.dio});

  final Dio dio;

  Future<Wiki> get({
    required String id,
    bool? force,
    CancelToken? cancelToken,
  }) => dio
      .get(
        '/wiki_pages/$id.json',
        options: forceOptions(force),
        cancelToken: cancelToken,
      )
      .then((response) => E621Wiki.fromJson(response.data));

  Future<List<Wiki>> page({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) => dio
      .get(
        '/wiki_pages.json',
        queryParameters: {'page': page, 'limit': limit, ...?query},
        options: forceOptions(force),
        cancelToken: cancelToken,
      )
      .then(unwrapRailsArray)
      .then(
        (response) =>
            (response.data as List).map<Wiki>(E621Wiki.fromJson).toList(),
      );
}
