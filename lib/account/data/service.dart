import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/account/account.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/foundation.dart';

class AccountService {
  AccountService({
    required this.dio,
    required this.identity,
    required this.traits,
    required this.postsService,
  });

  final Dio dio;
  final Identity identity;
  final ValueNotifier<Traits> traits;
  final PostService postsService;

  Future<void> available() => dio.get('');

  Future<void> push({required Traits traits, CancelToken? cancelToken}) async {
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

  Future<void> pull({bool? force, CancelToken? cancelToken}) =>
      get(force: force, cancelToken: cancelToken);

  Future<Account?> get({bool? force, CancelToken? cancelToken}) async {
    if (identity.username == null) return null;

    Account result = await dio
        .get(
          '/users/${identity.username}.json',
          options:
              ClientCacheConfig(
                maxAge: const Duration(hours: 1),
                policy:
                    (force ?? false)
                        ? CachePolicy.refresh
                        : CachePolicy.request,
              ).toOptions(),
          cancelToken: cancelToken,
        )
        .then((response) => E621Account.fromJson(response.data));

    Post? avatar;

    if (result.avatarId != null) {
      // TODO: this shouldnt be here
      avatar = await postsService.get(
        id: result.avatarId!,
        force: force,
        cancelToken: cancelToken,
      );
    }

    traits.value = traits.value.copyWith(
      // TODO: also store "id"
      denylist: result.blacklistedTags?.split('\n').trim() ?? [],
      // TODO: also store "perPage"
      // TODO: this shouldn't be file but sample
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
