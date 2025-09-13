import 'dart:async';

import 'package:e1547/domain/domain.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/user/user.dart';

class UserRepo {
  UserRepo({required this.persona, required this.client, required this.cache});

  final Persona persona;
  final UserClient client;
  final CachedQuery cache;

  final String queryKey = 'users';

  late final _userCache = cache.bridge<User, String>(
    queryKey,
    fetch: (id) => get(id: id),
  );

  Future<User> get({required String id, CancelToken? cancelToken}) =>
      client.get(id: id, force: true, cancelToken: cancelToken);

  Query<User> useGet({required String id, bool? vendored}) => Query(
    cache: cache,
    key: [queryKey, id],
    queryFn: () => get(id: id),
    config: _userCache.getConfig(vendored: vendored),
  );
}
