import 'package:flutter/material.dart';

const Duration defaultAnimationDuration = Duration(milliseconds: 200);

enum FadeAnimationStyle { adjacent, stacked }

class CrossFade extends StatelessWidget {
  factory CrossFade({
    required bool showChild,
    required Widget child,
    Widget? secondChild,
    Duration? duration,
    FadeAnimationStyle style = FadeAnimationStyle.adjacent,
  }) {
    return CrossFade.builder(
      showChild: showChild,
      builder: (context) => child,
      secondChild: secondChild,
      duration: duration,
      style: style,
    );
  }

  const CrossFade.builder({
    super.key,
    required this.showChild,
    required this.builder,
    this.secondChild,
    this.duration,
    this.style = FadeAnimationStyle.adjacent,
  });

  /// Builds the primary child of this widget.
  final WidgetBuilder builder;

  /// The secondary child of this Widget. Defaults to an empty SizedBox.
  final Widget? secondChild;

  /// The duration for switching between.
  final Duration? duration;

  /// Wether to show the child or its replacement.
  final bool showChild;

  /// The style of this animation.
  ///
  /// If adjacent, an AnimatedSwitcher with AnimatedSize will be used.
  /// If stacked, an AnimatedCrossFade will be used.
  final FadeAnimationStyle style;

  @override
  Widget build(BuildContext context) {
    Duration duration = this.duration ?? defaultAnimationDuration;
    switch (style) {
      case FadeAnimationStyle.stacked:
        return AnimatedCrossFade(
          firstChild: builder(context),
          secondChild: secondChild ?? const SizedBox.shrink(),
          crossFadeState: showChild
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: duration,
        );
      case FadeAnimationStyle.adjacent:
        return AnimatedSize(
          duration: duration,
          child: AnimatedSwitcher(
            duration: duration,
            child: showChild
                ? builder(context)
                : secondChild ?? const SizedBox.shrink(),
          ),
        );
    }
  }
}

class HiddenWidget extends StatelessWidget {
  const HiddenWidget({
    super.key,
    required this.child,
    required this.show,
    this.duration = defaultAnimationDuration,
    this.axis = Axis.horizontal,
  });

  final Duration duration;
  final Axis axis;
  final Widget child;
  final bool show;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: duration,
      child: Flex(
        direction: switch (axis) {
          Axis.horizontal => Axis.vertical,
          Axis.vertical => Axis.horizontal,
        },
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [if (show) child else const SizedBox()],
      ),
    );
  }
}
