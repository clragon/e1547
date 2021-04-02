import 'package:flutter/material.dart';

final Duration defaultAnimationDuration = Duration(milliseconds: 200);

class SafeBuilder extends StatelessWidget {
  final bool showChild;
  final Widget Function(BuildContext context) child;

  const SafeBuilder({@required this.showChild, @required this.child});

  @override
  Widget build(BuildContext context) {
    if (showChild) {
      return child(context);
    } else {
      return Container();
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
        secondChild: secondChild ?? Container(),
        crossFadeState:
            showChild ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        duration: duration ?? defaultAnimationDuration);
  }
}

class SafeCrossFade extends StatelessWidget {
  final Widget Function(BuildContext context) child;

  final Widget secondChild;
  final Duration duration;

  final bool showChild;

  const SafeCrossFade({
    @required this.showChild,
    @required this.child,
    this.secondChild,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return CrossFade(
      showChild: showChild,
      child: SafeBuilder(
        child: child,
        showChild: showChild,
      ),
      secondChild: secondChild,
      duration: duration,
    );
  }
}

class OpacitySwitcher extends StatelessWidget {
  final Widget child;

  final Widget secondChild;
  final Duration duration;

  final bool showChild;

  const OpacitySwitcher({
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
