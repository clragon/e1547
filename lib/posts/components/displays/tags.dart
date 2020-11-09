import 'package:e1547/interface/cross_fade.dart';
import 'package:e1547/posts/post.dart';
import 'package:e1547/posts/posts_page.dart';
import 'package:e1547/services/client.dart';
import 'package:e1547/util/text_helper.dart';
import 'package:e1547/wiki/wiki_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

Map group = {
  'general': 0,
  'species': 5,
  'character': 4,
  'copyright': 3,
  'artist': 1,
  'invalid': 6,
  'lore': 8,
  'meta': 7,
};

List<String> tagSets = [
  'general',
  'species',
  'character',
  'copyright',
  'meta',
  'lore',
  'artist',
  'invalid',
];

class TagCard extends StatelessWidget {
  final Post post;
  final String tag;
  final String tagSet;

  const TagCard(this.post, this.tag, this.tagSet);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: InkWell(
            onTap: () => Navigator.of(context).push(MaterialPageRoute<Null>(
                  builder: (context) => SearchPage(tags: tag),
                )),
            onLongPress: () => wikiDialog(context, tag, actions: true),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: () {
                      switch (tagSet) {
                        case 'general':
                          return Colors.indigo[300];
                        case 'species':
                          return Colors.teal[300];
                        case 'character':
                          return Colors.lightGreen[300];
                        case 'copyright':
                          return Colors.yellow[300];
                        case 'meta':
                          return Colors.deepOrange[300];
                        case 'lore':
                          return Colors.pink[300];
                        case 'artist':
                          return Colors.deepPurple[300];
                        default:
                          return Colors.grey[300];
                      }
                    }(),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5),
                        bottomLeft: Radius.circular(5)),
                  ),
                  height: 24,
                  child: CrossFade(
                    showChild: post.isEditing.value,
                    child: InkWell(
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: 4, left: 4, top: 4, bottom: 4),
                        child: Icon(Icons.clear, size: 16),
                      ),
                      onTap: () {
                        post.tags.value[tagSet].remove(tag);
                        post.tags.value = Map.from(post.tags.value);
                      },
                    ),
                    secondChild: Container(width: 5),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding:
                        EdgeInsets.only(top: 4, bottom: 4, right: 8, left: 6),
                    child: Text(
                      tag.replaceAll('_', ' '),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            )));
  }
}

class TagInput extends StatelessWidget {
  final bool isLoading;
  final String tagSet;
  final TextEditingController textController;
  final Future<void> Function() onSubmit;

  const TagInput(
      {@required this.isLoading,
      @required this.textController,
      @required this.onSubmit,
      @required this.tagSet});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              isLoading
                  ? Center(
                      child: Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Container(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator()),
                    ))
                  : Container(),
              Expanded(
                child: TypeAheadField(
                  direction: AxisDirection.up,
                  hideOnLoading: true,
                  hideOnEmpty: true,
                  hideOnError: true,
                  keepSuggestionsOnSuggestionSelected: true,
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: textController,
                    autofocus: true,
                    maxLines: 1,
                    inputFormatters: [LowercaseTextInputFormatter()],
                    decoration: InputDecoration(
                        labelText: tagSet, border: UnderlineInputBorder()),
                    onSubmitted: (_) async => onSubmit(),
                  ),
                  onSuggestionSelected: (suggestion) {
                    List<String> tags = textController.text.split(' ');
                    List<String> before = [];
                    for (String tag in tags) {
                      before.add(tag);
                      if (before.join(' ').length >=
                          textController.selection.extent.offset) {
                        tags[tags.indexOf(tag)] = suggestion;
                        break;
                      }
                    }
                    textController.text = tags.join(' ') + ' ';
                    setFocusToEnd(textController);
                  },
                  itemBuilder: (BuildContext context, itemData) {
                    return ListTile(
                      title: Text(itemData),
                    );
                  },
                  suggestionsCallback: (String pattern) async {
                    List<String> tags = textController.text.split(' ');
                    List<String> before = [];
                    int selection = 0;
                    for (String tag in tags) {
                      before.add(tag);
                      if (before.join(' ').length >=
                          textController.selection.extent.offset) {
                        selection = tags.indexOf(tag);
                        break;
                      }
                    }
                    if (tags[selection].trim().isNotEmpty) {
                      return (await client.tags(tags[selection],
                              category: group[tagSet]))
                          .map((t) => t['name'])
                          .toList();
                    } else {
                      return [];
                    }
                  },
                ),
              ),
            ],
          )
        ]));
  }
}

class TagEditor extends StatelessWidget {
  final String tagSet;
  final Future<void> Function(String) onEdit;

  const TagEditor(this.tagSet, this.onEdit);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        return Card(
          child: InkWell(
            child: Padding(
              padding: EdgeInsets.only(top: 4, bottom: 4, left: 4, right: 4),
              child: Icon(Icons.add, size: 16),
            ),
            onTap: () => onEdit(tagSet),
          ),
        );
      },
    );
  }
}

class TagDisplay extends StatefulWidget {
  final Post post;
  final Future<void> Function(String) onEdit;

  const TagDisplay(this.post, this.onEdit);

  @override
  _TagDisplayState createState() => _TagDisplayState();
}

class _TagDisplayState extends State<TagDisplay> {
  @override
  void initState() {
    super.initState();
    widget.post.tags.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    widget.post.tags.removeListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: () {
        List<Widget> columns = [];
        for (String tagSet in tagSets) {
          if (widget.post.tags.value[tagSet].length != 0 ||
              (widget.post.isEditing.value && tagSet != 'invalid')) {
            columns.add(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 4,
                    left: 4,
                    top: 2,
                    bottom: 2,
                  ),
                  child: Text(
                    '${tagSet[0].toUpperCase()}${tagSet.substring(1)}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Wrap(
                        direction: Axis.horizontal,
                        children: () {
                          List<Widget> tags = [];
                          for (String tag in widget.post.tags.value[tagSet]) {
                            tags.add(
                              TagCard(widget.post, tag, tagSet),
                            );
                          }
                          tags.add(CrossFade(
                            showChild: widget.post.isEditing.value,
                            child: TagEditor(tagSet, widget.onEdit),
                          ));
                          return tags;
                        }(),
                      ),
                    )
                  ],
                ),
                Divider(),
              ],
            ));
          }
        }
        return columns;
      }(),
    );
  }
}
