import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class DenylistTagDisplay extends StatelessWidget {
  final PostController post;

  const DenylistTagDisplay({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return CrossFade.builder(
      showChild: post.isDenied,
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              'Blacklisted',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          ...post.deniers!.map(
            (e) => Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        leading: const Icon(Icons.block),
                        title: Wrap(
                          children: [
                            ...e.split(' ').trim().map(DenyListTagCard.new),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
