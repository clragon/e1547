import 'package:e1547/pools/pool.dart';
import 'package:e1547/posts/posts_page.dart';
import 'package:e1547/services/client.dart';
import 'package:e1547/wiki/wiki_page.dart';
import 'package:flutter/material.dart';

class FollowTagCard extends StatelessWidget {
  final String tag;

  const FollowTagCard(this.tag);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: InkWell(
            onTap: () async {
              if (tag.startsWith('pool:')) {
                Pool p = await client.pool(int.parse(tag.split(':')[1]));
                Navigator.of(context)
                    .push(MaterialPageRoute<Null>(builder: (context) {
                  return PoolPage(pool: p);
                }));
              } else {
                Navigator.of(context)
                    .push(MaterialPageRoute<Null>(builder: (context) {
                  return SearchPage(tags: tag);
                }));
              }
            },
            onLongPress: () => wikiDialog(context, tag, actions: true),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Text(tag),
            )));
  }
}
