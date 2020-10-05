import 'package:e1547/interface.dart';
import 'package:e1547/settings.dart' show db;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';

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
    id = raw['id'] as int;
    name = raw['name'] as String;
    description = raw['description'] as String;
    postIDs.addAll(raw['post_ids'].cast<int>());
    creator = raw['creator_name'] as String;
    active = raw['is_active'] as bool;
    creation = raw['created_at'] as String;
    updated = raw['updated_at'] as String;
  }

  Uri url(String host) => Uri(scheme: 'https', host: host, path: '/pools/$id');
}

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
                () {
                  if (pool.description.isNotEmpty) {
                    return Padding(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 0,
                        bottom: 8,
                      ),
                      child:
                          dTextField(context, pool.description, darkText: true),
                    );
                  } else {
                    return Container();
                  }
                }(),
              ],
            )));
  }
}

class _FollowButton extends StatefulWidget {
  final Pool pool;

  _FollowButton(this.pool);

  @override
  State<StatefulWidget> createState() {
    return _FollowButtonState();
  }
}

class _FollowButtonState extends State<_FollowButton> {
  bool following = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<String> follows = snapshot.data;
          String tag = 'pool:${widget.pool.id}';
          follows.forEach((b) {
            if (b == tag) {
              following = true;
            }
          });
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                onPressed: () {
                  if (following) {
                    follows.removeAt(follows.indexOf(tag));
                    db.follows.value = Future.value(follows);
                    setState(() {
                      following = false;
                    });
                  } else {
                    follows.add(tag);
                    db.follows.value = Future.value(follows);
                    setState(() {
                      following = true;
                    });
                  }
                },
                icon: following
                    ? Icon(Icons.turned_in)
                    : Icon(Icons.turned_in_not),
                tooltip: following ? 'follow tag' : 'unfollow tag',
              ),
            ],
          );
        } else {
          return Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.turned_in_not),
                onPressed: () {},
              ),
            ],
          );
        }
      },
      future: db.follows.value,
    );
  }
}

Widget poolInfo(BuildContext context, Pool pool) {
  DateFormat dateFormat = DateFormat('dd.MM.yy HH:mm');
  Color textColor = Colors.grey[600];
  return AlertDialog(
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          child: Text(
            '${pool.name.replaceAll('_', ' ')} (#${pool.id})',
            softWrap: true,
          ),
        ),
        _FollowButton(pool),
      ],
    ),
    content: ConstrainedBox(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              pool.description.isNotEmpty
                  ? dTextField(context, pool.description)
                  : Text(
                      'no description',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
              Padding(
                padding: EdgeInsets.only(top: 16, bottom: 8),
                child: Divider(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'posts',
                    style: TextStyle(color: textColor),
                  ),
                  Text(
                    pool.postIDs.length.toString(),
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'status',
                    style: TextStyle(color: textColor),
                  ),
                  pool.active
                      ? Text(
                          'active',
                          style: TextStyle(color: textColor),
                        )
                      : Text(
                          'inactive',
                          style: TextStyle(color: textColor),
                        ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'created',
                    style: TextStyle(color: textColor),
                  ),
                  Text(
                    dateFormat.format(DateTime.parse(pool.creation).toLocal()),
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'updated',
                    style: TextStyle(color: textColor),
                  ),
                  Text(
                    dateFormat.format(DateTime.parse(pool.updated).toLocal()),
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
            ],
          ),
          physics: BouncingScrollPhysics(),
        ),
        constraints: BoxConstraints(
          maxHeight: 400.0,
        )),
    actions: [
      FlatButton(
        child: Text('SHARE'),
        onPressed: () async =>
            Share.share(pool.url(await db.host.value).toString()),
      ),
      FlatButton(
        child: Text('OK'),
        onPressed: () => Navigator.of(context).pop(),
      ),
    ],
  );
}
