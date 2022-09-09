import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PostTile extends StatelessWidget {
  const PostTile({
    required this.controller,
    this.onTap,
  });

  final PostController controller;
  final VoidCallback? onTap;

  Post get post => controller.value;

  @override
  Widget build(BuildContext context) {
    Widget tag() {
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

    Widget image() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: Listenable.merge([controller]),
              builder: (context, value) => PostTileOverlay(
                controller: controller,
                child: Hero(
                  tag: post.link,
                  child: PostImageWidget(
                    post: post,
                    size: PostImageSize.sample,
                    fit: BoxFit.cover,
                    showProgress: false,
                    withPreview: false,
                    cacheSize: context.read<SampleCacheSize>().size,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SelectionItemOverlay(
        item: post,
        child: Stack(
          fit: StackFit.passthrough,
          clipBehavior: Clip.none,
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: context.watch<Settings>().showPostInfo,
              builder: (context, value, child) => Column(
                children: [
                  Expanded(
                    child: image(),
                  ),
                  if (value) PostInfoBar(controller: controller),
                ],
              ),
            ),
            Positioned(top: 0, right: 0, child: tag()),
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onTap ??
                    () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                PostDetail(controller: controller),
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
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
