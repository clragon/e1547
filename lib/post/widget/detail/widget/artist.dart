import 'package:e1547/post/post.dart';
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 1),
                        content: Text('Copied post id #${post.id}'),
                      ),
                    );
                  },
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(4),
                  // TODO: implement
                  /*
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => UserLoadingPage(
                        post.uploaderId.toString(),
                        initalPage: UserPageSection.uploads,
                      ),
                    ),
                  ),
                  */
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
}

class ArtistName extends StatelessWidget {
  const ArtistName({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    Map<String, List<String>> tags = post.tags;

    List<String> artists =
        // TODO: implement
        (tags)['artist'] ?? []; // filterArtists((tags)['artist'] ?? []);
    if (artists.isNotEmpty) {
      return DefaultTextStyle.merge(
        overflow: TextOverflow.fade,
        style: const TextStyle(fontSize: 14),
        child: OverflowBar(
          children: [
            for (String artist in artists)
              Padding(
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.account_circle),
                    ),
                    Flexible(child: Text(artist)),
                  ],
                ),
              ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: DefaultTextStyle.merge(
          style: TextStyle(
            color: Theme.of(context).textTheme.titleSmall!.color,
            fontStyle: FontStyle.italic,
          ),
          child: const Text('no artist'),
        ),
      );
    }
  }
}
