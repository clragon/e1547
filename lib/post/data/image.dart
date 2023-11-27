import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

enum PostImageSize {
  preview,
  sample,
  file,
}

Future<void> preloadPostImage({
  required BuildContext context,
  required Post post,
  required PostImageSize size,
}) async {
  String? url;
  switch (size) {
    case PostImageSize.preview:
      url = post.preview.url;
      break;
    case PostImageSize.sample:
      url = post.sample.url;
      break;
    case PostImageSize.file:
      url = post.file.url;
      break;
  }
  if (post.type != PostType.image) return;
  if (url != null) {
    context.read<BaseCacheManager>().downloadFile(url);
  }
}

Future<void> preloadPostImages({
  required BuildContext context,
  required int index,
  required List<Post> posts,
  required PostImageSize size,
  int reach = 2,
}) async {
  for (int i = -(reach + 1); i < reach; i++) {
    int target = index + 1 + i;
    if (0 < target && target < posts.length) {
      Post post = posts[target];
      if (post.type == PostType.image && post.file.url != null) {
        if (!context.mounted) return;
        await preloadPostImage(context: context, post: post, size: size);
      }
    }
  }
}
