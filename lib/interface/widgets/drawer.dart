import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

class ContextDrawer extends StatelessWidget {
  final Widget? title;
  final List<Widget> children;

  const ContextDrawer({this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListTileTheme(
        style: ListTileStyle.list,
        child: Scaffold(
          appBar: title != null
              ? DefaultAppBar(
                  elevation: 0,
                  title: title,
                  automaticallyImplyLeading: false,
                )
              : null,
          body: ListView(
            children: children,
          ),
        ),
      ),
    );
  }
}

class ContextDrawerButton extends StatelessWidget {
  final IconData? icon;

  const ContextDrawerButton({this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 4),
      child: Builder(
        builder: (context) => IconButton(
          icon: Icon(icon ?? Icons.filter_list),
          onPressed: () => Scaffold.of(context).openEndDrawer(),
        ),
      ),
    );
  }
}
