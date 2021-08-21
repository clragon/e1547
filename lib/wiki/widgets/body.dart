import 'package:e1547/client.dart';
import 'package:e1547/dtext.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/tag.dart';
import 'package:e1547/wiki.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

class WikiBody extends StatefulWidget {
  final String tag;
  final PostController? controller;

  WikiBody({required this.tag, this.controller});

  @override
  _WikiBodyState createState() => _WikiBodyState();
}

class _WikiBodyState extends State<WikiBody> {
  late List<String> tags = sortTags(widget.tag).split(' ');

  @override
  Widget build(BuildContext context) {
    if (tags.length > 1) {
      Widget searchRemover(String tag) {
        return IconButton(
          icon: Icon(Icons.search_off),
          tooltip: 'Remove from search',
          onPressed: () {
            widget.controller!.search.value = widget.controller!.search.value
                .replaceFirst(RegExp(r'(?<!\S)-?' + tag + r'(?!\S)'), '');
            Navigator.of(context).maybePop();
          },
        );
      }

      Widget tagInfo(String tag) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: ExpandableNotifier(
            // initialExpanded: false,
            child: ExpandableTheme(
              data: ExpandableThemeData(
                headerAlignment: ExpandablePanelHeaderAlignment.center,
                iconColor: Theme.of(context).iconTheme.color,
              ),
              child: ExpandablePanel(
                header: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          tagToTitle(tag),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      if (widget.controller != null) searchRemover(tag),
                    ],
                  ),
                ),
                collapsed: SizedBox.shrink(),
                expanded: Padding(
                  padding: EdgeInsets.all(8),
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
    List<Wiki> results = await client.wiki(tagToName(widget.tag), 1);
    if (results.isNotEmpty) {
      return results.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: wiki,
      builder: (context, AsyncSnapshot<Wiki?> snapshot) => SafeCrossFade(
        showChild: snapshot.connectionState == ConnectionState.done,
        builder: (context) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              child: DTextField(source: snapshot.data!.body),
              physics: BouncingScrollPhysics(),
            );
          } else if (snapshot.hasError) {
            return IconMessage(
              title: Text('unable to retrieve wiki entry'),
              icon: Icon(Icons.warning_amber_outlined),
              direction: Axis.horizontal,
            );
          } else {
            return Center(
              child: Text(
                'no wiki entry',
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .color!
                      .withOpacity(0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          }
        },
        secondChild: Center(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: SizedCircularProgressIndicator(size: 26),
          ),
        ),
      ),
    );
  }
}
