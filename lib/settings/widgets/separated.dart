import 'package:flutter/material.dart';

class SeparatedListTile extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Widget? separated;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const SeparatedListTile({
    this.title,
    this.subtitle,
    this.leading,
    this.onTap,
    this.onLongPress,
    this.trailing,
    this.separated,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ListTile(
            title: title,
            subtitle: subtitle,
            leading: leading,
            trailing: trailing,
            onTap: onTap,
            onLongPress: onLongPress,
          ),
        ),
        if (separated != null)
          // couldve been intrinsic height
          // but this prevents clicking elements behind it
          Container(
            color: Colors.transparent,
            height: 64,
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Container(
                    color: Theme.of(context).dividerColor,
                    width: 2,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: separated,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
