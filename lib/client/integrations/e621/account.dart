import 'package:dio/dio.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/traits/traits.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/foundation.dart';

class E621AccountsClient extends AccountsClient {
  E621AccountsClient({
    required Dio dio,
    required this.identity,
    required this.traits,
    required this.postsClient,
  }) : _dio = dio;

  final Dio _dio;
  final Identity identity;
  final ValueNotifier<Traits> traits;
  final PostsClient postsClient;

  @override
  Future<Account?> account({bool? force, CancelToken? cancelToken}) async {
    if (identity.username == null) return null;

    Account result = await _dio
        .get(
          '/users/${identity.username}.json',
          options: ClientCacheConfig(
            maxAge: const Duration(hours: 1),
            policy:
                (force ?? false) ? CachePolicy.refresh : CachePolicy.request,
          ).toOptions(),
          cancelToken: cancelToken,
        )
        .then((response) => E621Account.fromJson(response.data));

    Post? avatar;

    if (result.avatarId != null) {
      avatar = await postsClient.post(
        result.avatarId!,
        force: force,
        cancelToken: cancelToken,
      );
    }

    traits.value = traits.value.copyWith(
      denylist: result.blacklistedTags?.split('\n').trim() ?? [],
      // TODO: also store "perPage"
      avatar: avatar?.file,
    );

    return result;
  }
}
