import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ArtistDisplay extends StatelessWidget {
  const ArtistDisplay({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: ArtistName(post: post)),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text('#${post.id}'),
                  ),
                  onLongPress: () {
                    Clipboard.setData(ClipboardData(text: post.id.toString()));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      duration: const Duration(seconds: 1),
                      content: Text('Copied post id #${post.id}'),
                    ));
                  },
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: context.watch<Client>().hasFeature(ClientFeature.users)
                      ? () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => UserLoadingPage(
                                post.uploaderId.toString(),
                                initalPage: UserPageSection.uploads,
                              ),
                            ),
                          )
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person, size: 14),
                        const SizedBox(width: 4),
                        Text(post.uploaderId.toString()),
                      ],
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

  final Post post;
}

class ArtistName extends StatelessWidget {
  const ArtistName({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    Map<String, List<String>> tags =
        context.select<PostEditingController?, Map<String, List<String>>>(
            (value) => value?.value?.tags ?? post.tags);

    List<String> artists = filterArtists((tags)['artist'] ?? []);
    if (artists.isNotEmpty) {
      return OverflowBar(
        children: [
          for (String artist in artists)
            TagGesture(
              tag: artist,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.account_circle),
                    ),
                    Flexible(
                      child: Text(
                        tagToName(artist),
                        overflow: TextOverflow.fade,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          'no artist',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleSmall!.color,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }
  }
}
