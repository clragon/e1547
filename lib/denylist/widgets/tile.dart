import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class DenylistTile extends StatelessWidget {
  const DenylistTile({
    required this.tag,
    this.onEdit,
    this.onDelete,
  });

  final String tag;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  children: TagMap.parse(tag)
                      .getTags()
                      .map(DenyListTagCard.new)
                      .toList(),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PopupMenuButton<VoidCallback?>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onSelected: (value) => value?.call(),
                    itemBuilder: (context) => [
                      PopupMenuTile(
                        value: onEdit,
                        title: 'Edit',
                        icon: Icons.edit,
                      ),
                      PopupMenuTile(
                        value: onDelete,
                        title: 'Delete',
                        icon: Icons.delete,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const Divider()
        ],
      ),
    );
  }
}
