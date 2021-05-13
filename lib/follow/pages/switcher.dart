import 'package:e1547/follow.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';

class FollowsPage extends StatefulWidget {
  @override
  _FollowsPageState createState() => _FollowsPageState();
}

class _FollowsPageState extends State<FollowsPage> {
  bool isSplit;

  Future<void> update() async {
    await db.followsSplit.value
        .then((value) => setState(() => isSplit = value));
  }

  @override
  void initState() {
    super.initState();
    update();
    db.followsSplit.addListener(update);
  }

  @override
  void dispose() {
    super.dispose();
    db.followsSplit.removeListener(update);
  }

  @override
  Widget build(BuildContext context) {
    return PageLoader(
        child: Builder(
            builder: (BuildContext context) => isSplit == null
                ? SizedBox.shrink()
                : isSplit
                    ? FollowsSplitPage()
                    : FollowsCombinedPage()),
        isLoading: isSplit == null,
        isEmpty: false,
        isError: false);
  }
}
