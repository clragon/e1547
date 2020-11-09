import 'package:e1547/posts/post.dart';
import 'package:e1547/posts/posts_page.dart';
import 'package:e1547/services/client.dart';
import 'package:e1547/wiki/wiki_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ArtistText extends StatefulWidget {
  final Post post;

  const ArtistText(this.post);

  @override
  _ArtistTextState createState() => _ArtistTextState();
}

class _ArtistTextState extends State<ArtistText> {
  @override
  void initState() {
    super.initState();
    widget.post.tags.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    widget.post.tags.removeListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.post.tags.value['artist'].length != 0) {
      return Text.rich(
        TextSpan(children: () {
          List<InlineSpan> spans = [];
          int count = 0;
          for (String artist in widget.post.tags.value['artist']) {
            switch (artist) {
              case 'conditional_dnp':
              case 'sound_warning':
              case 'epilepsy_warning':
              case 'avoid_posting':
                break;
              default:
                count++;
                if (count > 1) {
                  spans.add(TextSpan(text: ', '));
                }
                spans.add(WidgetSpan(
                    child: InkWell(
                  child: Text(
                    artist,
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                  onTap: () {
                    return Navigator.of(context)
                        .push(MaterialPageRoute<Null>(builder: (context) {
                      return SearchPage(tags: artist);
                    }));
                  },
                  onLongPress: () => wikiDialog(context, artist, actions: true),
                )));
                break;
            }
          }
          return spans;
        }()),
        overflow: TextOverflow.fade,
      );
    } else {
      return Text('no artist',
          style: TextStyle(
              color: Theme.of(context).textTheme.subtitle2.color,
              fontStyle: FontStyle.italic));
    }
  }
}

class ArtistDisplay extends StatelessWidget {
  final Post post;

  const ArtistDisplay(this.post);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(Icons.account_circle),
                  ),
                  Flexible(
                    child: ArtistText(post),
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
                        Scaffold.of(context).showSnackBar(SnackBar(
                          duration: Duration(seconds: 1),
                          content:
                              Text('Copied post ID #${post.id.toString()}'),
                        ));
                      },
                    );
                  },
                ),
                InkWell(
                  child: Row(children: [
                    Icon(Icons.person, size: 14.0),
                    Text(' ${post.uploader}'),
                  ]),
                  onTap: () async {
                    String uploader =
                        (await client.user(post.uploader.toString()))['name'];
                    Navigator.of(context)
                        .push(MaterialPageRoute<Null>(builder: (context) {
                      return SearchPage(tags: 'user:$uploader');
                    }));
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
