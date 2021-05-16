import 'package:e1547/dtext.dart';
import 'package:e1547/pool.dart';
import 'package:flutter/material.dart';

class PoolPreview extends StatelessWidget {
  final Pool pool;
  final VoidCallback onPressed;

  PoolPreview(
    this.pool, {
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Widget title() {
      return Row(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
              child: Text(
                pool.name.replaceAll('_', ' '),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 22, top: 8, bottom: 8, right: 12),
            child: Text(
              pool.postIDs.length.toString(),
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      );
    }

    return Card(
      child: InkWell(
        onTap: this.onPressed,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 42,
              child: Center(child: title()),
            ),
            if (pool.description.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 0,
                  bottom: 8,
                ),
                child: DTextField(source: pool.description, dark: true),
              ),
          ],
        ),
      ),
    );
  }
}
