import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ImageGrid extends StatelessWidget {
  const ImageGrid({super.key, this.images});

  final List<String>? images;

  BorderRadius getGridBorderRadius({
    required int index,
    required int length,
    required int crossAxisCount,
  }) {
    const radius = Radius.circular(4);
    const none = Radius.zero;

    final column = index % crossAxisCount;
    final row = index ~/ crossAxisCount;
    final lastRow = (length - 1) ~/ crossAxisCount;
    final lastColumn = (length - 1) % crossAxisCount;

    final isFirstRow = row == 0;
    final isLastRow = row == lastRow;

    final isTopLeft = isFirstRow && column == 0;
    final isTopRight =
        isFirstRow && (column == crossAxisCount - 1 || index == length - 1);
    final isBottomLeft = isLastRow && column == 0;
    final isBottomRight = isLastRow && column == lastColumn;

    return BorderRadius.only(
      topLeft: isTopLeft
          ? radius
          : column != 0 && !isFirstRow
          ? radius
          : none,
      topRight: isTopRight
          ? radius
          : column != crossAxisCount - 1 && !isFirstRow
          ? radius
          : none,
      bottomLeft: isBottomLeft
          ? radius
          : column != 0 && !isLastRow
          ? radius
          : none,
      bottomRight: isBottomRight
          ? radius
          : column != crossAxisCount - 1 && !isLastRow
          ? radius
          : none,
    );
  }

  @override
  Widget build(BuildContext context) {
    final urls = images?.take(4).toList() ?? [];
    final rowCount = urls.length > 2 ? 2 : 1;
    final perRow = (urls.length / rowCount).ceil();

    return Column(
      children: [
        for (int row = 0; row < rowCount; row++) ...[
          Expanded(
            child: Row(
              children: [
                for (int col = 0; col < perRow; col++)
                  if (row * perRow + col < urls.length) ...[
                    Expanded(
                      child: ClipRRect(
                        borderRadius: getGridBorderRadius(
                          index: row * perRow + col,
                          length: urls.length,
                          crossAxisCount: perRow,
                        ),
                        child: CachedNetworkImage(
                          imageUrl: urls[row * perRow + col],
                          errorWidget: defaultErrorBuilder,
                          fit: BoxFit.cover,
                          cacheManager: context.read<BaseCacheManager>(),
                        ),
                      ),
                    ),
                    if (col < perRow - 1) const SizedBox(width: 6),
                  ] else
                    const Spacer(),
              ],
            ),
          ),
          if (row < rowCount - 1) const SizedBox(height: 6),
        ],
      ],
    );
  }
}

class ImageTile extends StatelessWidget {
  const ImageTile({
    super.key,
    required this.images,
    required this.title,
    this.subtitle,
    this.description,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? description;
  final List<String>? images;

  @override
  Widget build(BuildContext context) {
    final bool hasImages = images?.isNotEmpty ?? false;
    return SizedBox(
      height: hasImages ? 300 : 150,
      child: hasImages
          ? ImageGrid(images: images)
          : Padding(
              padding: const EdgeInsets.all(4),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: DefaultTextStyle(
                      style: Theme.of(context).textTheme.titleLarge!,
                      textAlign: TextAlign.center,
                      child: title,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
