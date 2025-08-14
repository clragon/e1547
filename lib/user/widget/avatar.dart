import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/traits/data/client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_sub/flutter_sub.dart';

class IdentityAvatar extends StatelessWidget {
  const IdentityAvatar(this.id, {super.key, this.radius = 20});

  final int id;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Consumer<TraitsClient>(
      builder: (context, client, child) => SubStream(
        create: () => client.getOrNull(id).stream,
        builder: (context, snapshot) =>
            Avatar(snapshot.data?.avatar, radius: radius),
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.controller, required this.id});

  final PostController? controller;
  final int? id;

  @override
  Widget build(BuildContext context) {
    int? id = this.id;
    PostController? controller = this.controller;
    if (id == null || controller == null) {
      return const EmptyAvatar();
    }
    return SubFuture<PostController>(
      create: () => Future<PostController>(() async {
        await controller.getNextPage();
        return controller;
      }),
      keys: [controller],
      builder: (context, _) => PostsControllerConnector(
        id: id,
        controller: controller,
        builder: (context, post) => Avatar(
          post?.sample,
          onTap: () => Navigator.of(context).push(
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
          ),
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
      return SinglePostProvider(
        id: id!,
        child: Consumer<PostController>(
          builder: (context, controller, child) =>
              UserAvatar(id: id, controller: controller),
        ),
      );
    }
  }
}

class Avatar extends StatelessWidget {
  const Avatar(this.url, {super.key, this.onTap, this.radius = 20});

  final String? url;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (url case final url?) {
      return MouseCursorRegion(
        onTap: onTap,
        child: Container(
          decoration: const BoxDecoration(shape: BoxShape.circle),
          clipBehavior: Clip.antiAlias,
          width: radius * 2,
          height: radius * 2,
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            cacheManager: context.read<BaseCacheManager>(),
            placeholder: (context, url) => EmptyAvatar(radius: radius),
            errorWidget: (context, url, error) =>
                const Center(child: Icon(Icons.warning_amber)),
            fadeInDuration: Duration.zero,
            fadeOutDuration: Duration.zero,
          ),
        ),
      );
    } else {
      return EmptyAvatar(radius: radius);
    }
  }
}

class EmptyAvatar extends StatelessWidget {
  const EmptyAvatar({super.key, this.radius = 20});

  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(shape: BoxShape.circle),
    clipBehavior: Clip.antiAlias,
    width: radius * 2,
    height: radius * 2,
    child: Image.asset('assets/icon/app/user.png'),
  );
}
