import 'package:e1547/domain/domain.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/material.dart';

class TagGesture extends StatelessWidget {
  const TagGesture({
    super.key,
    required this.child,
    required this.tag,
    this.safe = true,
    this.wiki = false,
  });

  final bool safe;
  final bool wiki;
  final String tag;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    void sheet() => showTagSearchPrompt(context: context, tag: tag);

    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: () async {
        Traits traits = context.read<Domain>().traits.value;
        if (wiki || (safe && traits.denylist.contains(tag))) {
          sheet();
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PostsPage(query: {'tags': tag}),
            ),
          );
        }
      },
      onLongPress: sheet,
      onSecondaryTap: sheet,
      child: child,
    );
  }
}
