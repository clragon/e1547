import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/wiki/wiki.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

Future<void> tagSearchSheet({
  required BuildContext context,
  required String tag,
}) async {
  PostsController? controller = context.read<PostsController?>();
  return showDefaultSlidingBottomSheet(
    context,
    (context, sheetState) => TagSearchSheet(
      tag: tag,
      controller: controller,
    ),
  );
}

class TagSearchSheet extends StatelessWidget {
  const TagSearchSheet({required this.tag, this.controller});

  final String tag;
  final PostsController? controller;

  @override
  Widget build(BuildContext context) {
    return DefaultSheetBody(
      title: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).maybePop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PostsSearchPage(tags: tag),
                    ),
                  );
                },
                child: Text(tagToName(tag)),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller != null)
                  TagSearchActions(
                    tag: tag,
                    controller: controller!,
                  ),
                TagListActions(
                  tag: tag,
                ),
              ],
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 600),
          child: TagSearchInfo(
            tag: tag,
            controller: controller,
          ),
        ),
      ),
    );
  }
}

class TagSearchInfo extends StatelessWidget {
  const TagSearchInfo({super.key, required this.tag, this.controller});

  final String tag;
  final PostsController? controller;

  @override
  Widget build(BuildContext context) {
    Widget tagInfo(String tag) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ExpandableNotifier(
          child: ExpandableTheme(
            data: ExpandableThemeData(
              headerAlignment: ExpandablePanelHeaderAlignment.center,
              iconColor: Theme.of(context).iconTheme.color,
            ),
            child: ExpandablePanel(
              header: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          tagToName(tag),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    if (controller != null)
                      RemoveTagAction(
                        controller: controller!,
                        tag: tag,
                      ),
                  ],
                ),
              ),
              collapsed: const SizedBox.shrink(),
              expanded: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [SearchTagDisplay(tag: tag)],
                ),
              ),
            ),
          ),
        ),
      );
    }

    List<String> tags = sortTags(tag).split(' ');

    if (tags.length > 1) {
      return Column(children: tags.map(tagInfo).toList());
    } else {
      return SearchTagDisplay(tag: tag);
    }
  }
}

class SearchTagDisplay extends StatefulWidget {
  const SearchTagDisplay({required this.tag});

  final String tag;

  @override
  State<SearchTagDisplay> createState() => _SearchTagDisplayState();
}

class _SearchTagDisplayState extends State<SearchTagDisplay> {
  late Future<Wiki?> wiki = retrieveWiki();

  Future<Wiki?> retrieveWiki() async {
    List<Wiki> results =
        await context.read<Client>().wikis(1, search: tagToRaw(widget.tag));
    return results.firstWhereOrNull((e) => e.title == tagToRaw(widget.tag));
  }

  @override
  void initState() {
    super.initState();
    String host = context.read<Client>().host;
    HistoriesService service = context.read<HistoriesService>();
    wiki.then((value) {
      if (value != null) {
        service.addWiki(host, value);
      } else {
        service.addWikiSearch(host, widget.tag);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Wiki?>(
      future: wiki,
      builder: (context, snapshot) => CrossFade.builder(
        style: FadeAnimationStyle.stacked,
        showChild: snapshot.connectionState == ConnectionState.done,
        builder: (context) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              primary: true,
              child: DText(snapshot.data!.body),
            );
          } else if (snapshot.hasError) {
            return const IconMessage(
              title: Text('unable to retrieve wiki entry'),
              icon: Icon(Icons.warning_amber_outlined),
              direction: Axis.horizontal,
            );
          } else {
            return Center(
              child: Text(
                'no wiki entry',
                style: TextStyle(
                  color: dimTextColor(context, 0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          }
        },
        secondChild: const Center(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

void tagSearchDialog({required BuildContext context, required String tag}) {
  showDialog(
    context: context,
    builder: (context) {
      return TagSearchDialog(
        tag: tag,
      );
    },
  );
}

class TagSearchDialog extends StatelessWidget {
  const TagSearchDialog({required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                tagToName(tag),
                softWrap: true,
              ),
            ),
            TagListActions(tag: tag),
          ],
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: constraints.maxHeight * 0.5,
          ),
          child: SearchTagDisplay(tag: tag),
        ),
      ),
    );
  }
}
