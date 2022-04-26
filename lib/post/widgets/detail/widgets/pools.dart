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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text('Pools', style: TextStyle(fontSize: 16)),
          ),
          ...post.pools.map(
            (id) => LoadingTile(
              leading: const Icon(Icons.group),
              title: Text(id.toString()),
              onTap: () async {
                Pool pool = await client.pool(id);
                try {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PoolPage(pool: pool),
                  ));
                } on DioError {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    duration: const Duration(seconds: 1),
                    content: Text('Coulnd\'t retrieve Pool #${pool.id}'),
                  ));
                }
              },
            ),
          ),
          const Divider(),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
