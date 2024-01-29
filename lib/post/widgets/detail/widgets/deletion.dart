import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/markup/markup.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/data/map.dart';
import 'package:e1547/ticket/ticket.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class DeletionDisplay extends StatelessWidget {
  const DeletionDisplay({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context) {
    if (!post.isDeleted) return const SizedBox.shrink();
    return SubFuture<PostFlag>(
      create: () async {
        List<PostFlag> flags = await context.read<Client>().flags(
              limit: 1,
              query: TagMap({
                'type': 'deletion',
                'search[post_id]': post.id,
                'search[is_resolved]': 'false',
              }),
            );
        return flags.first;
      },
      builder: (context, value) => HiddenWidget(
        show: value.data != null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                'Deletion',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Theme.of(context)
                        .colorScheme
                        .errorContainer
                        .withOpacity(0.6),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: DText(
                        value.data?.reason ?? '',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
