import 'package:flutter/material.dart';

final Duration defaultAnimationDuration = Duration(milliseconds: 200);

class SafeBuilder extends StatelessWidget {
  final bool showChild;
  final Widget Function(BuildContext context) builder;

  const SafeBuilder({@required this.showChild, @required this.builder});

  @override
  Widget build(BuildContext context) {
    if (showChild) {
      return builder(context);
    } else {
      return SizedBox.shrink();
    }
  }
}

class CrossFade extends StatelessWidget {
  final Widget child;

  final Widget secondChild;
  final Duration duration;

  final bool showChild;

  const CrossFade({
    @required this.showChild,
    @required this.child,
    this.secondChild,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
        firstChild: child,
        secondChild: secondChild ?? SizedBox.shrink(),
        crossFadeState:
            showChild ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        duration: duration ?? defaultAnimationDuration);
  }
}

class SafeCrossFade extends StatelessWidget {
  final Widget Function(BuildContext context) builder;

  final Widget secondChild;
  final Duration duration;

  final bool showChild;

  const SafeCrossFade({
    @required this.showChild,
    @required this.builder,
    this.secondChild,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return CrossFade(
      showChild: showChild,
      child: SafeBuilder(
        builder: builder,
        showChild: showChild,
      ),
      secondChild: secondChild,
      duration: duration,
    );
  }
}

class Replacer extends StatelessWidget {
  final Widget child;

  final Widget secondChild;
  final Duration duration;

  final bool showChild;

  const Replacer({
    @required this.showChild,
    @required this.child,
    @required this.secondChild,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IgnorePointer(
          ignoring: !showChild,
          child: AnimatedOpacity(
            opacity: showChild ? 1 : 0,
            duration: duration ?? defaultAnimationDuration,
            child: child,
          ),
        ),
        IgnorePointer(
          ignoring: showChild,
          child: AnimatedOpacity(
            opacity: showChild ? 0 : 1,
            duration: duration ?? defaultAnimationDuration,
            child: secondChild,
          ),
        ),
      ],
    );
  }
}
