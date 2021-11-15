import 'dart:math';

import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

class SelectionScope<T> extends StatelessWidget {
  final void Function(Set<T> selections) onChanged;
  final Set<T> selections;
  final Widget child;

  const SelectionScope(
      {required this.selections, required this.child, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: child,
      onWillPop: () async {
        if (selections.isNotEmpty) {
          onChanged({});
          return false;
        } else {
          return true;
        }
      },
    );
  }
}

class SelectionAppBar<T> extends StatelessWidget {
  final Set<T> Function()? onSelectAll;
  final void Function(Set<T> selections) onChanged;
  final Set<T> selections;
  final List<Widget> actions;

  final WidgetBuilder? titleBuilder;

  const SelectionAppBar({
    required this.selections,
    required this.onChanged,
    required this.actions,
    this.titleBuilder,
    this.onSelectAll,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultAppBar(
      title: titleBuilder?.call(context) ?? Text('${selections.length} items'),
      leading: IconButton(
        icon: Icon(Icons.clear),
        onPressed: () => onChanged({}),
      ),
      actions: [
        if (onSelectAll != null)
          IconButton(
            icon: Icon(Icons.select_all),
            onPressed: () {
              onChanged(onSelectAll!());
            },
          ),
        ...actions,
      ],
    );
  }
}

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
            postDownloadingSnackbar(context, Set.from(selections));
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
              postFavoritingSnackbar(context, Set.from(selections), isLiked);
              onChanged({});
              return !isLiked;
            },
          ),
        ),
      ],
    );
  }
}

class PostSelectionOverlay extends StatelessWidget {
  final Post post;
  final Set<Post> selections;
  final void Function(Post post) select;

  const PostSelectionOverlay(
      {required this.selections, required this.post, required this.select});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: selections.isNotEmpty ? () => select(post) : null,
      onLongPress: () => select(post),
      child: IgnorePointer(
        child: AnimatedOpacity(
          duration: defaultAnimationDuration,
          opacity: selections.contains(post) ? 1 : 0,
          child: Padding(
            padding: EdgeInsets.all(4),
            child: Container(
              color: Colors.black38,
              child: LayoutBuilder(
                builder: (context, constraint) => Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: min(constraint.maxHeight, constraint.maxWidth) * 0.4,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
