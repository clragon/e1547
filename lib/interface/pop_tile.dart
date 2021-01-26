import 'package:flutter/material.dart';

class PopTile extends StatelessWidget {
  final IconData icon;
  final String title;

  const PopTile({@required this.icon, @required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 20),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(title),
        ),
      ],
    );
  }
}
