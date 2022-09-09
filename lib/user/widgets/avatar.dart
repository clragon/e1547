import 'package:async_builder/async_builder.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> initializeUserAvatar(BuildContext context) async {
  Post? avatar = await context.read<Client>().currentUserAvatar();
  if (avatar?.sample.url != null) {
    await precacheImage(
      CachedNetworkImageProvider(avatar!.sample.url!),
      context,
    );
  }
}

class CurrentUserAvatar extends StatelessWidget {
  final bool enabled;

  const CurrentUserAvatar({this.enabled = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<Future<PostsController?>>(
      builder: (context, controller, child) => AsyncBuilder<PostsController?>(
        future: controller,
        builder: (context, value) => UserAvatar(
          controller: value,
          enabled: enabled,
        ),
      ),
    );
  }
}

class CurrentUserAvatarProvider
    extends SubProvider2<Client, DenylistService, Future<PostsController?>> {
  CurrentUserAvatarProvider({super.child, super.builder})
      : super(
          create: (context, client, denylist) async {
            int? id = (await context.read<Client>().currentUserAvatar())?.id;
            if (id != null) {
              PostsController controller = PostsController.single(
                client: client,
                denylist: denylist,
                id: id,
                denyMode: DenyListMode.unavailable,
              );
              await controller.loadFirstPage();
              initializeUserAvatar(context);
              return controller;
            }
            return null;
          },
          dispose: (context, value) async => (await value)?.dispose(),
          selector: (context) => [context.read<Client>().credentials],
        );
}

class UserAvatar extends StatelessWidget {
  final PostsController? controller;
  final bool enabled;

  const UserAvatar({super.key, required this.controller, this.enabled = false});

  @override
  Widget build(BuildContext context) {
    return _UserAvatarProvider(
      controller: controller,
      child: Consumer<Future<PostController?>>(
        builder: (context, controller, child) => AsyncBuilder<PostController?>(
          future: controller,
          builder: (context, value) => Avatar(
            value,
            enabled: enabled,
          ),
        ),
      ),
    );
  }
}

class _UserAvatarProvider
    extends SubProvider2<Client, DenylistService, Future<PostController?>> {
  _UserAvatarProvider({
    required PostsController? controller,
    super.child,
    super.builder, // ignore: unused_element
  }) : super(
          create: (context, client, denylist) async {
            if (controller != null) {
              await controller.loadFirstPage();
              return PostController(
                client: client,
                denylist: denylist,
                parent: controller,
                id: controller.itemList!.first.id,
              );
            } else {
              return null;
            }
          },
          selector: (context) => [controller],
          dispose: (context, value) async => (await value)?.dispose(),
        );
}

class PostAvatar extends StatelessWidget {
  final int? id;

  const PostAvatar({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    if (id == null) {
      return const UserAvatar(controller: null);
    } else {
      return PostsProvider.single(
        id: id!,
        child: Consumer<PostsController>(
          builder: (context, controller, child) =>
              UserAvatar(controller: controller),
        ),
      );
    }
  }
}

class PostIdAvatar extends StatelessWidget {
  final int id;
  final PostsController controller;

  const PostIdAvatar({required this.id, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: PostProvider(
        id: id,
        child: Consumer<PostController>(
          builder: (context, controller, child) => Avatar(controller),
        ),
      ),
    );
  }
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
                    builder: (context) => PostDetail(controller: post!),
                  ),
                )
            : null,
        child: PostTileOverlay(
          controller: post!,
          child: Hero(
            tag: post!.value.link,
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
