import 'package:cached_query/cached_query.dart';
import 'package:e1547/domain/domain.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/widgets.dart';

const String postQueryKey = 'posts';

final _postCache = CacheSync<Post, int>(
  baseKey: postQueryKey,
  getId: (post) => post.id,
);

Query<Post> usePost(BuildContext context, int id) {
  final domain = DomainRef.of(context);
  return Query(
    key: [postQueryKey, id],
    queryFn: () => domain.posts.get(id: id),
    onSuccess: (post) => _postCache.setItem(post),
  );
}

typedef InfinitePostQuery = InfiniteQuery<List<Post>, int>;

InfinitePostQuery usePostPage(BuildContext context) {
  final domain = DomainRef.of(context);
  return InfinitePostQuery(
    key: [postQueryKey],
    getNextArg: (state) => (state?.pageParams.lastOrNull ?? 0) + 1,
    queryFn: (page) => domain.posts.page(page: page),
    onSuccess: (data) => data.pages.forEach(_postCache.setItems),
  );
}

Mutation<void, bool> useSetFavoritePost(
  BuildContext context, {
  required int id,
}) {
  final domain = DomainRef.of(context);
  return Mutation(
    queryFn: (isFavorite) =>
        domain.posts.setFavorite(id: id, favorite: isFavorite),
    onSuccess: (_, favorite) => _postCache.updateItem(
      id,
      (post) => post.copyWith(
        isFavorited: favorite,
        favCount: favorite ? post.favCount + 1 : post.favCount - 1,
      ),
    ),
  );
}
