import 'package:e1547/domain/domain.dart';
import 'package:e1547/favorite/favorite.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';

class FavoriteRepo {
  FavoriteRepo({
    required this.persona,
    required this.client,
    required this.cache,
  });

  final Persona persona;
  final FavoriteClient client;
  final CachedQuery cache;

  final String queryKey = 'favorites';

  Future<List<Post>> page({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) => client.page(
    page: page,
    limit: limit,
    query: query,
    force: force,
    cancelToken: cancelToken,
  );

  InfiniteQuery<List<int>, int> usePage() => InfiniteQuery<List<int>, int>(
    cache: cache,
    key: [queryKey],
    getNextArg: (state) => state.nextPage,
    queryFn: (key) =>
        page(page: key).then((posts) => posts.map((post) => post.id).toList()),
  );

  Future<void> setFavorite({required int id, required bool favorite}) =>
      favorite ? client.add(id) : client.remove(id);

  Mutation<void, bool> useSetFavorite({required int id}) => Mutation(
    mutationFn: (isFavorite) => setFavorite(id: id, favorite: isFavorite),
    onSuccess: (data, isFavorite) {
      // TODO: this needs to invalidate favorite queries and optimistically update post queries
    },
  );
}
