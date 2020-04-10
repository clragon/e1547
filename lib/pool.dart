import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Pool {
  Map raw;

  int id;
  String name;
  String description;
  List<int> postIDs = [];
  String creator;

  Pool.fromRaw(this.raw) {
    id = raw['id'];
    name = raw['name'];
    description = raw['description'];
    postIDs.addAll(raw['post_ids'].cast<int>());
    creator = raw['creator_name'];
  }
}

class PoolPreview extends StatelessWidget {
  final Pool pool;
  final VoidCallback onPressed;

  const PoolPreview(
    this.pool, {
    Key key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget title() {
      return new Row(
        children: <Widget>[
          new Expanded(
            child: new Container(
              padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
              child: new Text(
                pool.name.replaceAll('_', ' '),
                overflow: TextOverflow.ellipsis,
                style: new TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
          new Container(
            margin: EdgeInsets.only(left: 22, top: 8, bottom: 8, right: 12),
            child: Text(
              pool.postIDs.length.toString(),
              style: new TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      );
    }

    return new GestureDetector(
        onTap: this.onPressed,
        child: new Card(
          child: new Center(
            child: title(),
          ),
        ));
  }
}
