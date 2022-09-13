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
        child: SafeArea(
          child: ListView(
            primary: false,
            padding: EdgeInsets.only(bottom: defaultActionListPadding.bottom),
            children: [
              if (title != null)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                  child: DefaultTextStyle(
                    style: Theme.of(context).textTheme.headline6!,
                    child: title!,
                  ),
                ),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class ContextDrawerButton extends StatelessWidget {
  final IconData? icon;
  final String? tooltip;

  const ContextDrawerButton({this.icon, this.tooltip = 'Filter'});

  @override
  Widget build(BuildContext context) {
    if (!Scaffold.of(context).hasEndDrawer) return const SizedBox();
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon ?? Icons.filter_list),
      onPressed: () => Scaffold.of(context).openEndDrawer(),
    );
  }
}
