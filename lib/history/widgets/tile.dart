import 'package:e1547/app/app.dart';
import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoryTile extends StatelessWidget {
  final History entry;

  const HistoryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return ImageTile(
      thumbnails: entry.thumbnails,
      onTap: parseLinkOnTap(context, entry.link),
      child: SelectionItemOverlay<History>(
        item: entry,
        child: ListTile(
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    entry.getName(context),
                    style: TextStyle(
                      shadows: getTextShadows(),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getCurrentTimeFormat().format(entry.visitedAt),
                  style: TextStyle(
                    shadows: getTextShadows(),
                    color: Colors.white70,
                  ),
                ),
                if (entry.subtitle != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: IgnorePointer(
                        child: DefaultTextStyle(
                          style: TextStyle(
                            shadows: getTextShadows(),
                            color: Colors.white70,
                          ),
                          child: DText(
                              '${entry.subtitle!.split('').take(200).join()}...'),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          trailing: PopupMenuButton<VoidCallback>(
            icon: const ShadowIcon(
              Icons.more_vert,
            ),
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
