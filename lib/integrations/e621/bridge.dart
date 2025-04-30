import 'package:dio/dio.dart';
import 'package:e1547/integrations/http/bridge.dart';
import 'package:e1547/traits/traits.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/foundation.dart';

class E621BridgeService extends HttpBridgeService {
  E621BridgeService({
    required super.dio,
    required super.identity,
    required super.traits,
    required this.accountsService,
  });

  final AccountService accountsService;

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
      accountsService.get(
        force: force,
        cancelToken: cancelToken,
      );
}
