import 'dart:math';

import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';

class PostImageTile extends StatelessWidget {
  const PostImageTile({
    super.key,
    required this.post,
    this.size,
    this.fit,
    this.showProgress,
    this.withLowRes,
    this.onTap,
    this.bottomBar,
  });

  final Post post;
  final VoidCallback? onTap;
  final PostImageSize? size;
  final BoxFit? fit;
  final bool? showProgress;
  final bool? withLowRes;
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SelectionItemOverlay(
        item: post,
        child: Stack(
          fit: StackFit.passthrough,
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: PostTileOverlay(
                    post: post,
                    child: Hero(
                      tag: post.link,
                      child: PostImageWidget(
                        post: post,
                        size: size ?? PostImageSize.sample,
                        fit: fit ?? BoxFit.cover,
                        showProgress: showProgress ?? false,
                        withLowRes: withLowRes ?? false,
                        cacheSize: context.read<LowResCacheSize?>()?.size,
                      ),
                    ),
                  ),
                ),
                if (bottomBar != null) bottomBar!,
              ],
            ),
            Positioned(top: 0, right: 0, child: PostImageTag(post: post)),
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PostImageTag extends StatelessWidget {
  const PostImageTag({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    if (post.file.ext == 'gif') {
      return Container(
        color: Colors.black12,
        child: const Icon(
          Icons.gif,
          color: Colors.white,
        ),
      );
    }
    if (post.type == PostType.video) {
      return Container(
        color: Colors.black12,
        child: const Icon(
          Icons.play_arrow,
          color: Colors.white,
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class PostTileOverlay extends StatelessWidget {
  const PostTileOverlay({required this.post, required this.child});

  final Post post;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PostsConnector(
      post: post,
      builder: (context, post) {
        PostsController? controller = context.watch<PostsController?>();
        if (post.flags.deleted) {
          return const Center(child: Text('deleted'));
        }
        if (post.type == PostType.unsupported) {
          return const Center(child: Text('unsupported'));
        }
        if (post.file.url == null) {
          return const Center(child: Text('unsafe'));
        }
        if (controller?.isDenied(post) ?? false) {
          return const Center(child: Text('blacklisted'));
        }
        return child;
      },
    );
  }
}

class PostInfoBar extends StatelessWidget {
  const PostInfoBar({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: Theme.of(context).iconTheme.copyWith(size: 16),
      child: Container(
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(post.score.total.toString()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            post.score.total >= 0
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: {
                              VoteStatus.upvoted: Colors.deepOrange,
                              VoteStatus.downvoted: Colors.blue,
                              VoteStatus.unknown: null,
                            }[post.voteStatus],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(post.favCount.toString()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            Icons.favorite,
                            color: post.isFavorited ? Colors.pinkAccent : null,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(post.commentCount.toString()),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(Icons.comment),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(post.rating.name.toUpperCase()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: post.rating.icon,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void defaultPushPostDetail(BuildContext context, Post post) {
  PostsController? controller = context.read<PostsController?>();
  int? cacheSize = context.read<LowResCacheSize>().size;
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => LowResCacheSizeProvider(
        size: cacheSize,
        child: controller != null
            ? PostsRouteConnector(
                controller: controller,
                child: PostDetailGallery(
                  controller: controller,
                  initialPage: controller.itemList!.indexOf(post),
                ),
              )
            : PostDetail(post: post),
      ),
    ),
  );
}

class PostTile extends StatelessWidget {
  const PostTile({
    required this.post,
    this.onTap,
  });

  final Post post;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PostImageTile(
      post: post,
      onTap: onTap ?? () => defaultPushPostDetail(context, post),
      bottomBar: ValueListenableBuilder<bool>(
        valueListenable: context.watch<Settings>().showPostInfo,
        builder: (context, value, child) =>
            value ? PostInfoBar(post: post) : const SizedBox(),
      ),
    );
  }
}

class PostComicTile extends StatelessWidget {
  const PostComicTile({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: post.file.width / post.file.height,
      child: PostImageTile(
        post: post,
        size: post.type == PostType.video
            ? PostImageSize.sample
            : PostImageSize.file,
        withLowRes: true,
        showProgress: false,
        onTap: () => defaultPushPostDetail(context, post),
      ),
    );
  }
}

class PostFeedTile extends StatelessWidget {
  const PostFeedTile({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context) {
    int? cacheSize = context.read<LowResCacheSize>().size;

    Widget actions() {
      return DimSubtree(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.comment),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PostCommentsPage(postId: post.id),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(post.commentCount.toString()),
              ],
            ),
            VoteDisplay(
              status: post.voteStatus,
              score: post.score.total,
              onUpvote: (isLiked) async {
                PostsController controller = context.read<PostsController>();
                final messenger = ScaffoldMessenger.of(context);
                if (context.read<Client>().hasLogin) {
                  controller
                      .vote(post: post, upvote: true, replace: !isLiked)
                      .then((value) {
                    if (!value) {
                      messenger.showSnackBar(SnackBar(
                        duration: const Duration(seconds: 1),
                        content: Text('Failed to upvote Post #${post.id}'),
                      ));
                    }
                  });
                  return !isLiked;
                } else {
                  return false;
                }
              },
              onDownvote: (isLiked) async {
                PostsController controller = context.read<PostsController>();
                final messenger = ScaffoldMessenger.of(context);
                if (context.read<Client>().hasLogin) {
                  controller
                      .vote(post: post, upvote: false, replace: !isLiked)
                      .then((value) {
                    if (!value) {
                      messenger.showSnackBar(SnackBar(
                        duration: const Duration(seconds: 1),
                        content: Text('Failed to downvote Post #${post.id}'),
                      ));
                    }
                  });
                  return !isLiked;
                } else {
                  return false;
                }
              },
            ),
            Row(
              children: [
                FavoriteButton(post: post),
                const SizedBox(width: 4),
                Text(post.favCount.toString()),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => Share.share(
                context,
                context.read<Client>().withHost(post.link),
              ),
            ),
          ],
        ),
      );
    }

    Widget menu() {
      return PopupMenuButton<VoidCallback>(
        icon: Icon(
          Icons.more_vert,
          color: dimTextColor(context),
        ),
        iconSize: 18,
        onSelected: (value) => value(),
        itemBuilder: (context) => [
          if (post.file.url != null)
            PopupMenuTile(
              value: () => postDownloadingNotification(context, {post}),
              title: 'Download',
              icon: Icons.file_download,
            ),
          PopupMenuTile(
            value: () => launch(context.read<Client>().withHost(post.link)),
            title: 'Browse',
            icon: Icons.open_in_browser,
          ),
        ],
      );
    }

    Widget image() {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 400),
        child: AspectRatio(
          aspectRatio: max(post.file.width / post.file.height, 0.9),
          child: PostImageTile(
            post: post,
            onTap: () {
              PostsController? controller = context.read<PostsController?>();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PostVideoRoute(
                    post: post,
                    child: LowResCacheSizeProvider(
                      size: cacheSize,
                      child: controller != null
                          ? ChangeNotifierProvider.value(
                              value: controller,
                              child: PostsRouteConnector(
                                controller: controller,
                                child: PostFullscreen(post: post),
                              ),
                            )
                          : PostFullscreen(post: post),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(4),
          child: InkWell(
            onTap: () => defaultPushPostDetail(context, post),
            child: Padding(
              padding: const EdgeInsets.all(8).copyWith(bottom: 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 4),
                      Expanded(
                        child: TimedText(
                          created: post.createdAt,
                          child: DefaultTextStyle(
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                            child: ArtistName(post: post),
                          ),
                        ),
                      ),
                      menu(),
                    ],
                  ),
                  if (post.description.isNotEmpty)
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: DText(post.description.ellipse(200)),
                          ),
                        ),
                      ],
                    ),
                  image(),
                  const SizedBox(height: 8),
                  actions(),
                ],
              ),
            ),
          ),
        ),
        const Divider(indent: 8, endIndent: 8),
      ],
    );
  }
}
