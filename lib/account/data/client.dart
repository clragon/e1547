import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/account/account.dart';
import 'package:e1547/stream/stream.dart';
import 'package:e1547/traits/traits.dart';

class AccountClient {
  AccountClient({required this.dio});

  final Dio dio;

  final ValueCache<QueryKey, Account?> cache = ValueCache(
    size: null,
    maxAge: const Duration(hours: 1),
  );

  Future<void> available() => dio.get('');

  Future<Account?> get({
    required String? username,
    bool? force,
    CancelToken? cancelToken,
  }) async => cache
      .stream(
        QueryKey([username]),
        fetch: () {
          if (username == null) return null;

          return dio
              .get('/users/$username.json', cancelToken: cancelToken)
              .then((response) => E621Account.fromJson(response.data));
        },
      )
      .future;

  Future<void> update({
    required String username,
    required Traits traits,
    CancelToken? cancelToken,
  }) async {
    cache.optimistic(
      QueryKey([username]),
      (previous) => previous?.copyWith(
        blacklistedTags: traits.denylist.join('\n'),
        perPage: traits.perPage,
      ),
      () => dio.put(
        '/users/$username.json',
        data: FormData.fromMap({
          'blacklisted_tags': traits.denylist.join('\n'),
        }),
        cancelToken: cancelToken,
      ),
    );
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
