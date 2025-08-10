import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

class PostSelectionAppBar extends StatelessWidget with AppBarBuilderWidget {
  const PostSelectionAppBar({
    super.key,
    required this.controller,
    required this.child,
  });

  final PostController controller;
  @override
  final PreferredSizeWidget child;

  @override
  Widget build(BuildContext context) {
    return SelectionAppBar<Post>(
      child: child,
      titleBuilder: (context, data) => data.selections.length == 1
          ? Text('post #${data.selections.first.id}')
          : Text('${data.selections.length} posts'),
      actionBuilder: (context, data) => [
        IconButton(
          icon: const Icon(Icons.file_download),
          onPressed: () {
            postDownloadingNotification(context, Set.from(data.selections));
            data.onChanged({});
          },
        ),
        InkResponse(
          onTap: () {},
          child: LikeButton(
            isLiked:
                data.selections.isNotEmpty &&
                data.selections.every((post) => post.isFavorited),
            circleColor: const CircleColor(start: Colors.pink, end: Colors.red),
            bubblesColor: const BubblesColor(
              dotPrimaryColor: Colors.pink,
              dotSecondaryColor: Colors.red,
            ),
            likeBuilder: (bool isLiked) => Icon(
              Icons.favorite,
              color: isLiked
                  ? Colors.pinkAccent
                  : Theme.of(context).iconTheme.color,
            ),
            onTap: (isLiked) async {
              postFavoritingNotification(
                context,
                Set.from(data.selections),
                controller,
                isLiked,
              );
              data.onChanged({});
              return !isLiked;
            },
          ),
        ),
      ],
    );
  }
}
