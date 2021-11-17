import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

const defaultTileHeightFactor = 1.2;

typedef TileLayoutTileBuilder = StaggeredTile? Function(int) Function(
  double tileHeightFactor,
  int crossAxisCount,
  GridQuilt stagger,
);

typedef TileLayoutBuilder = Widget Function(
  BuildContext context,
  int crossAxisCount,
  StaggeredTile? Function(int) tileBuilder,
);

class TileLayoutScope extends StatelessWidget {
  final TileLayoutTileBuilder tileBuilder;
  final TileLayoutBuilder builder;
  final double tileHeightFactor;
  final int? tileSize;
  final GridQuilt? stagger;

  const TileLayoutScope({
    required this.tileBuilder,
    required this.builder,
    this.tileHeightFactor = defaultTileHeightFactor,
    this.tileSize,
    this.stagger,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: settings.tileSize,
      builder: (context, tileSize, child) {
        tileSize = this.tileSize ?? tileSize;
        return ValueListenableBuilder<GridQuilt>(
          valueListenable: settings.quilt,
          builder: (context, stagger, child) {
            stagger = this.stagger ?? stagger;
            return LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = notZero(constraints.maxWidth / tileSize);
                return builder(
                  context,
                  crossAxisCount,
                  tileBuilder(
                    tileHeightFactor,
                    crossAxisCount,
                    stagger,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

StaggeredTile? Function(int) Function(
  double tileHeightFactor,
  int crossAxisCount,
  GridQuilt stagger,
) defaultStaggerTileBuilder(Size? Function(int index) tileSize) {
  return (
    double tileHeightFactor,
    int crossAxisCount,
    GridQuilt stagger,
  ) {
    return (int index) {
      Size? size = tileSize(index);
      if (size == null) {
        return null;
      }
      double widthRatio = size.width / size.height;
      double heightRatio = size.height / size.width;
      switch (stagger) {
        case GridQuilt.square:
          return StaggeredTile.count(1, 1 * tileHeightFactor);
        case GridQuilt.vertical:
          return StaggeredTile.count(1, heightRatio);
        case GridQuilt.omni:
          if (crossAxisCount == 1) {
            return StaggeredTile.count(1, heightRatio);
          } else {
            return StaggeredTile.count(
                notZero(widthRatio), notZero(heightRatio) * tileHeightFactor);
          }
      }
    };
  };
}
