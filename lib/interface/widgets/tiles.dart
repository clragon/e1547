import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

const defaultTileHeightFactor = 1.2;

class TileLayoutScope extends StatelessWidget {
  final StaggeredTile? Function(int) Function(
    double tileHeightFactor,
    int crossAxisCount,
    GridQuilt stagger,
  ) tileBuilder;
  final Widget Function(
    BuildContext context,
    int crossAxisCount,
    StaggeredTile? Function(int) tileBuilder,
  ) builder;
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
