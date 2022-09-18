import 'package:flutter/material.dart';

class DividerListTile extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
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
              child: SizedBox(
                width: 80,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Container(
                        color: Theme.of(context).dividerColor,
                        width: 2,
                      ),
                    ),
                    separated!,
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
