import 'package:dio/dio.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';

class TagClient {
  TagClient({required this.dio});

  final Dio dio;

  // Technically missing get()
  Future<List<Tag>> page({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) => dio
      .get(
        '/tags.json',
        queryParameters: {'page': page, 'limit': limit, ...?query},
        options: forceOptions(force),
        cancelToken: cancelToken,
      )
      .then(unwrapRailsArray)
      .then((response) => response.data.map<Tag>(E621Tag.fromJson).toList());

  Future<List<Tag>> autocomplete({
    String? search,
    int? limit,
    int? category,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    search ??= '';
    if (search.contains(':')) return [];
    if (category == null) {
      if (search.length < 3) return [];
      return dio
          .get(
            '/tags/autocomplete.json',
            queryParameters: {'search[name_matches]': search},
            options: forceOptions(force),
            cancelToken: cancelToken,
          )
          .then(unwrapRailsArray)
          .then(
            (response) =>
                response.data.map<Tag>(E621Tag.fromJson).take(3).toList(),
          );
    } else {
      return page(
        limit: limit,
        query: {
          'search[name_matches]': '$search*',
          'search[category]': category,
          'search[order]': 'count',
        }.toQuery(),
        force: force,
      );
    }
  }

  Future<String?> aliases({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) => dio
      .get(
        '/tag_aliases.json',
        queryParameters: {'page': page, 'limit': limit, ...?query},
        options: forceOptions(force),
        cancelToken: cancelToken,
      )
      .then(unwrapRailsArray)
      .then((response) {
        return response.data
            .cast<Map<String, dynamic>>()
            .where((e) => e['status'] != 'deleted')
            .map((e) => e['consequent_name'] as String?)
            .firstOrNull;
      });
}
