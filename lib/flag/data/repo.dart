import 'package:dio/dio.dart';
import 'package:e1547/flag/flag.dart';
import 'package:e1547/shared/shared.dart';

class FlagRepo {
  FlagRepo({required this.persona, required this.client});

  final FlagClient client;
  final Persona persona;

  Future<List<PostFlag>> list({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) => client.list(
    page: page,
    limit: limit,
    query: query,
    force: force,
    cancelToken: cancelToken,
  );

  Future<void> create(int postId, String flag, {int? parent}) =>
      client.create(postId, flag, parent: parent);
}
