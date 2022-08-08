import 'package:flutter/material.dart';

class PopupMenuTile<T> extends PopupMenuItem<T> {
  final IconData icon;
  final String title;

  PopupMenuTile({
    required T value,
    required this.icon,
    required this.title,
  }) : super(
          child: ListMenuTile(leading: Icon(icon), title: Text(title)),
          value: value,
        );
}

class ListMenuTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;

  const ListMenuTile({this.leading, this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (leading != null) leading!,
        if (title != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: title!,
          ),
      ],
    );
  }
}
