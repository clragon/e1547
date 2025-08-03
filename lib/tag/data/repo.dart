import 'package:dio/dio.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';

class TagRepo {
  TagRepo({required this.client, required this.persona});

  final TagClient client;
  final Persona persona;

  Future<List<Tag>> page({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) => client.page(
    page: page,
    limit: limit,
    query: query,
    force: force,
    cancelToken: cancelToken,
  );

  Future<List<Tag>> autocomplete({
    String? search,
    int? limit,
    int? category,
    bool? force,
    CancelToken? cancelToken,
  }) => client.autocomplete(
    search: search,
    limit: limit,
    category: category,
    force: force,
    cancelToken: cancelToken,
  );

  Future<String?> aliases({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) => client.aliases(
    page: page,
    limit: limit,
    query: query,
    force: force,
    cancelToken: cancelToken,
  );
}
