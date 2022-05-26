import 'package:flutter/material.dart';

class LimitedWidthLayoutData extends InheritedWidget {
  final double space;
  final double maxWidth;

  EdgeInsets get padding => EdgeInsets.symmetric(horizontal: space);

  const LimitedWidthLayoutData({
    required super.child,
    required this.maxWidth,
    required this.space,
  });

  @override
  bool updateShouldNotify(covariant LimitedWidthLayoutData oldWidget) {
    return oldWidget.space != space;
  }
}

class LimitedWidthLayout extends StatefulWidget {
  final double maxWidth;
  final double tolerance;
  final WidgetBuilder builder;

  const LimitedWidthLayout.builder({
    required this.builder,
    this.maxWidth = 600,
    this.tolerance = 100,
  });

  factory LimitedWidthLayout({
    required Widget child,
    double maxWidth = 600,
    double tolerance = 100,
  }) {
    return LimitedWidthLayout.builder(
      builder: (context) => child,
      maxWidth: maxWidth,
      tolerance: tolerance,
    );
  }

  @override
  State<LimitedWidthLayout> createState() => _LimitedWidthLayoutState();

  static LimitedWidthLayoutData? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LimitedWidthLayoutData>();
  }
}

class _LimitedWidthLayoutState extends State<LimitedWidthLayout> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double padding = (constraints.maxWidth - widget.maxWidth) / 2;
        if (padding < widget.tolerance) {
          padding = 0;
        }
        return LimitedWidthLayoutData(
          space: padding,
          maxWidth: widget.maxWidth,
          child: Builder(builder: widget.builder),
        );
      },
    );
  }
}

class LimitedWidthChild extends StatelessWidget {
  final Widget child;

  const LimitedWidthChild({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: LimitedWidthLayout.of(context)!.space,
      ),
      child: child,
    );
  }
}
