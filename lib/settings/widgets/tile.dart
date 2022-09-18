import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class ImageGrid extends StatelessWidget {
  const ImageGrid({super.key, this.images});

  final List<String>? images;

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
    return LayoutBuilder(
      builder: (context, constraints) {
        int count = images?.length.clamp(1, 4) ?? 1;
        if (count != 1) {
          count = (count / 2).round() * 2;
        }
        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: GridView.builder(
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
              if (images != null && index < images!.length) {
                return ClipRRect(
                  borderRadius: getGridBorderRadius(
                    index: index,
                    length: images!.length.clamp(0, 4),
                    crossAxisCount: 2,
                  ),
                  child: Opacity(
                    opacity: 0.8,
                    child: CachedNetworkImage(
                      imageUrl: images![index],
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
          ),
        );
      },
    );
  }
}

class ImageTile extends StatelessWidget {
  const ImageTile({
    required this.images,
    required this.title,
    this.subtitle,
    this.description,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.hero,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? description;
  final Widget? leading;
  final Widget? trailing;
  final List<String>? images;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? hero;

  @override
  Widget build(BuildContext context) {
    final bool centerTitle = images?.isEmpty ?? true;
    return Column(
      children: [
        Material(
          type: MaterialType.transparency,
          clipBehavior: Clip.antiAlias,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            child: Column(
              children: [
                Stack(
                  fit: StackFit.passthrough,
                  children: [
                    SizedBox(
                      height: images?.isNotEmpty ?? true ? 300 : 150,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          centerTitle
                              ? Expanded(
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Center(
                                        child: DefaultTextStyle(
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6!,
                                          textAlign: TextAlign.center,
                                          child: title,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Expanded(
                                  child: hero != null
                                      ? Hero(
                                          tag: hero!,
                                          child: ImageGrid(images: images),
                                        )
                                      : ImageGrid(images: images),
                                ),
                        ],
                      ),
                    ),
                    const Positioned.fill(
                      child: Material(type: MaterialType.transparency),
                    ),
                  ],
                ),
                ListTile(
                  title: !centerTitle ? title : null,
                  subtitle: subtitle,
                  trailing: trailing,
                ),
              ],
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }
}
