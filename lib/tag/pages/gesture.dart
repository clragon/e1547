import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:e1547/wiki.dart';
import 'package:flutter/material.dart';

class TagGesture extends StatelessWidget {
  final bool safe;
  final String tag;
  final Widget child;
  final PostProvider provider;

  const TagGesture(
      {@required this.child,
      @required this.tag,
      this.provider,
      this.safe = false});

  @override
  Widget build(BuildContext context) {
    Function wiki =
        () => wikiSheet(context: context, tag: tag, provider: provider);

    return InkWell(
      onTap: () async {
        if (safe && (await db.denylist.value).contains(tag)) {
          wiki();
        } else {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SearchPage(tags: tag),
          ));
        }
      },
      onLongPress: wiki,
      child: child,
    );
  }
}
