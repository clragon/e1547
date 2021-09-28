import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ArtistDisplay extends StatelessWidget {
  final Post post;
  final PostController? controller;

  ArtistDisplay({required this.post, required this.controller});

  @override
  Widget build(BuildContext context) {
    Widget artists() {
      return AnimatedSelector(
        animation: post,
        selector: () => [post.tags.hashCode],
        builder: (context, child) {
          if (post.artists.isNotEmpty) {
            List<InlineSpan> spans = [];
            for (String artist in post.artists) {
              if (artist != post.artists.first && post.artists.length > 1) {
                spans.add(TextSpan(text: ', '));
              }
              spans.add(
                WidgetSpan(
                  child: TagGesture(
                    tag: artist,
                    controller: controller,
                    child: Text(artist, style: TextStyle(fontSize: 14.0)),
                  ),
                ),
              );
            }
            return Text.rich(TextSpan(children: spans),
                overflow: TextOverflow.fade);
          } else {
            return Text(
              'no artist',
              style: TextStyle(
                  color: Theme.of(context).textTheme.subtitle2!.color,
                  fontStyle: FontStyle.italic),
            );
          }
        },
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(Icons.account_circle),
                  ),
                  Flexible(
                    child: artists(),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Builder(
                  builder: (BuildContext context) {
                    return InkWell(
                      child: Text('#${post.id}'),
                      onLongPress: () {
                        Clipboard.setData(ClipboardData(
                          text: post.id.toString(),
                        ));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: Duration(seconds: 1),
                          content: Text('Copied post ID #${post.id}'),
                        ));
                      },
                    );
                  },
                ),
                InkWell(
                  child: Row(children: [
                    Icon(Icons.person, size: 14.0),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(post.uploaderId.toString()),
                    ),
                  ]),
                  onTap: () async {
                    String? uploader =
                        (await client.user(post.uploaderId.toString()))['name'];
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            SearchPage(tags: 'user:$uploader')));
                  },
                ),
              ],
            ),
          ],
        ),
        Divider(),
      ],
    );
  }
}
