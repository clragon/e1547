import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class PoolDisplay extends StatelessWidget {
  final Post post;

  const PoolDisplay({required this.post});

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
                try {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => PoolPage(pool: p)));
                } on DioError {
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
      return SizedBox.shrink();
    }
  }
}
