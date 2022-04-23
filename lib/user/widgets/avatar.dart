import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';

Future<void> initializeUserAvatar(BuildContext context) async {
  Post? avatar = await client.currentAvatar;
  if (avatar?.sample.url != null) {
    precacheImage(
      CachedNetworkImageProvider(avatar!.sample.url!),
      context,
    );
  }
}

class CurrentUserAvatar extends StatelessWidget {
  const CurrentUserAvatar();

  @override
  Widget build(BuildContext context) {
    return AvatarLoader((context) async {
      initializeUserAvatar(context);
      return client.currentAvatar;
    });
  }
}

class UserAvatar extends StatelessWidget {
  final int id;

  const UserAvatar({required this.id});

  @override
  Widget build(BuildContext context) {
    return AvatarLoader((context) async {
      User user = await client.user(id.toString());

      if (user.avatarId == null) {
        return Future.value(null);
      }
      return await client.post(user.avatarId!);
    });
  }
}

class PostAvatar extends StatelessWidget {
  final int? id;

  const PostAvatar({required this.id});

  @override
  Widget build(BuildContext context) {
    return AvatarLoader(
      (context) async {
        if (id == null) {
          return Future.value(null);
        }
        return await client.post(id!);
      },
    );
  }
}

class AvatarLoader extends StatefulWidget {
  final Future<Post?> Function(BuildContext context) provider;

  const AvatarLoader(this.provider);

  @override
  State<AvatarLoader> createState() => _AvatarLoaderState();
}

class _AvatarLoaderState extends State<AvatarLoader>
    with ListenerCallbackMixin {
  late Future<Post?> avatar;

  @override
  Map<Listenable, VoidCallback> get initListeners => {
        client: () => avatar = widget.provider(context),
      };

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Post?>(
      future: avatar,
      builder: (context, snapshot) => Avatar(snapshot.data),
    );
  }
}

class Avatar extends StatelessWidget {
  final Post? post;

  const Avatar(this.post);

  @override
  Widget build(BuildContext context) {
    if (post != null && post!.sample.url != null) {
      return PostTileOverlay(
        post: post!,
        child: Hero(
          tag: post!.hero,
          child: CircleAvatar(
            foregroundImage: (CachedNetworkImageProvider(post!.sample.url!)),
          ),
        ),
      );
    } else {
      return AppIcon();
    }
  }
}
