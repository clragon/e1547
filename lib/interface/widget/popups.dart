import 'package:flutter/material.dart';

class PopupMenuTile<T> extends PopupMenuItem<T> {
  PopupMenuTile({
    super.key,
    required T value,
    required this.icon,
    required this.title,
  }) : super(
         child: ListMenuTile(leading: Icon(icon), title: Text(title)),
         value: value,
       );

  final IconData icon;
  final String title;
}

class ListMenuTile extends StatelessWidget {
  const ListMenuTile({super.key, this.leading, this.title});

  final Widget? leading;
  final Widget? title;

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
