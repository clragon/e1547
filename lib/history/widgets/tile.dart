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

  const HistoryTile({
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    Widget titleText(String text) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          text,
          style: TextStyle(
            shadows: getTextShadows(),
            color: Colors.white,
          ),
        ),
      );
    }

    Widget subtitleText(String text) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          text,
          style: TextStyle(
            shadows: getTextShadows(),
            color: Colors.white70,
          ),
        ),
      );
    }

    return ImageTile(
      thumbnails: entry.thumbnails,
      onTap: parseLinkOnTap(context, entry.link),
      child: SelectionItemOverlay<History>(
        item: entry,
        child: ListTile(
          title: Row(
            children: [
              titleText(entry.name),
              const SizedBox(width: 8),
              subtitleText(getCurrentTimeFormat().format(entry.visitedAt)),
            ],
          ),
          subtitle: entry.subtitle != null ? DText(entry.subtitle!) : null,
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
                    tag: entry.link,
                  ),
                ),
              PopupMenuTile(
                title: 'Delete',
                icon: Icons.delete,
                value: () =>
                    Provider.of<HistoriesService>(context).remove(entry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
