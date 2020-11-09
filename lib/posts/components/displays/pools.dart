import 'package:e1547/pools/pool.dart';
import 'package:e1547/posts/post.dart';
import 'package:e1547/posts/posts_page.dart';
import 'package:e1547/services/client.dart';
import 'package:flutter/material.dart';

class PoolDisplay extends StatelessWidget {
  final Post post;

  const PoolDisplay(this.post);

  @override
  Widget build(BuildContext context) {
    if (post.pools.length != 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: () {
          List<Widget> items = [];
          items.add(Padding(
            padding: EdgeInsets.only(
              right: 4,
              left: 4,
              top: 2,
              bottom: 2,
            ),
            child: Text(
              'Pools',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ));
          for (int pool in post.pools) {
            items.add(loadingListTile(
              leading: Icon(Icons.group),
              title: Text(pool.toString()),
              onTap: () async {
                Pool p = await client.pool(pool);
                if (p != null) {
                  Navigator.of(context)
                      .push(MaterialPageRoute<Null>(builder: (context) {
                    return PoolPage(pool: p);
                  }));
                } else {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    duration: Duration(seconds: 1),
                    content: Text('Coulnd\'t retrieve Pool #${p.id}'),
                  ));
                }
              },
            ));
          }
          items.add(Divider());
          return items;
        }(),
      );
    } else {
      return Container();
    }
  }
}
