import 'package:animations/animations.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';

class FollowsSwitcherPage extends StatefulWidget {
  const FollowsSwitcherPage({super.key});

  @override
  State<FollowsSwitcherPage> createState() => _FollowsSwitcherPageState();
}

class _FollowsSwitcherPageState extends State<FollowsSwitcherPage>
    with DrawerEntry {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: context.watch<Settings>().splitFollows,
      builder: (context, value, child) => PageTransitionSwitcher(
        duration: defaultAnimationDuration,
        reverse: !value,
        transitionBuilder: (child, animation, secondaryAnimation) =>
            FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        ),
        child: value ? const FollowsFolderPage() : const FollowsTimelinePage(),
      ),
    );
  }
}
