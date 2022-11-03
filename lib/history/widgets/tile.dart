import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class HistoryTile extends StatelessWidget {
  const HistoryTile({required this.entry});

  final History entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: SelectionItemOverlay<History>(
        item: entry,
        padding: const EdgeInsets.only(bottom: 16),
        child: ImageTile(
          images: entry.thumbnails,
          onTap: parseLinkOnTap(context, entry.link),
          title: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(entry.getName(context)),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(formatTime(entry.visitedAt)),
              ),
              if (entry.subtitle?.isNotEmpty ?? false)
                IgnorePointer(
                  child: DText(entry.subtitle!.ellipse(400)),
                ),
            ],
          ),
          trailing: PopupMenuButton<VoidCallback>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => value(),
            itemBuilder: (context) => [
              if (entry.isSearch(LinkType.post))
                PopupMenuTile(
                  title: 'Wiki',
                  icon: Icons.info,
                  value: () => tagSearchSheet(
                    context: context,
                    tag: parseLink(entry.link)!.search!,
                  ),
                ),
              if (entry.subtitle != null)
                PopupMenuTile(
                  title: 'Description',
                  icon: Icons.description,
                  value: () => historySheet(
                    context: context,
                    entry: entry,
                  ),
                ),
              PopupMenuTile(
                title: 'Share',
                icon: Icons.share,
                value: () => Share.share(
                  context,
                  context.read<Client>().withHost(entry.link),
                ),
              ),
              if (context.read<HistoriesController?>() != null)
                PopupMenuTile(
                  title: 'Delete',
                  icon: Icons.delete,
                  value: () =>
                      context.read<HistoriesController>().remove(entry),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
