import 'package:flutter/material.dart';

class ListTileHeader extends StatelessWidget {
  const ListTileHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 72, bottom: 8, top: 8, right: 16),
          child: Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
