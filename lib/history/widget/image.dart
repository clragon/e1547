import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class HistoryImageGrid extends StatelessWidget {
  const HistoryImageGrid({super.key, this.images});

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
