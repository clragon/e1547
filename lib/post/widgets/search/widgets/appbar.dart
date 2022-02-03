import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

class PostSelectionAppBar extends StatelessWidget with AppBarSize {
  final Set<Post> Function()? onSelectAll;
  final void Function(Set<Post> selections) onChanged;
  final Set<Post> selections;

  const PostSelectionAppBar(
      {required this.selections, required this.onChanged, this.onSelectAll});

  @override
  Widget build(BuildContext context) {
    return SelectionAppBar<Post>(
      onSelectAll: onSelectAll,
      onChanged: onChanged,
      selections: selections,
      titleBuilder: (context) => selections.length == 1
          ? Text('post #${selections.first.id}')
          : Text('${selections.length} posts'),
      actions: [
        IconButton(
          icon: Icon(Icons.file_download),
          onPressed: () {
            postDownloadingNotification(context, Set.from(selections));
            onChanged({});
          },
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: LikeButton(
            isLiked: selections.isNotEmpty &&
                selections.every((post) => post.isFavorited),
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
                  context, Set.from(selections), isLiked);
              onChanged({});
              return !isLiked;
            },
          ),
        ),
      ],
    );
  }
}
