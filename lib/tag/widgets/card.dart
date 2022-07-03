import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class TagCard extends StatelessWidget {
  final String tag;
  final String? category;
  final Color? stripeColor;
  final VoidCallback? onRemove;
  final bool editing;
  final PostsController? controller;
  final bool wiki;
  final List<Widget>? extra;

  const TagCard({
    required this.tag,
    this.controller,
    this.category,
    this.stripeColor,
    this.onRemove,
    this.editing = false,
    this.wiki = false,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: TagGesture(
        tag: tag,
        wiki: wiki,
        controller: controller,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (stripeColor != null ||
                category != null ||
                editing ||
                onRemove != null)
              Container(
                height: 26,
                decoration: BoxDecoration(
                  color: stripeColor ??
                      (category != null
                          ? TagCategory.byName(category!).color
                          : null),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                  ),
                ),
                child: CrossFade(
                  showChild: editing,
                  secondChild: Container(width: 5),
                  child: IconButton(
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.clear, size: 16),
                    onPressed: onRemove,
                  ),
                ),
              ),
            Flexible(
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 4, bottom: 4, right: 8, left: 6),
                child: Text(
                  tagToCard(tag),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (extra != null) ...extra!
          ],
        ),
      ),
    );
  }
}

class TagCounterCard extends StatelessWidget {
  final String tag;
  final int count;
  final String? category;
  final PostsController? controller;

  const TagCounterCard({
    required this.tag,
    required this.count,
    this.category,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TagCard(
      tag: tag,
      category: category,
      controller: controller,
      wiki: true,
      extra: [
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
    );
  }
}

class DenyListTagCard extends StatelessWidget {
  final String tag;

  const DenyListTagCard(this.tag);

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

  @override
  Widget build(BuildContext context) {
    return TagCard(
      tag: tag,
      wiki: true,
      stripeColor: getTagColor(tag),
    );
  }
}
