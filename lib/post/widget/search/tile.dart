import 'package:context_plus/context_plus.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/vote/vote.dart';
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
    if (post.isDeleted) {
      return const Center(child: Text('deleted'));
    }
    if (post.type == PostType.unsupported) {
      return const Center(child: Text('unsupported'));
    }
    if (post.file == null) {
      return const Center(child: Text('unavailable'));
    }
    /*
    if (controller?.isDenied(post) ?? false) {
      return const Center(child: Text('blacklisted'));
    }
    */
    return child;
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
                            color: {
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

void defaultPushPostDetail(BuildContext context, int id) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (context) => PostDetailPage(id: id)));
}

class PostTile extends StatelessWidget {
  const PostTile({super.key, required this.post, this.onTap});

  final Post post;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PostImageTile(
      post: post,
      onTap: onTap ?? () => defaultPushPostDetail(context, post.id),
      bottomBar: SettingsRef.of(context).value.showPostInfoBar
          ? PostInfoBar(post: post)
          : const SizedBox(),
    );
  }
}
