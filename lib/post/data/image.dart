import 'package:meta/meta.dart';

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
