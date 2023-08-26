import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/markup/markup.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/wiki/wiki.dart';
import 'package:flutter/material.dart';

Future<void> tagSearchPrompt({
  required BuildContext context,
  required String tag,
}) async {
  bool isDesktop = [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ].contains(Theme.of(context).platform);

  if (isDesktop) {
    return tagSearchDialog(
      context: context,
      tag: tag,
    );
  }

  return tagSearchSheet(
    context: context,
    tag: tag,
  );
}

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(tagToName(tag)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(indent: 4, endIndent: 4),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
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
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
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
    List<String> tags = QueryMap.parse(tag).toString().split(' ');

    if (tags.length > 1) {
      return SingleChildScrollView(
        primary: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: tags
              .map(
                (e) => TagSearchInfoChild(
                  tag: e,
                  controller: controller,
                ),
              )
              .toList(),
        ),
      );
    } else {
      return SingleChildScrollView(
        primary: true,
        child: SearchTagDisplay(tag: tag),
      );
    }
  }
}

class TagSearchInfoChild extends StatelessWidget {
  const TagSearchInfoChild({
    super.key,
    required this.tag,
    this.controller,
  });

  final String tag;
  final PostsController? controller;

  @override
  Widget build(BuildContext context) {
    Widget actions(String tag, bool alignRight) {
      return SingleChildScrollView(
        reverse: alignRight,
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment:
              alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
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
        ),
      );
    }

    bool alignRight =
        context.findAncestorWidgetOfExactType<TagSearchDialog>() != null;
    return ExpandableNotifier(
      child: ExpandableTheme(
        data: ExpandableThemeData(
          headerAlignment: ExpandablePanelHeaderAlignment.center,
          iconColor: Theme.of(context).iconTheme.color,
          iconPlacement: alignRight ? ExpandablePanelIconPlacement.left : null,
        ),
        child: ExpandablePanel(
          header: Builder(
            builder: (context) {
              bool expanded = ExpandableController.of(context)!.expanded;
              return Row(
                children: [
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: expanded
                          ? Theme.of(context).textTheme.titleLarge!
                          : Theme.of(context).textTheme.titleMedium!,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(tagToName(tag)),
                      ),
                    ),
                  ),
                  if (expanded && alignRight) actions(tag, alignRight),
                ],
              );
            },
          ),
          collapsed: const SizedBox.shrink(),
          expanded: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!alignRight) actions(tag, alignRight),
              const SizedBox(height: 8),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: SearchTagDisplay(tag: tag),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
            return DText(snapshot.data!.body);
          } else if (snapshot.hasError) {
            return const IconMessage(
              title: Text('unable to retrieve wiki entry'),
              icon: Icon(Icons.warning_amber_outlined),
              direction: Axis.horizontal,
            );
          } else {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'no wiki entry',
                    style: TextStyle(
                      color: dimTextColor(context, 0.5),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            );
          }
        },
        secondChild: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> tagSearchDialog({
  required BuildContext context,
  required String tag,
}) {
  PostsController? controller = context.read<PostsController?>();
  return showDialog(
    context: context,
    builder: (context) => TagSearchDialog(
      tag: tag,
      controller: controller,
    ),
  );
}

class TagSearchDialog extends StatelessWidget {
  const TagSearchDialog({
    super.key,
    required this.tag,
    this.controller,
  });

  final String tag;
  final PostsController? controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => AlertDialog(
        content: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: SizedBox(
            width: 800,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        tagToName(tag),
                        style: Theme.of(context).textTheme.titleLarge,
                        softWrap: true,
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
                    ),
                  ],
                ),
                const Divider(indent: 4, endIndent: 4),
                Flexible(
                  child: TagSearchInfo(
                    tag: tag,
                    controller: controller,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
