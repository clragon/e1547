import 'package:e1547/post.dart';
import 'package:e1547/post/pages/drawer.dart';
import 'package:flutter/material.dart';

class SearchDrawer extends StatelessWidget {
  final PostProvider provider;

  SearchDrawer({@required this.provider});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Search'),
          leading: BackButton(),
        ),
        body: ListView(
          padding: EdgeInsets.only(top: 8),
          physics: BouncingScrollPhysics(),
          children: [
            DrawerCounter(provider: provider),
            Builder(
              builder: (context) => DrawerDenySwitch(provider: provider),
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
    @required this.category,
    @required this.tag,
    @required this.count,
  });
}
