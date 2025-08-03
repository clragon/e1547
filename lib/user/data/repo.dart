import 'package:dio/dio.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/user/user.dart';

class UserRepo {
  UserRepo({required this.persona, required this.client});

  final Persona persona;
  final UserClient client;

  Future<User> get({required int id, bool? force, CancelToken? cancelToken}) =>
      client.get(id: id, force: force, cancelToken: cancelToken);

  Future<User> getByName({
    required String name,
    bool? force,
    CancelToken? cancelToken,
  }) => client.getByName(name: name, force: force, cancelToken: cancelToken);

  Future<List<User>> page({
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
