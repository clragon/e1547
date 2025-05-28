import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/wiki/wiki.dart';
import 'package:flutter/material.dart';

Future<void> wikiPrompt(BuildContext context, Wiki wiki) async {
  if (Theme.of(context).isDesktop) {
    return wikiDialog(context, wiki);
  } else {
    return wikiSheet(context, wiki);
  }
}

Future<void> wikiSheet(BuildContext context, Wiki wiki) async {
  return showDefaultSlidingBottomSheet(
    context,
    (context, sheetState) => WikiSheet(wiki: wiki),
  );
}

Future<void> wikiDialog(BuildContext context, Wiki wiki) async {
  return showDialog(
    context: context,
    builder: (context) => WikiDialog(wiki: wiki),
  );
}

class WikiSheet extends StatelessWidget {
  const WikiSheet({super.key, required this.wiki});

  final Wiki wiki;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).maybePop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PostsSearchPage(
                            query: TagMap({'tags': wiki.title}),
                          ),
                        ),
                      );
                    },
                    child: Text(
                      tagToName(wiki.title),
                      style: Theme.of(context).textTheme.titleLarge,
                      softWrap: true,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: WikiInfo(wiki: wiki),
            ),
          ],
        ),
      ),
    );
  }
}

class WikiDialog extends StatelessWidget {
  const WikiDialog({super.key, required this.wiki});

  final Wiki wiki;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: 800,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tagToName(wiki.title),
              style: Theme.of(context).textTheme.titleLarge,
              softWrap: true,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: WikiInfo(wiki: wiki),
            ),
          ],
        ),
      ),
    );
  }
}
