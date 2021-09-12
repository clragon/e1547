import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';

mixin FollowerMixin<T extends StatefulWidget> on State<T> {
  late bool safe;
  late List<Follow> follows;

  void updateFollows() {
    setState(() {
      follows = settings.follows.value;
    });
  }

  void updateSafety() {
    setState(() {
      safe = client.isSafe;
    });
  }

  void initFollows() {
    updateFollows();
    updateSafety();
  }

  void afterFollowInit() {}

  @override
  void initState() {
    super.initState();
    settings.host.addListener(updateSafety);
    settings.follows.addListener(updateFollows);
    initFollows();
    afterFollowInit();
  }

  @override
  void dispose() {
    super.dispose();
    settings.host.removeListener(updateSafety);
    settings.follows.removeListener(updateFollows);
  }
}
