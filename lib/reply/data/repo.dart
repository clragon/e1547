import 'package:dio/dio.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/shared/shared.dart';

class ReplyRepo {
  ReplyRepo({required this.persona, required this.client});

  final ReplyClient client;
  final Persona persona;

  Future<Reply> get({required int id, bool? force, CancelToken? cancelToken}) =>
      client.get(id: id, force: force, cancelToken: cancelToken);

  Future<List<Reply>> page({
    required int id,
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) => client.page(
    id: id,
    page: page,
    limit: limit,
    query: query,
    force: force,
    cancelToken: cancelToken,
  );

  Future<List<Reply>> byTopic({
    required int id,
    int? page,
    int? limit,
    bool? ascending,
    bool? force,
    CancelToken? cancelToken,
  }) => client.byTopic(
    id: id,
    page: page,
    limit: limit,
    ascending: ascending,
    force: force,
    cancelToken: cancelToken,
  );
}
