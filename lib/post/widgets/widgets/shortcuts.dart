import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PostFavoriteIntent extends Intent {
  /// Indicates that a post be favorited.
  const PostFavoriteIntent();
}

class PostUnfavoriteIntent extends Intent {
  /// Indicates that a post be unfavorited.
  const PostUnfavoriteIntent();
}

class PostUpvoteIntent extends Intent {
  /// Indicates that a post should be upvoted.
  const PostUpvoteIntent();
}

class PostDownvoteIntent extends Intent {
  /// Indicates that a post should be downvoted.
  const PostDownvoteIntent();
}

class PostShortcuts extends StatelessWidget {
  const PostShortcuts({
    super.key,
    required this.child,
    required this.post,
    this.autoFocus = true,
  });

  /// The child widget in which these shortcuts should be available.
  final Widget child;

  /// The post that the shortcuts should work on.
  final PostController post;

  /// Whether the shortcuts should request focus for its child.
  final bool autoFocus;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.keyF): PostFavoriteIntent(),
        SingleActivator(LogicalKeyboardKey.keyF, shift: true):
            PostUnfavoriteIntent(),
        SingleActivator(LogicalKeyboardKey.keyW): PostUpvoteIntent(),
        SingleActivator(LogicalKeyboardKey.keyS): PostDownvoteIntent(),
      },
      child: Actions(
        actions: {
          PostFavoriteIntent: CallbackAction<PostFavoriteIntent>(
            onInvoke: (intent) async => post.fav().then((value) {
              if (!value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 1),
                    content: Text(
                        'Failed to add Post #${post.value.id} to favorites'),
                  ),
                );
              }
              return null;
            }),
          ),
          PostUnfavoriteIntent: CallbackAction<PostUnfavoriteIntent>(
            onInvoke: (intent) async => post.unfav().then((value) {
              if (!value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 1),
                    content: Text(
                        'Failed to remove Post #${post.value.id} from favorites'),
                  ),
                );
              }
              return null;
            }),
          ),
          PostUpvoteIntent: CallbackAction<PostUpvoteIntent>(
            onInvoke: (intent) async => post
                .vote(
              upvote: true,
              replace: post.value.voteStatus == VoteStatus.unknown,
            )
                .then((value) {
              if (!value) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: const Duration(seconds: 1),
                  content: Text('Failed to upvote Post #${post.value.id}'),
                ));
              }
              return null;
            }),
          ),
          PostDownvoteIntent: CallbackAction<PostDownvoteIntent>(
            onInvoke: (intent) async => post
                .vote(
              upvote: false,
              replace: post.value.voteStatus == VoteStatus.unknown,
            )
                .then((value) {
              if (!value) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: const Duration(seconds: 1),
                  content: Text('Failed to downvote Post #${post.value.id}'),
                ));
              }
              return null;
            }),
          ),
        },
        child: FocusScope(
          autofocus: autoFocus,
          skipTraversal: true,
          child: child,
        ),
      ),
    );
  }
}
