import 'package:dio/dio.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/user/user.dart';

class E621UsersClient extends UsersClient {
  E621UsersClient({required this.dio});

  final Dio dio;

  @override
  Set<UsersFeature> get features => {UsersFeature.report};

  @override
  Future<User> user({
    required String id,
    bool? force,
    CancelToken? cancelToken,
  }) async =>
      dio
          .get(
            '/users/$id.json',
            options: forceOptions(force),
            cancelToken: cancelToken,
          )
          .then(
            (response) => E621User.fromJson(response.data),
          );

  @override
  Future<void> reportUser({
    required int id,
    required String reason,
  }) =>
      dio.post(
        '/tickets',
        queryParameters: {
          'ticket[reason]': reason,
          'ticket[disp_id]': id,
          'ticket[qtype]': 'user',
        },
      );
}
