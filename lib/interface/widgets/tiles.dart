import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';

enum GridQuilt {
  square,
  vertical,
}

class TileLayoutData extends InheritedWidget {
  const TileLayoutData({
    required super.child,
    required this.tileHeightFactor,
    required this.tileSize,
    required this.crossAxisCount,
    required this.stagger,
  });

  final double tileHeightFactor;
  final int tileSize;
  final int crossAxisCount;
  final GridQuilt stagger;

  @override
  bool updateShouldNotify(covariant TileLayoutData oldWidget) =>
      (oldWidget.tileHeightFactor != tileHeightFactor ||
          oldWidget.crossAxisCount != crossAxisCount ||
          oldWidget.stagger != stagger);
}

class TileLayout extends StatelessWidget {
  const TileLayout({
    required this.child,
    this.tileHeightFactor = 1.2,
    this.tileSize,
    this.stagger,
  });

  final Widget child;
  final double tileHeightFactor;
  final int? tileSize;
  final GridQuilt? stagger;

  static TileLayoutData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TileLayoutData>()!;

  static TileLayoutData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TileLayoutData>();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: context.watch<Settings>().tileSize,
      builder: (context, tileSize, child) => ValueListenableBuilder<GridQuilt>(
        valueListenable: context.watch<Settings>().quilt,
        builder: (context, stagger, child) => LayoutBuilder(
          builder: (context, constraints) {
            tileSize = this.tileSize ?? tileSize;
            stagger = this.stagger ?? stagger;
            int crossAxisCount = notZero(constraints.maxWidth / tileSize);
            return TileLayoutData(
              tileHeightFactor: tileHeightFactor,
              tileSize: tileSize,
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
