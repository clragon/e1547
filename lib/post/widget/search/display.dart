import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

enum PostDisplayType { grid, comic, timeline }

class PostSliverDisplay extends StatelessWidget {
  const PostSliverDisplay({
    super.key,
    required this.controller,
    this.displayType = PostDisplayType.grid,
  });

  final PostController controller;
  final PostDisplayType displayType;

  @override
  Widget build(BuildContext context) {
    return switch (displayType) {
      PostDisplayType.grid => PostSliverGrid(controller: controller),
      PostDisplayType.comic => PostSliverComic(controller: controller),
      PostDisplayType.timeline => PostSliverTimeline(controller: controller),
    };
  }
}

class PostSliverGrid extends StatelessWidget {
  const PostSliverGrid({
    super.key,
    required this.controller,
    this.display = PostDisplayType.grid,
  });

  final PostController controller;
  final PostDisplayType display;

  @override
  Widget build(BuildContext context) {
    PagedChildBuilderDelegate<Post> buildBuilderDelegate(
      ItemWidgetBuilder<Post> itemBuilder,
    ) => defaultPagedChildBuilderDelegate<Post>(
      onRetry: controller.getNextPage,
      onEmpty: const Text('No posts'),
      onError: const Text('Failed to load posts'),
      itemBuilder: itemBuilder,
    );

    Widget itemBuilder(context, item, index) => ImageCacheSizeProvider(
      size: TileLayout.of(context).tileSize * 2,
      child: PostTile(post: item),
    );

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => switch (TileLayout.of(context).stagger) {
        GridQuilt.square => PagedSliverGrid<int, Post>(
          showNewPageErrorIndicatorAsGridChild: false,
          showNewPageProgressIndicatorAsGridChild: false,
          showNoMoreItemsIndicatorAsGridChild: false,
          state: controller.state,
          fetchNextPage: controller.getNextPage,
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
          state: controller.state,
          fetchNextPage: controller.getNextPage,
          builderDelegate: buildBuilderDelegate(
            (context, item, index) => AspectRatio(
              aspectRatio: 1 / (item.height / item.width),
              child: itemBuilder(context, item, index),
            ),
          ),
          crossAxisCount: TileLayout.of(context).crossAxisCount,
        ),
      },
    );
  }
}

class PostSliverComic extends StatelessWidget {
  const PostSliverComic({super.key, required this.controller});

  final PostController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => PagedSliverList(
        state: controller.state,
        fetchNextPage: controller.getNextPage,
        builderDelegate: defaultPagedChildBuilderDelegate<Post>(
          onRetry: controller.getNextPage,
          onEmpty: const Text('No posts'),
          onError: const Text('Failed to load posts'),
          itemBuilder: (context, item, index) => ImageCacheSizeProvider(
            size: 800,
            child: PostComicTile(post: item),
          ),
        ),
      ),
    );
  }
}

class PostSliverTimeline extends StatelessWidget {
  const PostSliverTimeline({super.key, required this.controller});

  final PostController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => PagedSliverList(
        state: controller.state,
        fetchNextPage: controller.getNextPage,
        builderDelegate: defaultPagedChildBuilderDelegate<Post>(
          onRetry: controller.getNextPage,
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
      ),
    );
  }
}
