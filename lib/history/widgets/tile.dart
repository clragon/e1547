import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/markup/markup.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class HistoryTile extends StatelessWidget {
  const HistoryTile({super.key, required this.entry});

  final History entry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(4),
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: const E621LinkParser().parseOnTap(context, entry.link),
            child: SelectionItemOverlay<History>(
              item: entry,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TimedText(
                            created: entry.visitedAt,
                            child: DefaultTextStyle(
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(entry.getName(context)),
                              ),
                            ),
                          ),
                        ),
                        PopupMenuButton<VoidCallback>(
                          icon: Icon(
                            Icons.more_vert,
                            color: dimTextColor(context),
                          ),
                          iconSize: 18,
                          onSelected: (value) => value(),
                          itemBuilder: (context) => [
                            if (entry.isSearch(LinkType.post))
                              PopupMenuTile(
                                title: 'Wiki',
                                icon: Icons.info,
                                value: () => showTagSearchPrompt(
                                  context: context,
                                  tag: const E621LinkParser()
                                      .parse(entry.link)!
                                      .query!['tags']!,
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
                            PopupMenuTile(
                              title: 'Delete',
                              icon: Icons.delete,
                              value: () => context
                                  .read<Client>()
                                  .histories
                                  .remove(id: entry.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (entry.subtitle?.isNotEmpty ?? false)
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 8,
                              ),
                              child: ExcludeFocus(
                                child: IgnorePointer(
                                  child: Opacity(
                                    opacity: 0.7,
                                    child: DText(entry.subtitle!.ellipse(400)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      const SizedBox(height: 8),
                    ImageTile(
                      images: entry.thumbnails,
                      title: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(entry.getName(context)),
                      ),
                      showTitle: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Divider(indent: 8, endIndent: 8),
      ],
    );
  }
}
