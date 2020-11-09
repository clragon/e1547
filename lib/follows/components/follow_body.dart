import 'package:e1547/follows/components/follow_card.dart';
import 'package:e1547/interface/pop_menu_tile.dart';
import 'package:e1547/pools/pool.dart';
import 'package:e1547/posts/posts_page.dart';
import 'package:e1547/services/client.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';

class FollowListBody extends StatelessWidget {
  final List<String> follows;

  const FollowListBody(
      {@required this.follows});

  @override
  Widget build(BuildContext context) {
    if (follows.length == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark,
              size: 32,
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Text('You are not following any tags'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: follows.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: () {
                        return [FollowTagCard(follows[index])];
                      }(),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          PopupMenuItem(
                            value: 'search',
                            child: PopMenuTile(
                                title: 'Search', icon: Icons.search),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: PopMenuTile(
                                title: 'Delete', icon: Icons.delete),
                          ),
                        ],
                        onSelected: (value) async {
                          switch (value) {
                            case 'search':
                              if (follows[index].startsWith('pool:')) {
                                Pool p = await client.pool(
                                    int.parse(follows[index].split(':')[1]));
                                Navigator.of(context).push(
                                    MaterialPageRoute<Null>(builder: (context) {
                                  return PoolPage(pool: p);
                                }));
                              } else {
                                Navigator.of(context).push(
                                    MaterialPageRoute<Null>(builder: (context) {
                                  return SearchPage(tags: follows[index]);
                                }));
                              }
                              break;
                            case 'delete':
                              db.follows.value =
                                  Future.value(follows..removeAt(index));
                              break;
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              Divider()
            ],
          ),
        );
      },
      physics: BouncingScrollPhysics(),
    );
  }
}
