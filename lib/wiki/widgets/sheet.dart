import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/wiki/wiki.dart';
import 'package:flutter/material.dart';

Future<void> wikiSheet(BuildContext context, Wiki wiki) async {
  return showDefaultSlidingBottomSheet(
    context,
    (context, sheetState) => WikiSheet(wiki: wiki),
  );
}

class WikiSheet extends StatelessWidget {
  final Wiki wiki;

  const WikiSheet({required this.wiki});

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
                          builder: (context) => SearchPage(tags: wiki.title),
                        ),
                      );
                    },
                    child: Text(
                      tagToTitle(wiki.title),
                      style: Theme.of(context).textTheme.headline6,
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
