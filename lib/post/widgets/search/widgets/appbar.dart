import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

class PostSelectionAppBar extends StatelessWidget with PreferredSizeWidget {
  final PostController controller;
  final PreferredSizeWidget appbar;

  @override
  Size get preferredSize => appbar.preferredSize;

  const PostSelectionAppBar({
    required this.controller,
    required this.appbar,
  });

  @override
  Widget build(BuildContext context) {
    return SelectionAppBar<Post>(
      appbar: appbar,
      titleBuilder: (context, data) => data.selections.length == 1
          ? Text('post #${data.selections.first.id}')
          : Text('${data.selections.length} posts'),
      actionBuilder: (context, data) => [
        IconButton(
          icon: Icon(Icons.file_download),
          onPressed: () {
            postDownloadingNotification(context, Set.from(data.selections));
            data.onChanged({});
          },
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: LikeButton(
            isLiked: data.selections.isNotEmpty &&
                data.selections.every((post) => post.isFavorited),
            circleColor: CircleColor(start: Colors.pink, end: Colors.red),
            bubblesColor: BubblesColor(
                dotPrimaryColor: Colors.pink, dotSecondaryColor: Colors.red),
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
