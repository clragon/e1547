import 'package:e1547/client.dart';
import 'package:e1547/post.dart';
import 'package:e1547/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ArtistDisplay extends StatelessWidget {
  final Post post;
  final PostProvider provider;

  ArtistDisplay({@required this.post, @required this.provider});

  @override
  Widget build(BuildContext context) {
    Widget artists() {
      return ValueListenableBuilder(
        valueListenable: post.tags,
        builder: (BuildContext context, value, Widget child) {
          if (value['artist'].isNotEmpty) {
            return Text.rich(
              TextSpan(
                children: post.artists
                    .map<List<InlineSpan>>(
                      (artist) => [
                        if (artist != post.artists.first &&
                            post.artists.length > 1)
                          TextSpan(text: ', '),
                        WidgetSpan(
                          child: TagGesture(
                            tag: artist,
                            provider: provider,
                            child: Text(
                              artist,
                              style: TextStyle(
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                    .reduce(
                      (value, element) => [...value, ...element],
                    ),
              ),
              overflow: TextOverflow.fade,
            );
          } else {
            return Text('no artist',
                style: TextStyle(
                    color: Theme.of(context).textTheme.subtitle2.color,
                    fontStyle: FontStyle.italic));
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
                      child: Text(post.uploader.toString()),
                    ),
                  ]),
                  onTap: () async {
                    String uploader =
                        (await client.user(post.uploader.toString()))['name'];
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
