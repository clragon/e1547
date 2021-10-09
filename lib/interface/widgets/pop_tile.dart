import 'package:flutter/material.dart';

class PopupMenuTile<T> extends PopupMenuItem<T> {
  final IconData icon;
  final String title;

  PopupMenuTile({
    required T value,
    required this.icon,
    required this.title,
  }) : super(
          child: MenuTile(icon: icon, title: title),
          value: value,
        );
}

class MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;

  const MenuTile({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(title),
        ),
      ],
    );
  }
}
