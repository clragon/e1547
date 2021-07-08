import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/post.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

enum ImageSize {
  preview,
  sample,
  file,
}

Future<void> preloadImage(
    {@required BuildContext context,
    @required Post post,
    @required ImageSize size}) async {
  String url;
  switch (size) {
    case ImageSize.preview:
      url = post.preview.value.url;
      break;
    case ImageSize.sample:
      url = post.sample.value.url;
      break;
    case ImageSize.file:
      url = post.file.value.url;
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
  @required BuildContext context,
  @required int index,
  @required List<Post> posts,
  @required ImageSize size,
  int reach = 2,
}) async {
  for (int i = -(reach + 1); i < reach; i++) {
    int target = index + 1 + i;
    if (0 < target && target < posts.length) {
      await preloadImage(context: context, post: posts[target], size: size);
    }
  }
}

class PostImage {
  PostImage({
    @required this.width,
    @required this.height,
    @required this.url,
  });

  int width;
  int height;
  String url;

  factory PostImage.fromMap(Map<String, dynamic> json) => PostImage(
        width: json["width"],
        height: json["height"],
        url: json["url"] == null ? null : json["url"],
      );

  Map<String, dynamic> toMap() => {
        "width": width,
        "height": height,
        "url": url == null ? null : url,
      };
}

class PostImageFile extends PostImage {
  PostImageFile({
    @required this.width,
    @required this.height,
    @required this.ext,
    @required this.size,
    @required this.md5,
    @required this.url,
  });

  int width;
  int height;
  String ext;
  int size;
  String md5;
  String url;

  factory PostImageFile.fromMap(Map<String, dynamic> json) => PostImageFile(
        width: json["width"],
        height: json["height"],
        ext: json["ext"],
        size: json["size"],
        md5: json["md5"],
        url: json["url"] == null ? null : json["url"],
      );

  Map<String, dynamic> toMap() => {
        "width": width,
        "height": height,
        "ext": ext,
        "size": size,
        "md5": md5,
        "url": url == null ? null : url,
      };
}
