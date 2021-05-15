import 'package:e1547/client.dart';
import 'package:e1547/dtext.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/wiki.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

class WikiBody extends StatefulWidget {
  final String tag;
  final PostProvider provider;

  WikiBody({@required this.tag, this.provider});

  @override
  _WikiBodyState createState() => _WikiBodyState();
}

class _WikiBodyState extends State<WikiBody> {
  @override
  Widget build(BuildContext context) {
    Tagset tags = Tagset.parse(widget.tag);
    if (tags.length > 1) {
      return Column(
        children: tags
            .map(
              (tag) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: ExpandableNotifier(
                    initialExpanded: false,
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
                                  tagToTitle(tag.toString()),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              if (widget.provider != null)
                                IconButton(
                                  icon: Icon(Icons.search_off),
                                  tooltip: 'Remove from search',
                                  onPressed: () {
                                    widget.provider.search.value = widget
                                        .provider.search.value
                                        ?.replaceFirst(
                                            RegExp(r'(?<!\S)-?' +
                                                tag.toString() +
                                                r'(?!\S)'),
                                            '');
                                    Navigator.of(context).maybePop();
                                  },
                                ),
                            ],
                          ),
                        ),
                        collapsed: SizedBox.shrink(),
                        expanded: Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [WikiTagDisplay(tag: tag.toString())],
                          ),
                        ),
                      ),
                    ),
                  )),
            )
            .toList(),
      );
    } else {
      return WikiTagDisplay(tag: tags.toString());
    }
  }
}

class WikiTagDisplay extends StatefulWidget {
  final String tag;

  const WikiTagDisplay({@required this.tag});

  @override
  _WikiTagDisplayState createState() => _WikiTagDisplayState();
}

class _WikiTagDisplayState extends State<WikiTagDisplay> {
  Wiki wiki;
  bool loading = true;
  bool error = false;

  @override
  void initState() {
    super.initState();
    loading = true;
    client.wiki(tagToName(widget.tag), 1).then((list) {
      if (list.isNotEmpty) {
        wiki = list.first;
      }
      setState(() {
        loading = false;
      });
    }).catchError((_) {
      setState(() {
        error = true;
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget message(Widget child) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              child,
            ],
          ),
        ],
      );
    }

    return CrossFade(
      showChild: loading,
      child: message(
        Padding(
          padding: EdgeInsets.all(16),
          child: Container(
            height: 26,
            width: 26,
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      secondChild: SafeCrossFade(
        showChild: wiki != null,
        builder: (context) => SingleChildScrollView(
          child: DTextField(msg: wiki.body),
          physics: BouncingScrollPhysics(),
        ),
        secondChild: message(
          error
              ? Text('unable to retrieve wiki entry',
                  style: TextStyle(fontStyle: FontStyle.italic))
              : Text(
                  'no wiki entry',
                  style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .color
                          .withOpacity(0.5),
                      fontStyle: FontStyle.italic),
                ),
        ),
      ),
    );
  }
}
