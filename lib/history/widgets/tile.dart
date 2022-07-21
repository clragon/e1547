import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class HistoryTile extends StatelessWidget {
  final History entry;

  const HistoryTile({required this.entry});

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
              if (entry.subtitle != null)
                IgnorePointer(
                  child: DText(
                    entry.subtitle!.length > 400
                        ? '${entry.subtitle!.split('').take(400).join()}...'
                        : entry.subtitle!,
                  ),
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
                value: () async => Share.share(
                  context.read<Client>().withHost(entry.link),
                ),
              ),
              PopupMenuTile(
                title: 'Delete',
                icon: Icons.delete,
                value: () => context.read<HistoriesService>().remove(entry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
