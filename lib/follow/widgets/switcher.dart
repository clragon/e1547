import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';

class FollowsPage extends StatefulWidget {
  @override
  State<FollowsPage> createState() => _FollowsPageState();
}

class _FollowsPageState extends State<FollowsPage> with DrawerEntry {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: settings.splitFollows,
      builder: (context, value, child) =>
          value ? FollowsSplitPage() : FollowsCombinedPage(),
    );
  }
}
