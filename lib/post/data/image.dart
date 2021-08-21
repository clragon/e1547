import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

enum ImageSize {
  preview,
  sample,
  file,
}

Widget imageFlightShuttleBuilder(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  final Hero hero = flightDirection == HeroFlightDirection.push
      ? fromHeroContext.widget as Hero
      : toHeroContext.widget as Hero;
  return hero.child;
}

Future<void> preloadImage(
    {required BuildContext context,
    required Post post,
    required ImageSize size}) async {
  String? url;
  switch (size) {
    case ImageSize.preview:
      url = post.preview.url;
      break;
    case ImageSize.sample:
      url = post.sample.url;
      break;
    case ImageSize.file:
      url = post.file.url;
      break;
  }
  if (url != null) {
    await precacheImage(
      CachedNetworkImageProvider(url),
      context,
    );
  }
}

Future<void> preloadImages({
  required BuildContext context,
  required int index,
  required List<Post> posts,
  required ImageSize size,
  int reach = 2,
}) async {
  for (int i = -(reach + 1); i < reach; i++) {
    int target = index + 1 + i;
    if (0 < target && target < posts.length) {
      await preloadImage(context: context, post: posts[target], size: size);
    }
  }
}
