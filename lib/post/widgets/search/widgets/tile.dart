import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PostTile extends StatelessWidget {
  final Post post;
  final VoidCallback? onPressed;

  const PostTile({
    required this.post,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Widget tag() {
      if (post.file.ext == 'gif') {
        return Container(
          color: Colors.black12,
          child: Icon(
            Icons.gif,
            color: Colors.white,
          ),
        );
      }
      if (post.type == PostType.video) {
        return Container(
          color: Colors.black12,
          child: Icon(
            Icons.play_arrow,
            color: Colors.white,
          ),
        );
      }
      return SizedBox.shrink();
    }

    Widget image() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: post,
              builder: (context, value) => PostTileOverlay(
                post: post,
                child: Hero(
                  tag: post.hero,
                  child: PostImageWidget(
                    post: post,
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
      child: Stack(
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
              onTap: onPressed,
            ),
          ),
        ],
      ),
    );
  }
}

class PostTileOverlay extends StatelessWidget {
  final Post post;
  final Widget child;

  const PostTileOverlay({required this.post, required this.child});

  @override
  Widget build(BuildContext context) {
    if (post.flags.deleted) {
      return Center(child: Text('deleted'));
    }
    if (post.type == PostType.unsupported) {
      return Center(child: Text('unsupported'));
    }
    if (post.file.url == null) {
      return Center(child: Text('unsafe'));
    }
    if (post.isBlacklisted) {
      return Center(child: Text('blacklisted'));
    }
    return child;
  }
}

class PostInfoBar extends StatelessWidget {
  final Post post;

  const PostInfoBar({required this.post});

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: Theme.of(context).iconTheme.copyWith(
            size: 16,
          ),
      child: Container(
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  direction: Axis.horizontal,
                  children: [
                    AnimatedSelector(
                      animation: post,
                      selector: () => [post.voteStatus],
                      builder: (context, child) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(post.score.total.toString()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              post.score.total >= 0
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: () {
                                switch (post.voteStatus) {
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
                      animation: post,
                      selector: () => [post.isFavorited],
                      builder: (context, child) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(post.favCount.toString()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
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
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(Icons.comment),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(ratingValues.reverse![post.rating]!.toUpperCase()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(ratingIcons[post.rating]!),
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
