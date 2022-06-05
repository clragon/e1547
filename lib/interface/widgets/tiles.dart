import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';

enum GridQuilt {
  square,
  vertical,
  omni,
}

class TileLayoutData extends InheritedWidget {
  final double tileHeightFactor;
  final int crossAxisCount;
  final GridQuilt stagger;

  const TileLayoutData({
    required super.child,
    required this.tileHeightFactor,
    required this.crossAxisCount,
    required this.stagger,
  });

  @override
  bool updateShouldNotify(covariant TileLayoutData oldWidget) =>
      (oldWidget.tileHeightFactor != tileHeightFactor ||
          oldWidget.crossAxisCount != crossAxisCount ||
          oldWidget.stagger != stagger);
}

class TileLayout extends StatelessWidget {
  final Widget child;
  final double tileHeightFactor;
  final int? tileSize;
  final GridQuilt? stagger;

  const TileLayout({
    required this.child,
    this.tileHeightFactor = 1.2,
    this.tileSize,
    this.stagger,
  });

  static TileLayoutData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TileLayoutData>()!;

  static TileLayoutData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TileLayoutData>();

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
