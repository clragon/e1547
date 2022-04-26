import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

const double defaultTileHeightFactor = 1.2;

class TileLayoutData extends InheritedWidget {
  final double tileHeightFactor;
  final int crossAxisCount;
  final GridQuilt stagger;

  const TileLayoutData({
    required Widget child,
    required this.tileHeightFactor,
    required this.crossAxisCount,
    required this.stagger,
  }) : super(child: child);

  @override
  bool updateShouldNotify(covariant TileLayoutData oldWidget) =>
      (oldWidget.tileHeightFactor != tileHeightFactor ||
          oldWidget.crossAxisCount != crossAxisCount ||
          oldWidget.stagger != stagger);
}

class TileLayout extends StatelessWidget {
  final double tileHeightFactor;
  final int? tileSize;
  final GridQuilt? stagger;

  final Widget child;

  const TileLayout({
    required this.child,
    this.tileHeightFactor = defaultTileHeightFactor,
    this.tileSize,
    this.stagger,
  });

  static TileLayoutData of(BuildContext context) {
    final TileLayoutData? result =
        context.dependOnInheritedWidgetOfExactType<TileLayoutData>();
    assert(result != null, 'No TileLayoutData found in context');
    return result!;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: settings.tileSize,
      builder: (context, tileSize, child) => ValueListenableBuilder<GridQuilt>(
        valueListenable: settings.quilt,
        builder: (context, stagger, child) => LayoutBuilder(
          builder: (context, constraints) {
            tileSize = this.tileSize ?? tileSize;
            stagger = this.stagger ?? stagger;
            int crossAxisCount = notZero(constraints.maxWidth / tileSize);
            return TileLayoutData(
              tileHeightFactor: tileHeightFactor,
              crossAxisCount: crossAxisCount,
              stagger: stagger,
              child: this.child,
            );
          },
        ),
      ),
    );
  }
}

IndexedStaggeredTileBuilder postStaggeredTileBuilder(
    BuildContext context, Post Function(int index) postFromIndex) {
  return (int index) {
    TileLayoutData layoutData = TileLayout.of(context);
    PostFile image = postFromIndex(index).sample;

    Size size = Size(image.width.toDouble(), image.height.toDouble());
    double widthRatio = size.width / size.height;
    double heightRatio = size.height / size.width;

    switch (layoutData.stagger) {
      case GridQuilt.square:
        return StaggeredTile.count(1, 1 * layoutData.tileHeightFactor);
      case GridQuilt.vertical:
        return StaggeredTile.count(1, heightRatio);
      case GridQuilt.omni:
        if (layoutData.crossAxisCount == 1) {
          return StaggeredTile.count(1, heightRatio);
        } else {
          return StaggeredTile.count(notZero(widthRatio),
              notZero(heightRatio) * layoutData.tileHeightFactor);
        }
    }
  };
}
