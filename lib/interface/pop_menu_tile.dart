import 'package:flutter/material.dart';

class PopMenuTile extends StatelessWidget {
  final String title;
  final IconData icon;

  const PopMenuTile({@required this.title, @required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 20),
        Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
          child: Text(title),
        ),
      ],
    );
  }
}
