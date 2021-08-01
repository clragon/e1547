import 'package:e1547/client.dart';
import 'package:e1547/follow.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';

mixin FollowerMixin<T extends StatefulWidget> on State<T> {
  bool? safe;
  List<Follow>? follows;

  void update() {
    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> updateFollows() async {
    settings.follows.value.then((value) async {
      follows = value;
      update();
    });
  }

  Future<void> updateSafety() async {
    safe = await client.isSafe;
    update();
  }

  Future<void> initFollows() async {
    updateFollows();
    updateSafety();
  }

  Future<void> afterFollowInit() async {}

  @override
  void initState() {
    super.initState();
    settings.host.addListener(updateSafety);
    settings.follows.addListener(updateFollows);
    initFollows().then((_) => afterFollowInit());
  }

  @override
  void reassemble() {
    super.reassemble();
    settings.host.removeListener(updateSafety);
    settings.follows.removeListener(updateFollows);
    settings.host.addListener(updateSafety);
    settings.follows.addListener(updateFollows);
  }

  @override
  void dispose() {
    super.dispose();
    settings.host.removeListener(updateSafety);
    settings.follows.removeListener(updateFollows);
  }
}
