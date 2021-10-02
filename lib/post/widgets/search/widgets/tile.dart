import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';

class PostTile extends StatelessWidget {
  final Post post;
  final VoidCallback? onPressed;

  PostTile({
    required this.post,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Widget overlay({required Widget child}) {
      if (post.flags.deleted) {
        return Center(child: Text('deleted'));
      }
      if (post.type == PostType.Unsupported) {
        return Center(child: Text('unsupported'));
      }
      if (post.file.url == null) {
        return Center(child: Text('unsafe'));
      }
      return child;
    }

    Widget tag() {
      if (post.file.ext == 'gif') {
        return Container(
          color: Colors.black12,
          child: Icon(Icons.gif),
        );
      }
      if (post.type == PostType.Video) {
        return Container(
          color: Colors.black12,
          child: Icon(Icons.play_arrow),
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
              builder: (context, value) => overlay(
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

    return FakeCard(
      child: Stack(
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: settings.postInfo,
            builder: (context, value, child) {
              return Column(
                children: [
                  Expanded(
                    child: image(),
                  ),
                  if (value) PostInfoBar(post: post),
                ],
              );
            },
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AnimatedSelector(
                animation: post,
                selector: () => [post.voteStatus],
                builder: (context, child) => Row(
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
                  children: [
                    Text(post.favCount.toString()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        Icons.favorite,
                        color: post.isFavorited ? Colors.pinkAccent : null,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(post.commentCount.toString()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.comment),
                  ),
                ],
              ),
              Row(
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
      ),
    );
  }
}
