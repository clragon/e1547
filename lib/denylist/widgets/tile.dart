import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class DenylistTile extends StatelessWidget {
  final String tag;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const DenylistTile({
    required this.tag,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  direction: Axis.horizontal,
                  children: Tagset.parse(tag)
                      .map((tag) => DenyListTagCard(tag.toString()))
                      .toList(),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
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
          Divider()
        ],
      ),
    );
  }
}
