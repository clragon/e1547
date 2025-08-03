import 'package:dio/dio.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/wiki/wiki.dart';

class WikiRepo {
  WikiRepo({required this.client, required this.persona});

  final WikiClient client;
  final Persona persona;

  Future<Wiki> get({
    required String id,
    bool? force,
    CancelToken? cancelToken,
  }) => client.get(id: id, force: force, cancelToken: cancelToken);

  Future<List<Wiki>> page({
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
}
