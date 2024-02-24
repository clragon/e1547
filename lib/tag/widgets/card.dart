import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class TagCard extends StatelessWidget {
  const TagCard({
    super.key,
    required this.tag,
    this.category,
    this.onRemove,
  });

  final String tag;
  final String? category;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return ColoredCard(
      color: (category != null ? TagCategory.byName(category!).color : null),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PostsSearchPage(
            query: TagMap({'tags': tag}),
          ),
        ),
      ),
      onLongPress: () => showTagSearchPrompt(context: context, tag: tag),
      onSecondaryTap: () => showTagSearchPrompt(context: context, tag: tag),
      leading: onRemove != null
          ? IconButton(
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.clear, size: 16),
              onPressed: onRemove,
            )
          : null,
      child: Text(
        tagToTitle(tag),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class TagCounterCard extends StatelessWidget {
  const TagCounterCard({
    super.key,
    required this.tag,
    required this.count,
    this.category,
  });

  final String tag;
  final int count;
  final String? category;

  @override
  Widget build(BuildContext context) {
    return ColoredCard(
      color: (category != null ? TagCategory.byName(category!).color : null),
      trailing: Row(
        children: [
          Container(
            width: 2,
            height: 18,
            color: Theme.of(context).dividerColor,
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                count.toString(),
              ),
            ),
          ),
        ],
      ),
      child: Text(
        tagToTitle(tag),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class DenyListTagCard extends StatelessWidget {
  const DenyListTagCard(this.tag, {super.key});

  final String tag;

  Color? getTagColor(String tag) {
    String prefix = tag[0];
    switch (prefix) {
      case '-':
        return Colors.green[300];
      case '~':
        return Colors.orange[300];
      default:
        return Colors.red[300];
    }
  }

  Widget? getTagIcon(String tag) {
    String prefix = tag[0];
    switch (prefix) {
      case '-':
        return const Icon(Icons.check, size: 16);
      case '~':
        return const Icon(Icons.question_mark, size: 16);
      default:
        return const Icon(Icons.block, size: 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredCard(
      color: getTagColor(tag),
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: getTagIcon(tag),
      ),
      child: Text(
        tagToTitle(tag),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
