import 'package:flutter/material.dart';

class ContextDrawer extends StatelessWidget {
  final Widget title;
  final List<Widget> children;

  ContextDrawer({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListTileTheme(
        style: ListTileStyle.list,
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: title,
          ),
          body: ListView(
            padding: EdgeInsets.only(top: 8),
            physics: BouncingScrollPhysics(),
            children: children,
          ),
        ),
      ),
    );
  }
}

AppBar defaultAppBar({required String title}) => AppBar(
      title: Text(title),
      actions: [SizedBox.shrink()],
    );

AppBar Function(BuildContext context) defaultAppBarBuilder(String title) =>
    (context) => defaultAppBar(title: title);
