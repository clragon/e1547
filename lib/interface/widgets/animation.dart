import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

final Duration defaultAnimationDuration = Duration(milliseconds: 200);

enum FadeAnimationStyle {
  adjacent,
  stacked,
}

class FadeBuilder extends StatelessWidget {
  final WidgetBuilder builder;
  final Duration? duration;

  const FadeBuilder({
    required this.builder,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    Duration duration = this.duration ?? defaultAnimationDuration;
    return AnimatedSize(
      duration: duration,
      child: AnimatedSwitcher(
        duration: duration,
        child: builder(context),
      ),
    );
  }
}

class CrossFade extends StatelessWidget {
  final Widget child;

  final Widget? secondChild;
  final Duration? duration;

  final bool showChild;

  final FadeAnimationStyle style;

  const CrossFade({
    required this.showChild,
    required this.child,
    this.secondChild,
    this.duration,
    this.style = FadeAnimationStyle.adjacent,
  });

  @override
  Widget build(BuildContext context) {
    Duration duration = this.duration ?? defaultAnimationDuration;
    switch (style) {
      case FadeAnimationStyle.stacked:
        return AnimatedCrossFade(
          firstChild: child,
          secondChild: secondChild ?? SizedBox.shrink(),
          crossFadeState:
              showChild ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          duration: duration,
        );
      case FadeAnimationStyle.adjacent:
        return FadeBuilder(
          builder: (context) =>
              showChild ? child : secondChild ?? SizedBox.shrink(),
        );
    }
  }
}

class SafeCrossFade extends StatelessWidget {
  final WidgetBuilder builder;

  final Widget? secondChild;
  final Duration? duration;

  final bool showChild;

  final FadeAnimationStyle style;

  const SafeCrossFade({
    required this.showChild,
    required this.builder,
    this.secondChild,
    this.duration,
    this.style = FadeAnimationStyle.adjacent,
  });

  @override
  Widget build(BuildContext context) {
    return CrossFade(
      showChild: showChild,
      child: showChild ? builder(context) : SizedBox.shrink(),
      secondChild: secondChild,
      style: style,
    );
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
        children: <Widget>[
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
  _AnimatedSelectorState createState() => _AnimatedSelectorState();
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
          !DeepCollectionEquality().equals(values, selected),
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
