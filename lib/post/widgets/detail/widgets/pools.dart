import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class PoolDisplay extends StatelessWidget {
  const PoolDisplay({required this.post});

  final Post post;

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
            (id) => ListTile(
              leading: const Icon(Icons.group),
              title: Text(id.toString()),
              trailing: const Icon(Icons.arrow_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => PoolLoadingPage(id),
              )),
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
