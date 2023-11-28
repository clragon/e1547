import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_sub/flutter_sub.dart';

class CurrentUserAvatar extends StatelessWidget {
  const CurrentUserAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentUserAvatarController>(
      builder: (context, controller, child) {
        if (controller.error != null) {
          return CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: const Icon(Icons.warning_amber),
          );
        }

        return UserAvatar(
          id: controller.items?.firstOrNull?.id,
          controller: controller,
        );
      },
    );
  }
}

class CurrentUserAvatarController extends PostsController {
  CurrentUserAvatarController({
    required super.client,
    required super.denylist,
  }) : super(filterMode: PostFilterMode.unavailable);

  @override
  Future<List<Post>> fetch(int page, bool force) async {
    if (page != firstPageKey) return [];
    int? id = (await client.currentUser())?.avatarId;
    if (id == null) return [];
    return [
      await client.post(
        id,
        force: force,
        cancelToken: cancelToken,
      ),
    ];
  }
}

class CurrentUserAvatarProvider extends SubChangeNotifierProvider2<Client,
    DenylistService, CurrentUserAvatarController> {
  CurrentUserAvatarProvider({super.child, TransitionBuilder? builder})
      : super(
          create: (context, client, denylist) => CurrentUserAvatarController(
            client: client,
            denylist: denylist,
          )..getNextPage(),
          builder: (context, child) => SubEffect(
            effect: () {
              Future(() async {
                PostsController? controller =
                    context.read<CurrentUserAvatarController>();
                await controller.waitForNextPage();
                Post? avatar = controller.items?.firstOrNull;
                if (avatar?.sample.url != null && context.mounted) {
                  await preloadPostImage(
                    context: context,
                    post: avatar!,
                    size: PostImageSize.sample,
                  );
                }
              });
              return null;
            },
            keys: [context.watch<CurrentUserAvatarController>()],
            child: builder?.call(context, child) ?? child!,
          ),
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
    return SubFuture<PostsController>(
      create: () => Future<PostsController>(() async {
        await controller.getNextPage();
        return controller;
      }),
      keys: [controller],
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
      return SinglePostProvider(
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
  const Avatar(
    this.post, {
    super.key,
    this.onTap,
    this.radius = 20,
  });

  final Post? post;
  final double radius;
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
            child: Container(
              decoration: const BoxDecoration(shape: BoxShape.circle),
              clipBehavior: Clip.antiAlias,
              width: radius * 2,
              height: radius * 2,
              child: CachedNetworkImage(
                imageUrl: post!.sample.url!,
                fit: BoxFit.cover,
                cacheManager: context.read<BaseCacheManager>(),
              ),
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
