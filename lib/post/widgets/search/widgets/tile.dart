import 'dart:math';

import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class PostImageTile extends StatelessWidget {
  const PostImageTile({
    super.key,
    required this.controller,
    this.size,
    this.fit,
    this.showProgress,
    this.withLowRes,
    this.onTap,
    this.bottomBar,
  });

  final PostController controller;
  final VoidCallback? onTap;
  final PostImageSize? size;
  final BoxFit? fit;
  final bool? showProgress;
  final bool? withLowRes;
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Post>(
      valueListenable: controller,
      builder: (context, post, child) => Card(
        clipBehavior: Clip.antiAlias,
        child: SelectionItemOverlay(
          item: post,
          child: Stack(
            fit: StackFit.passthrough,
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: PostTileOverlay(
                            controller: controller,
                            child: Hero(
                              tag: post.link,
                              child: PostImageWidget(
                                post: post,
                                size: size ?? PostImageSize.sample,
                                fit: fit ?? BoxFit.cover,
                                showProgress: showProgress ?? false,
                                withLowRes: withLowRes ?? false,
                                cacheSize: context.read<LowResCacheSize>().size,
                              ),
                            ),
                          ),
                        ),
                      ],
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
  const PostTileOverlay({required this.controller, required this.child});

  final PostController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        Post post = controller.value;
        if (post.flags.deleted) {
          return const Center(child: Text('deleted'));
        }
        if (post.type == PostType.unsupported) {
          return const Center(child: Text('unsupported'));
        }
        if (post.file.url == null) {
          return const Center(child: Text('unsafe'));
        }
        if (controller.isDenied) {
          return const Center(child: Text('blacklisted'));
        }
        return child!;
      },
      child: child,
    );
  }
}

class PostInfoBar extends StatelessWidget {
  const PostInfoBar({required this.controller});

  final PostController controller;

  Post get post => controller.value;

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
                    AnimatedSelector(
                      animation: Listenable.merge([controller]),
                      selector: () => [post.voteStatus],
                      builder: (context, child) => Row(
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
                    ),
                    AnimatedSelector(
                      animation: Listenable.merge([controller]),
                      selector: () => [post.isFavorited],
                      builder: (context, child) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(post.favCount.toString()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              Icons.favorite,
                              color:
                                  post.isFavorited ? Colors.pinkAccent : null,
                            ),
                          ),
                        ],
                      ),
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

void defaultPushPostDetail(BuildContext context, PostController controller) {
  int? cacheSize = context.read<LowResCacheSize>().size;
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => LowResCacheSizeProvider(
        size: cacheSize,
        child: controller.parent != null
            ? PostControllerConnector(
                controller: controller.parent!,
                child: PostDetailGallery(
                  controller: controller.parent!,
                  initialPage:
                      controller.parent!.itemList!.indexOf(controller.value),
                ),
              )
            : PostDetail(controller: controller),
      ),
    ),
  );
}

class PostTile extends StatelessWidget {
  const PostTile({
    required this.controller,
    this.onTap,
  });

  final PostController controller;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PostImageTile(
      controller: controller,
      onTap: onTap ?? () => defaultPushPostDetail(context, controller),
      bottomBar: ValueListenableBuilder<bool>(
        valueListenable: context.watch<Settings>().showPostInfo,
        builder: (context, value, child) =>
            value ? PostInfoBar(controller: controller) : const SizedBox(),
      ),
    );
  }
}

class PostComicTile extends StatelessWidget {
  const PostComicTile({
    super.key,
    required this.controller,
  });

  final PostController controller;

  Post get post => controller.value;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: post.file.width / post.file.height,
      child: PostImageTile(
        controller: controller,
        size: PostImageSize.file,
        withLowRes: true,
        showProgress: false,
        onTap: () => defaultPushPostDetail(context, controller),
      ),
    );
  }
}

class PostFeedTile extends StatelessWidget {
  const PostFeedTile({
    super.key,
    required this.controller,
  });

  final PostController controller;

  Post get post => controller.value;

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
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
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
            AnimatedSelector(
              animation: controller,
              selector: () => [post.voteStatus],
              builder: (context, child) => VoteDisplay(
                status: post.voteStatus,
                score: post.score.total,
                onUpvote: (isLiked) async {
                  if (context.read<Client>().hasLogin) {
                    controller
                        .vote(upvote: true, replace: !isLiked)
                        .then((value) {
                      if (!value) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
                  if (context.read<Client>().hasLogin) {
                    controller
                        .vote(upvote: false, replace: !isLiked)
                        .then((value) {
                      if (!value) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
            ),
            Row(
              children: [
                FavoriteButton(controller: controller),
                const SizedBox(width: 4),
                AnimatedSelector(
                  animation: controller,
                  selector: () => [post.favCount],
                  builder: (context, child) => Text(
                    post.favCount.toString(),
                  ),
                ),
              ],
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.share),
              onPressed: () =>
                  Share.share(context.read<Client>().withHost(post.link)),
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
          size: 18,
        ),
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
            controller: controller,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PostVideoRoute(
                  post: post,
                  child: LowResCacheSizeProvider(
                    size: cacheSize,
                    child: controller.parent != null
                        ? PostControllerConnector(
                            controller: controller.parent!,
                            child: PostFullscreen(
                              controller: controller,
                              showFrame: true,
                            ),
                          )
                        : PostFullscreen(
                            controller: controller,
                            showFrame: true,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(4),
      child: InkWell(
        onTap: () => defaultPushPostDetail(context, controller),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 4),
                  TimedText(
                    created: post.createdAt,
                    child: DefaultTextStyle(
                      style: Theme.of(context).textTheme.bodyText2!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                      child: ArtistName(post: post),
                    ),
                  ),
                  const Spacer(),
                  menu(),
                ],
              ),
              if (post.description.isNotEmpty)
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 8),
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
    );
  }
}
