import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class ImageTile extends StatelessWidget {
  final Widget child;
  final List<String>? thumbnails;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ImageTile({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.thumbnails,
  });

  BorderRadius getGridBorderRadius({
    required int index,
    required int length,
    required int crossAxisCount,
  }) {
    int column = (index + 1) % crossAxisCount;
    bool firstRow = index < crossAxisCount;
    bool lastRow = index >= length - crossAxisCount;

    BorderRadius radius = BorderRadius.zero;

    if (column != 0) {
      radius = radius.copyWith(
        topRight: Radius.circular(firstRow ? 0 : 4),
        bottomRight: Radius.circular(lastRow ? 0 : 4),
      );
    }
    if (column != 1) {
      radius = radius.copyWith(
        topLeft: Radius.circular(firstRow ? 0 : 4),
        bottomLeft: Radius.circular(lastRow ? 0 : 4),
      );
    }

    return radius;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      int count = thumbnails?.length.clamp(1, 4) ?? 1;
                      if (count != 1) {
                        count = (count / 2).round() * 2;
                      }
                      return GridView.builder(
                        primary: false,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: count.clamp(1, 2),
                          mainAxisExtent: count > 2
                              ? constraints.maxHeight * 0.5
                              : constraints.maxHeight,
                          mainAxisSpacing: 6,
                          crossAxisSpacing: 6,
                        ),
                        itemCount: count,
                        itemBuilder: (context, index) {
                          if (thumbnails != null &&
                              index < thumbnails!.length) {
                            return ClipRRect(
                              borderRadius: getGridBorderRadius(
                                index: index,
                                length: thumbnails!.length.clamp(0, 4),
                                crossAxisCount: 2,
                              ),
                              child: Opacity(
                                opacity: 0.8,
                                child: CachedNetworkImage(
                                  imageUrl: thumbnails![index],
                                  errorWidget: defaultErrorBuilder,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          } else {
                            return const Center(
                              child: Icon(Icons.image_not_supported_outlined),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
                Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: onTap,
                    onLongPress: onLongPress,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: 300,
                      ),
                      child: child,
                    ),
                  ),
                )
              ],
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}

class PostPresenterTile extends StatelessWidget {
  final Widget child;
  final String? thumbnail;
  final int? postId;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const PostPresenterTile({
    required this.child,
    this.thumbnail,
    this.onTap,
    this.onLongPress,
    this.postId,
  });

  @override
  Widget build(BuildContext context) {
    return ImageTile(
      thumbnails: [if (thumbnail != null) thumbnail!],
      child: child,
      onTap: onTap ??
          (postId != null
              ? () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PostLoadingPage(postId!),
                    ),
                  )
              : null),
      onLongPress: onLongPress,
    );
  }
}
