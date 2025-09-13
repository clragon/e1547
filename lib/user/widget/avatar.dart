import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/domain/domain.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/data/cache.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/traits/data/client.dart';
import 'package:e1547/user/user.dart';
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
  const UserAvatar({
    super.key,
    required this.id,
    this.radius,
    this.onTap,
    this.vendored = false,
  });

  final String? id;
  final double? radius;
  final VoidCallback? onTap;
  final bool vendored;

  @override
  Widget build(BuildContext context) => switch (id) {
    final id? => QueryBuilder(
      query: context.watch<Domain>().users.useGet(id: id, vendored: vendored),
      builder: (context, state) => PostAvatar(
        id: state.data?.avatarId,
        onTap: state.data != null
            ? onTap ??
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => UserPage(user: state.data!),
                    ),
                  )
            : null,
        vendored: vendored,
      ),
    ),
    _ => const EmptyAvatar(),
  };
}

class PostAvatar extends StatelessWidget {
  const PostAvatar({
    super.key,
    required this.id,
    this.radius,
    this.onTap,
    this.vendored = false,
  });

  final int? id;
  final double? radius;
  final VoidCallback? onTap;
  final bool vendored;

  @override
  Widget build(BuildContext context) => switch (id) {
    final id? => QueryBuilder(
      query: context.watch<Domain>().posts.useGet(id: id, vendored: vendored),
      builder: (context, state) => Avatar(
        state.data?.sample,
        radius: radius,
        onTap: state.data != null
            ? onTap ??
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PostDetail(post: state.data!),
                    ),
                  )
            : null,
      ),
    ),
    _ => const EmptyAvatar(),
  };
}

class Avatar extends StatelessWidget {
  const Avatar(this.url, {super.key, this.onTap, double? radius})
    : radius = radius ?? 20;

  final String? url;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => switch (url) {
    final url? => MouseCursorRegion(
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
    ),
    _ => EmptyAvatar(radius: radius),
  };
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
