import 'package:flutter/material.dart';

class DividerListTile extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Widget? separated;
  final VoidCallback? onTap;
  final VoidCallback? onTapSeparated;
  final VoidCallback? onLongPressSeparated;
  final VoidCallback? onLongPress;
  final EdgeInsets? contentPadding;

  const DividerListTile({
    this.title,
    this.subtitle,
    this.leading,
    this.onTap,
    this.onLongPress,
    this.trailing,
    this.separated,
    this.contentPadding,
    this.onTapSeparated,
    this.onLongPressSeparated,
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
            contentPadding: contentPadding,
          ),
        ),
        if (separated != null)
          InkWell(
            onTap: onTapSeparated,
            onLongPress: onLongPressSeparated,
            child: Container(
              color: Colors.transparent,
              height: 64,
              width: 80,
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Container(
                            color: Theme.of(context).dividerColor,
                            width: 2,
                          ),
                        ),
                        separated!,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
