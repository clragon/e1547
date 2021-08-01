import 'package:e1547/post.dart';
import 'package:flutter/material.dart';

import 'counter.dart';

class SearchDrawer extends StatelessWidget {
  final PostController controller;

  SearchDrawer({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text('Search'),
        ),
        body: ListView(
          padding: EdgeInsets.only(top: 8),
          physics: BouncingScrollPhysics(),
          children: [
            DrawerCounter(controller: controller),
            Builder(
              builder: (context) => DrawerDenySwitch(controller: controller),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchTag {
  final String category;
  final String tag;
  final int count;

  SearchTag({
    required this.category,
    required this.tag,
    required this.count,
  });
}
