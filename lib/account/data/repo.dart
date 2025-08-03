import 'package:dio/dio.dart';
import 'package:e1547/account/account.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/traits/traits.dart';

class AccountRepo {
  AccountRepo({
    required this.persona,
    required this.client,
    required this.postClient,
  });

  final AccountClient client;
  final PostClient postClient;
  final Persona persona;

  Future<void> available() => client.available();

  Future<Account?> get({bool? force, CancelToken? cancelToken}) => client.get(
    username: persona.identity.username,
    force: force,
    cancelToken: cancelToken,
  );

  Future<Account?> pull({bool? force, CancelToken? cancelToken}) async {
    final account = await get(force: force, cancelToken: cancelToken);
    if (account == null) return null;

    Post? avatar;
    if (account.avatarId != null) {
      avatar = await postClient.get(
        id: account.avatarId!,
        force: force,
        cancelToken: cancelToken,
      );
    }

    persona.traits.value = persona.traits.value.copyWith(
      denylist: account.blacklistedTags?.split('\n').trim() ?? [],
      avatar: avatar?.sample ?? avatar?.file,
    );

    return account;
  }

  Future<void> update({
    required Traits traits,
    CancelToken? cancelToken,
  }) async {
    final username = persona.identity.username;
    if (username == null) return;
    await client.update(
      username: username,
      traits: traits,
      cancelToken: cancelToken,
    );
  }

  Future<void> push({required Traits traits, CancelToken? cancelToken}) async {
    final previous = persona.traits.value = traits;
    try {
      await update(traits: traits, cancelToken: cancelToken);
      persona.traits.value = persona.traits.value.copyWith(
        denylist: traits.denylist,
        perPage: traits.perPage,
      );
    } on DioException {
      persona.traits.value = persona.traits.value.copyWith(
        denylist: previous.denylist,
        perPage: previous.perPage,
      );
      rethrow;
    }
  }
}
