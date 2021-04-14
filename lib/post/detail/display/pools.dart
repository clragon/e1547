import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/pool.dart';
import 'package:e1547/post.dart';
import 'package:flutter/material.dart';

class PoolDisplay extends StatelessWidget {
  final Post post;

  PoolDisplay({@required this.post});

  @override
  Widget build(BuildContext context) {
    if (post.pools.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
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
          ),
          ...post.pools.map(
            (pool) => LoadingTile(
              leading: Icon(Icons.group),
              title: Text(pool.toString()),
              onTap: () async {
                Pool p = await client.pool(pool);
                if (p != null) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => PoolPage(pool: p)));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    duration: Duration(seconds: 1),
                    content: Text('Coulnd\'t retrieve Pool #${p.id}'),
                  ));
                }
              },
            ),
          ),
          Divider(),
        ],
      );
    } else {
      return Container();
    }
  }
}
