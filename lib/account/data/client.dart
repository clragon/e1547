import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/account/account.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/stream/stream.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/foundation.dart';

class AccountClient {
  AccountClient({
    required this.dio,
    required this.identity,
    required this.traits,
    required this.postClient,
  });

  final Dio dio;
  final Identity identity;
  final ValueNotifier<Traits> traits;
  final PostClient postClient;

  final ValueCache<QueryKey, Account?> cache = ValueCache(
    size: null,
    maxAge: const Duration(hours: 1),
  );

  Future<void> available() => dio.get('');

  Future<Account?> get({bool? force, CancelToken? cancelToken}) async => cache
      .stream(
        QueryKey([identity.username]),
        fetch: () {
          if (identity.username == null) return null;

          return dio
              .get('/users/${identity.username}.json', cancelToken: cancelToken)
              .then((response) => E621Account.fromJson(response.data));
        },
      )
      .future;

  Future<Account?> pull({bool? force, CancelToken? cancelToken}) async =>
      get(
        force: force,
        cancelToken: cancelToken,
      ).streamed.distinct((a, b) => a?.id == b?.id).asyncMap((account) async {
        if (account == null) return null;

        Post? avatar;

        if (account.avatarId != null) {
          avatar = await postClient.get(
            id: account.avatarId!,
            force: force,
            cancelToken: cancelToken,
          );
        }

        traits.value = traits.value.copyWith(
          denylist: account.blacklistedTags?.split('\n').trim() ?? [],
          avatar: avatar?.sample ?? avatar?.file,
        );

        return account;
      }).future;

  Future<void> update({
    required Traits traits,
    CancelToken? cancelToken,
  }) async {
    if (identity.username == null) return;
    cache.optimistic(
      QueryKey([identity.username]),
      (previous) => previous?.copyWith(
        blacklistedTags: traits.denylist.join('\n'),
        perPage: traits.perPage,
      ),
      () => dio.put(
        '/users/${identity.username}.json',
        data: FormData.fromMap({
          'blacklisted_tags': traits.denylist.join('\n'),
        }),
        cancelToken: cancelToken,
      ),
    );
  }

  Future<void> push({required Traits traits, CancelToken? cancelToken}) async {
    Traits previous = this.traits.value = traits;
    try {
      await update(traits: traits, cancelToken: cancelToken);
      this.traits.value = this.traits.value.copyWith(
        denylist: traits.denylist,
        perPage: traits.perPage,
      );
    } on DioException {
      this.traits.value = this.traits.value.copyWith(
        denylist: previous.denylist,
        perPage: previous.perPage,
      );
      rethrow;
    }
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
