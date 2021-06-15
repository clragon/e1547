import 'package:e1547/client.dart';
import 'package:e1547/follow.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';

mixin FollowerMixin<T extends StatefulWidget> on State<T> {
  bool safe;
  List<Follow> follows;

  void update() {
    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> updateFollows() async {
    db.follows.value.then((value) async {
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
    db.host.addListener(updateSafety);
    db.follows.addListener(updateFollows);
    initFollows().then((_) => afterFollowInit());
  }

  @override
  void reassemble() {
    super.reassemble();
    db.host.removeListener(updateSafety);
    db.follows.removeListener(updateFollows);
    db.host.addListener(updateSafety);
    db.follows.addListener(updateFollows);
  }

  @override
  void dispose() {
    super.dispose();
    db.host.removeListener(updateSafety);
    db.follows.removeListener(updateFollows);
  }
}
