import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

class HistoryTile extends StatelessWidget {
  final HistoryEntry entry;

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

    if (entry is PostHistoryEntry) {
      PostHistoryEntry entry = this.entry as PostHistoryEntry;
      return PostPresenterTile(
        postId: entry.id,
        thumbnail: entry.thumbnail,
        child: SelectionItemOverlay<HistoryEntry>(
          item: entry,
          child: ListTile(
            title: titleText('Post #${entry.id}'),
            subtitle:
                subtitleText(getCurrentTimeFormat().format(entry.visitedAt)),
            trailing: PopupMenuButton<VoidCallback>(
              icon: const ShadowIcon(
                Icons.more_vert,
                color: Colors.white,
              ),
              onSelected: (value) => value(),
              itemBuilder: (context) => [
                PopupMenuTile(
                  value: () async =>
                      Share.share(getPostUri(client.host, entry.id).toString()),
                  title: 'Share',
                  icon: Icons.share,
                ),
                PopupMenuTile(
                  title: 'Delete',
                  icon: Icons.delete,
                  value: () => historyController.removeEntry(entry),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (entry is TagHistoryEntry) {
      TagHistoryEntry entry = this.entry as TagHistoryEntry;
      return ImageTile(
        thumbnails: entry.thumbnails,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SearchPage(tags: entry.tags),
          ),
        ),
        child: SelectionItemOverlay<HistoryEntry>(
          item: entry,
          child: ListTile(
            title: entry.tags.isNotEmpty
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
                if (entry.tags.isNotEmpty)
                  PopupMenuTile(
                    title: 'Wiki',
                    icon: Icons.info,
                    value: () => tagSearchSheet(
                      context: context,
                      tag: entry.tags,
                    ),
                  ),
                PopupMenuTile(
                  title: 'Delete',
                  icon: Icons.delete,
                  value: () => historyController.removeEntry(entry),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      throw UnimplementedError(
          'No tile implementation for this HistoryEntry: $entry');
    }
  }
}
