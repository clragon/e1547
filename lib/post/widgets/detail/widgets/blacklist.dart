import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class DenylistTagDisplay extends StatelessWidget {
  const DenylistTagDisplay({super.key, required this.controller});

  final PostController controller;

  @override
  Widget build(BuildContext context) {
    return CrossFade.builder(
      showChild: controller.isDenied,
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
          ...controller.deniers!.map(
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
