import 'dart:math';

import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/markup/markup.dart';
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
                        cacheSize: context.watch<ImageCacheSize?>()?.size,
                      ),
                    ),
                  ),
                ),
                if (bottomBar != null) bottomBar!,
              ],
            ),
            Positioned(top: 0, right: 0, child: PostImageTag(post: post)),
            if (onTap != null)
              Material(
                type: MaterialType.transparency,
                child: InkWell(onTap: onTap),
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
    if (post.ext == 'gif') {
      return const ColoredBox(
        color: Colors.black12,
        child: Icon(Icons.gif, color: Colors.white),
      );
    }
    if (post.type == PostType.video) {
      return const ColoredBox(
        color: Colors.black12,
        child: Icon(Icons.play_arrow, color: Colors.white),
      );
    }
    return const SizedBox.shrink();
  }
}

class PostTileOverlay extends StatelessWidget {
  const PostTileOverlay({super.key, required this.post, required this.child});

  final Post post;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PostsConnector(
      post: post,
      builder: (context, post) {
        PostController? controller = context.watch<PostController?>();
        if (post.isDeleted) {
          return const Center(child: Text('deleted'));
        }
        if (post.type == PostType.unsupported) {
          return const Center(child: Text('unsupported'));
        }
        if (post.file == null) {
          return const Center(child: Text('unavailable'));
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
  const PostInfoBar({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: Theme.of(context).iconTheme.copyWith(size: 16),
      child: ColoredBox(
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
                        Text(post.vote.score.toString()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            post.vote.score >= 0
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color:
                                {
                                  VoteStatus.upvoted: Colors.deepOrange,
                                  VoteStatus.downvoted: Colors.blue,
                                  VoteStatus.unknown: null,
                                }[post.vote.status],
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
                        Text('${post.commentCount}'),
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
  PostController? controller = context.read<PostController?>();
  int? cacheSize = context.read<ImageCacheSize>().size;
  Navigator.of(context).push(
    MaterialPageRoute(
      builder:
          (context) => ImageCacheSizeProvider(
            size: cacheSize,
            child:
                controller != null
                    ? PostsRouteConnector(
                      controller: controller,
                      child: PostDetailGallery(
                        controller: controller,
                        initialPage: controller.items!.indexOf(post),
                      ),
                    )
                    : PostDetail(post: post),
          ),
    ),
  );
}

class PostTile extends StatelessWidget {
  const PostTile({super.key, required this.post, this.onTap});

  final Post post;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PostImageTile(
      post: post,
      onTap: onTap ?? () => defaultPushPostDetail(context, post),
      bottomBar: ValueListenableBuilder<bool>(
        valueListenable: context.watch<Settings>().showPostInfo,
        builder:
            (context, value, child) =>
                value ? PostInfoBar(post: post) : const SizedBox(),
      ),
    );
  }
}

class PostComicTile extends StatelessWidget {
  const PostComicTile({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: post.width / post.height,
      child: PostImageTile(
        post: post,
        size:
            post.type == PostType.video
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
  const PostFeedTile({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    int? cacheSize = context.read<ImageCacheSize>().size;

    Widget actions() {
      return Dimmed(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.comment),
                  onPressed:
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) => PostCommentsPage(postId: post.id),
                        ),
                      ),
                ),
                const SizedBox(width: 12),
                Text(post.commentCount.toString()),
              ],
            ),
            VoteDisplay(
              status: post.vote.status,
              score: post.vote.score,
              onUpvote: (isLiked) async {
                PostController controller = context.read<PostController>();
                ScaffoldMessengerState messenger = ScaffoldMessenger.of(
                  context,
                );
                if (context.read<Client>().hasLogin) {
                  controller
                      .vote(post: post, upvote: true, replace: !isLiked)
                      .then((value) {
                        if (!value) {
                          messenger.showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 1),
                              content: Text(
                                'Failed to upvote Post #${post.id}',
                              ),
                            ),
                          );
                        }
                      });
                  return !isLiked;
                } else {
                  return false;
                }
              },
              onDownvote: (isLiked) async {
                PostController controller = context.read<PostController>();
                ScaffoldMessengerState messenger = ScaffoldMessenger.of(
                  context,
                );
                if (context.read<Client>().hasLogin) {
                  controller
                      .vote(post: post, upvote: false, replace: !isLiked)
                      .then((value) {
                        if (!value) {
                          messenger.showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 1),
                              content: Text(
                                'Failed to downvote Post #${post.id}',
                              ),
                            ),
                          );
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
              onPressed:
                  () => Share.text(
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
        icon: Icon(Icons.more_vert, color: dimTextColor(context)),
        iconSize: 18,
        onSelected: (value) => value(),
        itemBuilder:
            (context) => [
              if (post.file != null)
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
          aspectRatio: max(post.width / post.height, 0.9),
          child: PostImageTile(
            post: post,
            onTap: () {
              PostController? controller = context.read<PostController?>();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) => PostVideoRoute(
                        post: post,
                        child: ImageCacheSizeProvider(
                          size: cacheSize,
                          child:
                              controller != null
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
            borderRadius: BorderRadius.circular(4),
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
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium!.copyWith(
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
