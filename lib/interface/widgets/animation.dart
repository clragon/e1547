import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

const Duration defaultAnimationDuration = Duration(milliseconds: 200);

enum FadeAnimationStyle {
  adjacent,
  stacked,
}

class CrossFade extends StatelessWidget {
  final WidgetBuilder builder;

  final Widget? secondChild;
  final Duration? duration;

  final bool showChild;

  final FadeAnimationStyle style;

  const CrossFade.builder({
    required this.showChild,
    required this.builder,
    this.secondChild,
    this.duration,
    this.style = FadeAnimationStyle.adjacent,
  });

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

  @override
  Widget build(BuildContext context) {
    Duration duration = this.duration ?? defaultAnimationDuration;
    switch (style) {
      case FadeAnimationStyle.stacked:
        return AnimatedCrossFade(
          firstChild: builder(context),
          secondChild: secondChild ?? const SizedBox.shrink(),
          crossFadeState:
              showChild ? CrossFadeState.showFirst : CrossFadeState.showSecond,
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

class Replacer extends StatelessWidget {
  final Widget child;

  final Widget secondChild;
  final Duration? duration;

  final bool showChild;

  const Replacer({
    required this.showChild,
    required this.child,
    required this.secondChild,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: child,
      secondChild: secondChild,
      crossFadeState:
          showChild ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: duration ?? defaultAnimationDuration,
      layoutBuilder: (topChild, topChildKey, bottomChild, bottomChildKey) =>
          Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            key: bottomChildKey,
            child: ExcludeFocus(
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0,
                  child: bottomChild,
                ),
              ),
            ),
          ),
          Positioned(
            key: topChildKey,
            child: topChild,
          ),
        ],
      ),
    );
  }
}

class AnimatedSelector extends StatefulWidget {
  final Listenable animation;
  final List<dynamic> Function() selector;
  final TransitionBuilder builder;
  final Widget? child;

  const AnimatedSelector(
      {required this.animation,
      required this.selector,
      required this.builder,
      this.child});

  @override
  State<AnimatedSelector> createState() => _AnimatedSelectorState();
}

class _AnimatedSelectorState extends State<AnimatedSelector> {
  List<dynamic>? values;
  Widget? cache;
  Widget? oldWidget;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        List<dynamic> selected = widget.selector();
        bool shouldRebuild = [
          oldWidget != widget,
          !const DeepCollectionEquality().equals(values, selected),
        ].any((element) => element);
        if (shouldRebuild) {
          values = selected;
          oldWidget = widget;
          cache = widget.builder(
            context,
            child,
          );
        }
        return cache!;
      },
      child: widget.child,
    );
  }
}
