import 'package:e1547/interface.dart';
import 'package:e1547/pool.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';

class FollowButton extends StatefulWidget {
  final Pool pool;

  FollowButton(this.pool);

  @override
  State<StatefulWidget> createState() {
    return FollowButtonState();
  }
}

class FollowButtonState extends State<FollowButton> {
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
                    follows.remove(tag);
                  } else {
                    follows.add(tag);
                  }
                  db.follows.value = Future.value(follows);
                  setState(() {
                    following = false;
                  });
                },
                icon: CrossFade(
                  showChild: following,
                  child: Icon(Icons.turned_in),
                  secondChild: Icon(Icons.turned_in_not),
                ),
                tooltip: following ? 'unfollow tag' : 'follow tag',
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
