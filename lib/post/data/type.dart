import 'package:e1547/app/app.dart';
import 'package:e1547/post/data/post.dart';

enum PostType {
  image,
  video,
  unsupported,
}

extension PostTyping on Post {
  PostType get type {
    switch (ext) {
      case 'mp4':
      case 'webm':
        if (PlatformCapabilities.hasVideos) {
          return PostType.video;
        }
        return PostType.unsupported;
      case 'swf':
        return PostType.unsupported;
      default:
        return PostType.image;
    }
  }
}
