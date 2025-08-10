import 'dart:math';

import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

enum GridQuilt { square, vertical }

class TileLayoutData extends InheritedWidget {
  const TileLayoutData({
    super.key,
    required super.child,
    required this.tileHeightFactor,
    required this.tileSize,
    required this.mainAxisCount,
    required this.crossAxisCount,
    required this.stagger,
  });

  final double tileHeightFactor;
  final int tileSize;
  final int mainAxisCount;
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
    super.key,
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
            int crossAxisCount = max(
              1,
              constraints.maxWidth / tileSize,
            ).round();
            int mainAxisCount = max(
              1,
              constraints.maxHeight / tileSize,
            ).round();
            return TileLayoutData(
              tileHeightFactor: tileHeightFactor,
              tileSize: tileSize,
              mainAxisCount: mainAxisCount,
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
