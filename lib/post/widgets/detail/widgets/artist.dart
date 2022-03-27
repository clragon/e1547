import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ArtistDisplay extends StatelessWidget {
  final Post post;
  final PostController? controller;

  const ArtistDisplay({
    required this.post,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    PostEditingController? editingController = PostEditor.of(context);

    Widget artists() {
      return AnimatedSelector(
        animation: Listenable.merge([editingController]),
        selector: () => [
          editingController?.value?.tags.hashCode,
        ],
        builder: (context, child) {
          List<String> artists = filterArtists(
              (editingController?.value?.tags ?? post.tags)['artist']!);
          if (artists.isNotEmpty) {
            List<InlineSpan> spans = [];
            for (String artist in artists) {
              if (artist != artists.first && artists.length > 1) {
                spans.add(TextSpan(text: ', '));
              }
              spans.add(
                WidgetSpan(
                  child: TagGesture(
                    tag: artist,
                    controller: controller,
                    child: Text(artist),
                  ),
                ),
              );
            }
            return Text.rich(
              TextSpan(children: spans),
              overflow: TextOverflow.fade,
              style: TextStyle(fontSize: 14.0),
            );
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
                  builder: (context) => InkWell(
                    child: Text('#${post.id}'),
                    onLongPress: () {
                      Clipboard.setData(
                          ClipboardData(text: post.id.toString()));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: Duration(seconds: 1),
                        content: Text('Copied post id #${post.id}'),
                      ));
                    },
                  ),
                ),
                InkWell(
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 14),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text(post.uploaderId.toString()),
                      ),
                    ],
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => UserLoadingPage(
                        post.uploaderId.toString(),
                        initalPage: UserPageSection.Uploads,
                      ),
                    ),
                  ),
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
