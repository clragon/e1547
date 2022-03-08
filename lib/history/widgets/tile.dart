import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/wiki/wiki.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

class HistoryTile extends StatelessWidget {
  final HistoryEntry entry;

  const HistoryTile({
    Key? key,
    required this.entry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget titleText(String text) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
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
        padding: EdgeInsets.symmetric(horizontal: 8),
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
              icon: ShadowIcon(
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
      return SearchHistoryTile(
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
                ? titleText(tagToTitle(entry.name))
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
              icon: ShadowIcon(
                Icons.more_vert,
              ),
              onSelected: (value) => value(),
              itemBuilder: (context) => [
                if (entry.tags.isNotEmpty)
                  PopupMenuTile(
                    title: 'Wiki',
                    icon: Icons.info,
                    value: () => wikiSheet(
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

class SearchHistoryTile extends StatelessWidget {
  final Widget child;
  final List<String>? thumbnails;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const SearchHistoryTile({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.thumbnails,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ClipRRect(
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(5),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) => GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      primary: false,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: constraints.maxHeight * 0.5,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                      ),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        if (thumbnails != null && index < thumbnails!.length) {
                          BorderRadius borderRadius = BorderRadius.zero;
                          switch (index) {
                            case 0:
                              borderRadius = BorderRadius.only(
                                  bottomRight: Radius.circular(4));
                              break;
                            case 1:
                              borderRadius = BorderRadius.only(
                                  bottomLeft: Radius.circular(4));
                              break;
                            case 2:
                              borderRadius = BorderRadius.only(
                                  topRight: Radius.circular(4));
                              break;
                            case 3:
                              borderRadius = BorderRadius.only(
                                  topLeft: Radius.circular(4));
                              break;
                          }
                          return ClipRRect(
                            clipBehavior: Clip.antiAlias,
                            borderRadius: borderRadius,
                            child: Opacity(
                              opacity: 0.8,
                              child: CachedNetworkImage(
                                imageUrl: thumbnails![index],
                                errorWidget: defaultErrorBuilder,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        } else {
                          return Center(
                            child: Icon(Icons.image_not_supported_outlined),
                          );
                        }
                      },
                    ),
                  ),
                ),
                Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: onTap,
                    onLongPress: onLongPress,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: 200,
                      ),
                      child: child,
                    ),
                  ),
                )
              ],
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}
