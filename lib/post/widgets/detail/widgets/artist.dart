import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ArtistDisplay extends StatelessWidget {
  const ArtistDisplay({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(Icons.account_circle),
                  ),
                  Flexible(
                    child: ArtistName(post: post),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                InkWell(
                  child: Text('#${post.id}'),
                  onLongPress: () {
                    Clipboard.setData(ClipboardData(text: post.id.toString()));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      duration: const Duration(seconds: 1),
                      content: Text('Copied post id #${post.id}'),
                    ));
                  },
                ),
                InkWell(
                  child: Row(
                    children: [
                      const Icon(Icons.person, size: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(post.uploaderId.toString()),
                      ),
                    ],
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => UserLoadingPage(
                        post.uploaderId.toString(),
                        initalPage: UserPageSection.uploads,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }
}

class ArtistName extends StatelessWidget {
  const ArtistName({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    Map<String, List<String>> tags =
        context.select<PostEditingController?, Map<String, List<String>>>(
            (value) => value?.value?.tags ?? post.tags);

    List<String> artists = filterArtists((tags)['artist']!);
    if (artists.isNotEmpty) {
      List<InlineSpan> spans = [];
      for (String artist in artists) {
        if (artist != artists.first && artists.length > 1) {
          spans.add(const TextSpan(text: ', '));
        }
        spans.add(
          WidgetSpan(
            child: TagGesture(
              tag: artist,
              child: Text(artist),
            ),
          ),
        );
      }
      return Text.rich(
        TextSpan(children: spans),
        overflow: TextOverflow.fade,
        style: const TextStyle(fontSize: 14),
      );
    } else {
      return Text(
        'no artist',
        style: TextStyle(
            color: Theme.of(context).textTheme.titleSmall!.color,
            fontStyle: FontStyle.italic),
      );
    }
  }
}
