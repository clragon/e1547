import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/traits/traits.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/foundation.dart';

class E621AccountService extends AccountService {
  E621AccountService({
    required Dio dio,
    required this.identity,
    required this.traits,
    required this.postsClient,
  }) : _dio = dio;

  final Dio _dio;
  final Identity identity;
  final ValueNotifier<Traits> traits;
  final PostService postsClient;

  @override
  Future<Account?> get({bool? force, CancelToken? cancelToken}) async {
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
      avatar = await postsClient.get(
        id: result.avatarId!,
        force: force,
        cancelToken: cancelToken,
      );
    }

    traits.value = traits.value.copyWith(
      // TODO: also store "id"
      denylist: result.blacklistedTags?.split('\n').trim() ?? [],
      // TODO: also store "perPage"
      avatar: avatar?.file,
    );

    return result;
  }
}

extension E621Account on Account {
  static Account fromJson(dynamic json) => pick(json).letOrThrow(
        (pick) => Account(
          id: pick('id').asIntOrThrow(),
          name: pick('name').asStringOrThrow(),
          avatarId: pick('avatar_id').asIntOrNull(),
          blacklistedTags: pick('blacklisted_tags').asStringOrNull(),
          perPage: pick('per_page').asIntOrNull(),
        ),
      );
}
