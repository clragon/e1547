import 'package:flutter/material.dart';
import 'interface.dart';

class Pool {
  Map raw;

  int id;
  String name;
  String description;
  List<int> postIDs = [];
  String creator;
  String creation;
  String updated;
  bool active;

  Pool.fromRaw(this.raw) {
    id = raw['id'];
    name = raw['name'];
    description = raw['description'];
    postIDs.addAll(raw['post_ids'].cast<int>());
    creator = raw['creator_name'];
    active = raw['is_active'] as bool;
    creation = raw['created_at'];
    updated = raw['updated_at'];
  }

  Uri url(String host) =>
      new Uri(scheme: 'https', host: host, path: '/pools/$id');
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
                  fontSize: 18,
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
            child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              height: 42,
              child: Center(child: title()),
            ),
            () {
              if (pool.description != '') {
                return new Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 0,
                    bottom: 8,
                  ),
                  child: badTextField(context, pool.description, darkText: true),
                );
              } else {
                return new Container();
              }
            }(),
          ],
        )));
  }
}
