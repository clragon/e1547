import 'package:e1547/follow/follow.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';

class FollowsPage extends StatefulWidget {
  @override
  _FollowsPageState createState() => _FollowsPageState();
}

class _FollowsPageState extends State<FollowsPage> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: settings.followsSplit,
      builder: (context, value, child) =>
          value ? FollowsSplitPage() : FollowsCombinedPage(),
    );
  }
}
