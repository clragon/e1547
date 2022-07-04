import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';

Future<void> initializeUserAvatar(BuildContext context) async {
  Post? avatar = await client.currentUserAvatar();
  if (avatar?.sample.url != null) {
    precacheImage(
      CachedNetworkImageProvider(avatar!.sample.url!),
      context,
    );
  }
}

class CurrentUserAvatar extends StatefulWidget {
  final bool enabled;

  const CurrentUserAvatar({this.enabled = false});

  @override
  State<CurrentUserAvatar> createState() => _CurrentUserAvatarState();
}

class _CurrentUserAvatarState extends State<CurrentUserAvatar> {
  final Future<PostsController?> controller = Future(() async {
    int? id = (await client.currentUserAvatar())?.id;
    if (id != null) {
      PostsController controller = PostsController.single(
        id,
        denyMode: DenyListMode.unavailable,
      );
      await controller.loadFirstItem();
      return controller;
    }
    return null;
  });

  @override
  void initState() {
    super.initState();
    initializeUserAvatar(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PostsController?>(
      future: controller,
      builder: (context, snapshot) {
        return UserAvatar(
          controller: snapshot.data,
          enabled: widget.enabled,
        );
      },
    );
  }
}

class UserAvatar extends StatefulWidget {
  final PostsController? controller;
  final bool enabled;

  const UserAvatar({super.key, required this.controller, this.enabled = false});

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  late Future<Post>? post = widget.controller?.loadFirstItem();

  @override
  void didUpdateWidget(covariant UserAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      post = widget.controller?.loadFirstItem();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (post != null) {
      return FutureBuilder<Post>(
        future: post,
        builder: (context, snapshot) {
          PostController? controller;
          if (snapshot.hasData) {
            controller = PostController(
              id: snapshot.data!.id,
              parent: widget.controller!,
            );
          }
          return Avatar(
            controller,
            enabled: widget.enabled,
          );
        },
      );
    }
    return const AppIcon();
  }
}

class PostAvatar extends StatefulWidget {
  final int? id;

  const PostAvatar({super.key, required this.id});

  @override
  State<PostAvatar> createState() => _PostAvatarState();
}

class _PostAvatarState extends State<PostAvatar> {
  late PostsController? controller =
      widget.id != null ? PostsController.single(widget.id!) : null;

  @override
  void didUpdateWidget(covariant PostAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      if (widget.id != null) {
        controller = PostsController.single(widget.id!);
      } else {
        controller = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return UserAvatar(controller: controller);
  }
}

class PostIdAvatar extends StatefulWidget {
  final int? id;
  final PostsController controller;

  const PostIdAvatar({required this.id, required this.controller});

  @override
  State<PostIdAvatar> createState() => _PostIdAvatarState();
}

class _PostIdAvatarState extends State<PostIdAvatar> {
  late PostController controller = PostController(
    id: widget.id,
    parent: widget.controller,
  );

  @override
  void didUpdateWidget(covariant PostIdAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      controller = PostController(
        id: widget.id,
        parent: widget.controller,
      );
    }
  }

  @override
  Widget build(BuildContext context) => Avatar(controller);
}

class Avatar extends StatelessWidget {
  final PostController? post;
  final bool enabled;

  const Avatar(this.post, {this.enabled = false});

  @override
  Widget build(BuildContext context) {
    if (post != null && post!.value.sample.url != null) {
      return GestureDetector(
        onTap: enabled
            ? () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PostDetail(post: post!),
                  ),
                )
            : null,
        child: PostTileOverlay(
          post: post!,
          child: Hero(
            tag: post!.value.hero,
            child: CircleAvatar(
              foregroundImage:
                  CachedNetworkImageProvider(post!.value.sample.url!),
            ),
          ),
        ),
      );
    } else {
      return const AppIcon();
    }
  }
}
