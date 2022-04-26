import 'package:e1547/client/client.dart';
import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/wiki/wiki.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import 'actions.dart';

class WikiBody extends StatefulWidget {
  final String tag;
  final PostController? controller;

  const WikiBody({required this.tag, this.controller});

  @override
  _WikiBodyState createState() => _WikiBodyState();
}

class _WikiBodyState extends State<WikiBody> {
  late List<String> tags = sortTags(widget.tag).split(' ');

  @override
  Widget build(BuildContext context) {
    if (tags.length > 1) {
      Widget tagInfo(String tag) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ExpandableNotifier(
            // initialExpanded: false,
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
                        child: Text(
                          tagToTitle(tag),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      if (widget.controller != null)
                        RemoveTagAction(
                            controller: widget.controller!, tag: tag),
                    ],
                  ),
                ),
                collapsed: const SizedBox.shrink(),
                expanded: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [WikiTagDisplay(tag: tag)],
                  ),
                ),
              ),
            ),
          ),
        );
      }

      return Column(children: tags.map(tagInfo).toList());
    } else {
      return WikiTagDisplay(tag: widget.tag);
    }
  }
}

class WikiTagDisplay extends StatefulWidget {
  final String tag;

  const WikiTagDisplay({required this.tag});

  @override
  _WikiTagDisplayState createState() => _WikiTagDisplayState();
}

class _WikiTagDisplayState extends State<WikiTagDisplay> {
  late Future<Wiki?> wiki = retrieveWiki();

  Future<Wiki?> retrieveWiki() async {
    List<Wiki> results = await client.wikis(1, search: tagToName(widget.tag));
    if (results.isNotEmpty && results.first.title == widget.tag) {
      return results.first;
    } else {
      return null;
    }
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
