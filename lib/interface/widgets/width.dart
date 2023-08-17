import 'package:flutter/material.dart';

class LimitedWidthLayoutData extends InheritedWidget {
  const LimitedWidthLayoutData({
    required super.child,
    required this.maxWidth,
    required this.space,
  });

  final double space;
  final double maxWidth;

  EdgeInsets get padding => EdgeInsets.symmetric(horizontal: space);

  @override
  bool updateShouldNotify(covariant LimitedWidthLayoutData oldWidget) =>
      oldWidget.space != space || oldWidget.maxWidth != maxWidth;
}

class LimitedWidthLayout extends StatelessWidget {
  factory LimitedWidthLayout({
    required Widget child,
    double maxWidth = 600,
    double tolerance = 0,
  }) {
    return LimitedWidthLayout.builder(
      builder: (context) => child,
      maxWidth: maxWidth,
      tolerance: tolerance,
    );
  }

  const LimitedWidthLayout.builder({
    required this.builder,
    this.maxWidth = 600,
    this.tolerance = 0,
  });

  final double maxWidth;
  final double tolerance;
  final WidgetBuilder builder;

  static LimitedWidthLayoutData of(BuildContext context) => maybeOf(context)!;

  static LimitedWidthLayoutData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LimitedWidthLayoutData>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double padding = (constraints.maxWidth - maxWidth) / 2;
        if (padding < tolerance) {
          padding = 0;
        }
        return LimitedWidthLayoutData(
          space: padding,
          maxWidth: maxWidth,
          child: Builder(builder: builder),
        );
      },
    );
  }
}

class LimitedWidthChild extends StatelessWidget {
  const LimitedWidthChild({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: LimitedWidthLayout.of(context).space,
      ),
      child: child,
    );
  }
}
