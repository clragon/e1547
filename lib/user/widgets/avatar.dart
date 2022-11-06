import 'package:async_builder/async_builder.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';

class CurrentUserAvatar extends StatelessWidget {
  const CurrentUserAvatar();

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentUserAvatarValue>(
      builder: (context, value, child) => AsyncBuilder<PostsController?>(
        future: value.controller,
        builder: (context, value) => UserAvatar(
          id: value?.itemList!.first.id,
          controller: value,
        ),
      ),
    );
  }
}

class CurrentUserAvatarValue {
  CurrentUserAvatarValue({
    required this.client,
    required this.denylist,
  });

  final Client client;
  final DenylistService denylist;
  late final Future<PostsController?> _controller = _createController();

  Future<PostsController?> get controller => _controller;

  Future<PostsController?> _createController() async {
    int? id = (await client.currentUser())?.avatarId;
    if (id != null) {
      PostsController controller = PostsController.single(
        client: client,
        denylist: denylist,
        id: id,
        denyMode: DenyListMode.unavailable,
      );
      return controller.loadFirstPage();
    }
    return null;
  }
}

class CurrentUserAvatarProvider
    extends SubProvider2<Client, DenylistService, CurrentUserAvatarValue> {
  CurrentUserAvatarProvider({super.child, super.builder})
      : super(
          create: (context, client, denylist) => CurrentUserAvatarValue(
            client: client,
            denylist: denylist,
          ),
          dispose: (context, value) async =>
              (await value.controller)?.dispose(),
          selector: (context) => [context.watch<Client>().credentials],
        );
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.controller, required this.id});

  final PostsController? controller;
  final int? id;

  @override
  Widget build(BuildContext context) {
    int? id = this.id;
    PostsController? controller = this.controller;
    if (id == null || controller == null) {
      return const EmptyAvatar();
    }
    return SubValueBuilder<Future<PostsController>>(
      create: (context) => controller.loadFirstPage(),
      selector: (context) => [controller],
      builder: (context, _) => PostsControllerConnector(
        id: id,
        controller: controller,
        builder: (context, post) => Avatar(
          post,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PostsControllerConnector(
                  id: id,
                  controller: controller,
                  builder: (context, post) => PostsRouteConnector(
                    controller: controller,
                    child: PostDetail(post: post!),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PostAvatar extends StatelessWidget {
  const PostAvatar({super.key, required this.id});

  final int? id;

  @override
  Widget build(BuildContext context) {
    if (id == null) {
      return const EmptyAvatar();
    } else {
      return PostsProvider.single(
        id: id!,
        child: Consumer<PostsController>(
          builder: (context, controller, child) =>
              UserAvatar(id: id, controller: controller),
        ),
      );
    }
  }
}

class Avatar extends StatelessWidget {
  const Avatar(this.post, {this.onTap});

  final Post? post;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (post?.sample.url != null) {
      return GestureDetector(
        onTap: onTap,
        child: PostTileOverlay(
          post: post!,
          child: Hero(
            tag: post!.link,
            child: CircleAvatar(
              foregroundImage: CachedNetworkImageProvider(post!.sample.url!),
            ),
          ),
        ),
      );
    } else {
      return const EmptyAvatar();
    }
  }
}

class EmptyAvatar extends StatelessWidget {
  const EmptyAvatar({super.key});

  @override
  Widget build(BuildContext context) => const AppIcon();
}
