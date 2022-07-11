import 'package:e1547/app/app.dart';
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

    // TODO: implement image + text tile combo
    return ImageTile(
      thumbnails: entry.thumbnails,
      onTap: parseLinkOnTap(context, entry.link),
      child: SelectionItemOverlay<History>(
        item: entry,
        child: ListTile(
          title: true
              ? titleText(entry.name)
              : DefaultTextStyle(
                  style: TextStyle(
                    color: dimTextColor(context, 0.5),
                    fontStyle: FontStyle.italic,
                  ),
                  child: titleText(
                    'empty search',
                  ),
                ),
          subtitle:
              subtitleText(getCurrentTimeFormat().format(entry.visitedAt)),
          trailing: PopupMenuButton<VoidCallback>(
            icon: const ShadowIcon(
              Icons.more_vert,
            ),
            onSelected: (value) => value(),
            itemBuilder: (context) => [
              if (true)
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
