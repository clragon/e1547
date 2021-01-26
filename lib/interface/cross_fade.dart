import 'package:flutter/material.dart';

class CrossFade extends StatelessWidget {
  final bool showChild;
  final Widget child;
  final Widget secondChild;
  final Duration duration;

  const CrossFade({
    @required this.showChild,
    @required this.child,
    this.secondChild,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: duration ?? Duration(milliseconds: 400),
      crossFadeState:
          showChild ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      firstChild: child,
      secondChild: secondChild ?? Container(),
    );
  }
}
