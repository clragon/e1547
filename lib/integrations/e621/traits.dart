import 'package:dio/dio.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/traits/traits.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/foundation.dart';

class E621TraitsClient extends TraitsClient {
  E621TraitsClient({
    required this.dio,
    required this.identity,
    required this.traits,
    required this.accountsClient,
  });

  final Dio dio;
  final Identity identity;
  final ValueNotifier<Traits> traits;
  final AccountService accountsClient;

  @override
  Future<void> push({
    required Traits traits,
    CancelToken? cancelToken,
  }) async {
    Traits previous = this.traits.value;
    this.traits.value = traits;
    if (identity.username == null) return;
    try {
      if (!listEquals(previous.denylist, traits.denylist)) {
        Map<String, dynamic> body = {
          'user[blacklisted_tags]': traits.denylist.join('\n'),
        };

        await dio.put(
          '/users/${identity.username}.json',
          data: FormData.fromMap(body),
          cancelToken: cancelToken,
        );
      }
    } on DioException {
      this.traits.value = this.traits.value.copyWith(
            denylist: previous.denylist,
          );
      rethrow;
    }
  }

  @override
  Future<void> pull({bool? force, CancelToken? cancelToken}) =>
      accountsClient.get(
        force: force,
        cancelToken: cancelToken,
      );
}
