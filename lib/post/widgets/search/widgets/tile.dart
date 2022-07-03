import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';

class PostTile extends StatelessWidget {
  final PostController post;
  final VoidCallback? onTap;

  const PostTile({
    required this.post,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget tag() {
      if (post.value.file.ext == 'gif') {
        return Container(
          color: Colors.black12,
          child: const Icon(
            Icons.gif,
            color: Colors.white,
          ),
        );
      }
      if (post.value.type == PostType.video) {
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
              animation: Listenable.merge([post]),
              builder: (context, value) => PostTileOverlay(
                post: post,
                child: Hero(
                  tag: post.value.hero,
                  child: PostImageWidget(
                    post: post.value,
                    size: ImageSize.sample,
                    fit: BoxFit.cover,
                    showProgress: false,
                    withPreview: false,
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
          clipBehavior: Clip.none,
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: settings.showPostInfo,
              builder: (context, value, child) => Column(
                children: [
                  Expanded(
                    child: image(),
                  ),
                  if (value) PostInfoBar(post: post),
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
                            builder: (context) => PostDetail(post: post),
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
  final PostController post;
  final Widget child;

  const PostTileOverlay({required this.post, required this.child});

  @override
  Widget build(BuildContext context) {
    if (post.value.flags.deleted) {
      return const Center(child: Text('deleted'));
    }
    if (post.value.type == PostType.unsupported) {
      return const Center(child: Text('unsupported'));
    }
    if (post.value.file.url == null) {
      return const Center(child: Text('unsafe'));
    }
    // TODO: make denying available in PostController
    if (post.parent!.isDenied(post.value)) {
      return const Center(child: Text('blacklisted'));
    }
    return child;
  }
}

class PostInfoBar extends StatelessWidget {
  final PostController post;

  const PostInfoBar({required this.post});

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
                      animation: Listenable.merge([post]),
                      selector: () => [post.value.voteStatus],
                      builder: (context, child) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(post.value.score.total.toString()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              post.value.score.total >= 0
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: () {
                                switch (post.value.voteStatus) {
                                  case VoteStatus.upvoted:
                                    return Colors.deepOrange;
                                  case VoteStatus.downvoted:
                                    return Colors.blue;
                                  case VoteStatus.unknown:
                                    return null;
                                }
                              }(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedSelector(
                      animation: Listenable.merge([post]),
                      selector: () => [post.value.isFavorited],
                      builder: (context, child) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(post.value.favCount.toString()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              Icons.favorite,
                              color: post.value.isFavorited
                                  ? Colors.pinkAccent
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(post.value.commentCount.toString()),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(Icons.comment),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(post.value.rating.name.toUpperCase()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(ratingIcons[post.value.rating]!),
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
