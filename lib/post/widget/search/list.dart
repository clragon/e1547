import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

enum PostDisplayType { grid, comic, timeline }

class PostList extends StatelessWidget {
  const PostList({super.key, this.displayType = PostDisplayType.grid});

  final PostDisplayType displayType;

  @override
  Widget build(BuildContext context) => PostPageQueryBuilder(
    builder: (context, state, query) => PullToRefresh(
      onRefresh: query.invalidate,
      child: CustomScrollView(
        primary: true,
        slivers: [
          SliverPadding(
            padding: defaultActionListPadding,
            sliver: SliverPostList(displayType: displayType),
          ),
        ],
      ),
    ),
  );
}

class SliverPostList extends StatelessWidget {
  const SliverPostList({super.key, this.displayType = PostDisplayType.grid});

  final PostDisplayType displayType;

  @override
  Widget build(BuildContext context) => PostPageQueryBuilder(
    builder: (context, state, query) => switch (displayType) {
      PostDisplayType.grid => PostGridSliver(
        state: state.paging,
        fetchNextPage: query.getNextPage,
      ),
      PostDisplayType.comic => PostComicSliver(
        state: state.paging,
        fetchNextPage: query.getNextPage,
      ),
      PostDisplayType.timeline => PostTimelineSliver(
        state: state.paging,
        fetchNextPage: query.getNextPage,
      ),
    },
  );
}

class PostGridSliver extends StatelessWidget {
  const PostGridSliver({
    super.key,
    required this.state,
    required this.fetchNextPage,
  });

  final PagingState<int, Post> state;
  final VoidCallback fetchNextPage;

  @override
  Widget build(BuildContext context) {
    PagedChildBuilderDelegate<Post> buildBuilderDelegate(
      ItemWidgetBuilder<Post> itemBuilder,
    ) => defaultPagedChildBuilderDelegate<Post>(
      onRetry: fetchNextPage,
      onEmpty: const Text('No posts'),
      onError: const Text('Failed to load posts'),
      itemBuilder: itemBuilder,
    );

    Widget itemBuilder(context, item, index) => ImageCacheSizeProvider(
      size: TileLayout.of(context).tileSize * 2,
      child: PostTile(post: item),
    );

    return switch (TileLayout.of(context).stagger) {
      GridQuilt.square => PagedSliverGrid<int, Post>(
        showNewPageErrorIndicatorAsGridChild: false,
        showNewPageProgressIndicatorAsGridChild: false,
        showNoMoreItemsIndicatorAsGridChild: false,
        state: state,
        fetchNextPage: fetchNextPage,
        builderDelegate: buildBuilderDelegate(itemBuilder),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: TileLayout.of(context).crossAxisCount,
          childAspectRatio: 1 / TileLayout.of(context).tileHeightFactor,
        ),
      ),
      GridQuilt.vertical => PagedSliverMasonryGrid<int, Post>.count(
        showNewPageErrorIndicatorAsGridChild: false,
        showNewPageProgressIndicatorAsGridChild: false,
        showNoMoreItemsIndicatorAsGridChild: false,
        state: state,
        fetchNextPage: fetchNextPage,
        builderDelegate: buildBuilderDelegate(
          (context, item, index) => AspectRatio(
            aspectRatio: 1 / (item.height / item.width),
            child: itemBuilder(context, item, index),
          ),
        ),
        crossAxisCount: TileLayout.of(context).crossAxisCount,
      ),
    };
  }
}

class PostComicSliver extends StatelessWidget {
  const PostComicSliver({
    super.key,
    required this.state,
    required this.fetchNextPage,
  });

  final PagingState<int, Post> state;
  final VoidCallback fetchNextPage;

  @override
  Widget build(BuildContext context) {
    return PagedSliverList(
      state: state,
      fetchNextPage: fetchNextPage,
      builderDelegate: defaultPagedChildBuilderDelegate<Post>(
        onRetry: fetchNextPage,
        onEmpty: const Text('No posts'),
        onError: const Text('Failed to load posts'),
        itemBuilder: (context, item, index) => Padding(
          padding:
              LimitedWidthLayout.maybeOf(context)?.padding ?? EdgeInsets.zero,
          child: ImageCacheSizeProvider(
            size: 800,
            child: PostComicTile(post: item),
          ),
        ),
      ),
    );
  }
}

class PostTimelineSliver extends StatelessWidget {
  const PostTimelineSliver({
    super.key,
    required this.state,
    required this.fetchNextPage,
  });

  final PagingState<int, Post> state;
  final VoidCallback fetchNextPage;

  @override
  Widget build(BuildContext context) {
    return PagedSliverList(
      state: state,
      fetchNextPage: fetchNextPage,
      builderDelegate: defaultPagedChildBuilderDelegate<Post>(
        onRetry: fetchNextPage,
        onEmpty: const Text('No posts'),
        onError: const Text('Failed to load posts'),
        itemBuilder: (context, item, index) => Padding(
          padding:
              LimitedWidthLayout.maybeOf(context)?.padding ?? EdgeInsets.zero,
          child: ImageCacheSizeProvider(
            size: 800,
            child: PostFeedTile(post: item),
          ),
        ),
      ),
    );
  }
}
