import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/history/widgets/appbar.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/data/actions.dart';
import 'package:e1547/settings/settings.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        settings.history,
        client,
      ]),
      builder: (context, child) {
        List<HistoryEntry> history =
            List.from(settings.history.value[client.host] ?? []);
        if (history.isEmpty) {
          return IconMessage(
            icon: Icon(Icons.history),
            title: Text('Your history is empty'),
          );
        }

        return SelectionScope<HistoryEntry>(
          builder: (context, selections, onChanged) => Scaffold(
            appBar: selections.isEmpty
                ? DefaultAppBar(
                    title: Text('History'),
                  )
                : HistorySelectionAppBar(
                    selections: selections,
                    onChanged: onChanged,
                    onSelectAll: () => history.toSet(),
                  ),
            body: GroupedListView<HistoryEntry, DateTime>(
              elements: history,
              order: GroupedListOrder.DESC,
              physics: BouncingScrollPhysics(),
              controller: PrimaryScrollController.of(context),
              groupBy: (element) => element.visitedAt.stripTime(),
              groupHeaderBuilder: (element) {
                String title =
                    getCurrentDateFormat().format(element.visitedAt.toLocal());
                if (DateTime.now()
                    .stripTime()
                    .isAtSameMomentAs(element.visitedAt.stripTime())) {
                  title = 'Today';
                }
                if (DateTime.now()
                    .stripTime()
                    .subtract(Duration(days: 1))
                    .isAtSameMomentAs(element.visitedAt.stripTime())) {
                  title = 'Yesterday';
                }
                return SettingsHeader(title: title);
              },
              itemComparator: (a, b) => a.visitedAt.compareTo(b.visitedAt),
              itemBuilder: (context, element) => PostPresenterTile(
                postId: element.postId,
                thumbnail: element.thumbnail,
                child: SelectionItemOverlay<HistoryEntry>(
                  selections: selections,
                  onChanged: onChanged,
                  item: element,
                  child: ListTile(
                    title: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'Post #${element.postId}',
                        style: TextStyle(
                          shadows: getTextShadows(),
                          color: Colors.white,
                        ),
                      ),
                    ),
                    subtitle: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        getCurrentTimeFormat().format(element.visitedAt),
                        style: TextStyle(
                          shadows: getTextShadows(),
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PopupMenuButton<VoidCallback>(
                          icon: ShadowIcon(
                            Icons.more_vert,
                            color: Colors.white,
                          ),
                          onSelected: (value) => value(),
                          itemBuilder: (context) => [
                            PopupMenuTile(
                              value: () async => Share.share(
                                  getPostUri(client.host, element.postId)
                                      .toString()),
                              title: 'Share',
                              icon: Icons.share,
                            ),
                            PopupMenuTile(
                              title: 'Delete',
                              icon: Icons.delete,
                              value: () => removeFromHistory(element),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
