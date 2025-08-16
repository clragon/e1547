import 'package:cached_query/cached_query.dart';
import 'package:e1547/domain/domain.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/widgets.dart';

void _updatePostCache(int id, Post Function(Post) updateFn) {
  final singlePostQuery =
      CachedQuery.instance.getQuery(['post', id]) as Query<Post>?;
  if (singlePostQuery != null) {
    final currentPost = singlePostQuery.state.data;
    if (currentPost != null) {
      final updatedPost = updateFn(currentPost);
      if (updatedPost != currentPost) {
        singlePostQuery.setData(updatedPost);
      }
    }
  }

  CachedQuery.instance
      .whereQuery(
        (query) => switch (query) {
          InfinitePostQuery q => q.state.data?.pages.isNotEmpty ?? false,
          _ => false,
        },
      )
      ?.cast<InfinitePostQuery>()
      .forEach((query) {
        final currentData = query.state.data!;
        bool hasChanges = false;
        final updatedPages = currentData.pages
            .map(
              (page) => page.map((post) {
                if (post.id == id) {
                  final updatedPost = updateFn(post);
                  if (updatedPost != post) {
                    hasChanges = true;
                  }
                  return updatedPost;
                }
                return post;
              }).toList(),
            )
            .toList();

        if (hasChanges) {
          query.setData(
            InfiniteQueryData(
              pages: updatedPages,
              pageParams: currentData.pageParams,
            ),
          );
        }
      });
}

void _createOrUpdatePostCache(Post post, Domain domain) {
  final singlePostQuery =
      CachedQuery.instance.getQuery(['post', post.id]) as Query<Post>?;
  if (singlePostQuery != null) {
    final currentPost = singlePostQuery.state.data;
    if (currentPost != post) {
      singlePostQuery.setData(post);
    }
  } else {
    final newQuery = Query<Post>(
      key: ['post', post.id],
      queryFn: () => domain.posts.get(id: post.id),
    );
    newQuery.setData(post);
  }

  _updatePostCache(post.id, (_) => post);
}

Query<Post> usePost(BuildContext context, int id) {
  final domain = DomainRef.of(context);
  return Query(
    key: ['post', id],
    queryFn: () => domain.posts.get(id: id),
    onSuccess: (post) => _createOrUpdatePostCache(post, domain),
  );
}

typedef InfinitePostQuery = InfiniteQuery<List<Post>, int>;

InfinitePostQuery usePostPage(BuildContext context) {
  final domain = DomainRef.of(context);
  return InfinitePostQuery(
    key: ['posts'],
    getNextArg: (state) => (state?.pageParams.lastOrNull ?? 0) + 1,
    queryFn: (page) => domain.posts.page(page: page),
    onSuccess: (data) => data.lastPage!.forEach(
      (post) => _createOrUpdatePostCache(post, domain),
    ),
  );
}

Mutation<void, bool> useSetFavoritePost(
  BuildContext context, {
  required int id,
}) {
  final domain = DomainRef.of(context);
  return Mutation(
    key: ['post', 'favorite', id],
    queryFn: (isFavorite) =>
        domain.posts.setFavorite(id: id, favorite: isFavorite),
    onSuccess: (_, favorite) => _updatePostCache(
      id,
      (post) => post.copyWith(
        isFavorited: favorite,
        favCount: favorite ? post.favCount + 1 : post.favCount - 1,
      ),
    ),
  );
}
