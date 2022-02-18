import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ClipRRect(
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(5),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: thumbnail != null
                      ? Opacity(
                          opacity: 0.8,
                          child: Hero(
                            tag: getPostHero(postId!),
                            child: CachedNetworkImage(
                              imageUrl: thumbnail!,
                              errorWidget: defaultErrorBuilder,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(Icons.image_not_supported_outlined),
                        ),
                ),
                Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: onTap ??
                        (postId != null
                            ? () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PostLoadingPage(postId!),
                                  ),
                                )
                            : null),
                    onLongPress: onLongPress,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: 200,
                      ),
                      child: child,
                    ),
                  ),
                )
              ],
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}
