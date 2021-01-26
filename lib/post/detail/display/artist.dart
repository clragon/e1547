import 'package:e1547/client.dart';
import 'package:e1547/post.dart';
import 'package:e1547/wiki.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ArtistDisplay extends StatefulWidget {
  final Post post;

  const ArtistDisplay({@required this.post});

  @override
  _ArtistDisplayState createState() => _ArtistDisplayState();
}

class _ArtistDisplayState extends State<ArtistDisplay> {
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
    Widget artists() {
      if (widget.post.tags.value['artist'].length != 0) {
        return Text.rich(
          TextSpan(children: () {
            List<InlineSpan> spans = [];
            int count = 0;
            for (String artist in widget.post.artists) {
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
                onTap: () => Navigator.of(context).push(MaterialPageRoute<Null>(
                    builder: (context) => SearchPage(tags: artist))),
                onLongPress: () => wikiDialog(context, artist, actions: true),
              )));
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
                      child: Text('#${widget.post.id}'),
                      onLongPress: () {
                        Clipboard.setData(ClipboardData(
                          text: widget.post.id.toString(),
                        ));
                        Scaffold.of(context).showSnackBar(SnackBar(
                          duration: Duration(seconds: 1),
                          content: Text('Copied post ID #${widget.post.id}'),
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
                      child: Text(widget.post.uploader.toString()),
                    ),
                  ]),
                  onTap: () async {
                    String uploader = (await client
                        .user(widget.post.uploader.toString()))['name'];
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
