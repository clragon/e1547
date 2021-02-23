import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/wiki.dart';
import 'package:flutter/material.dart';

class TagDisplay extends StatefulWidget {
  final Post post;
  final PostProvider provider;
  final Function() onEditorClose;
  final Function(Future<bool> Function() submit) builder;

  TagDisplay(
      {@required this.post,
      @required this.provider,
      this.onEditorClose,
      this.builder});

  @override
  _TagDisplayState createState() => _TagDisplayState();
}

class _TagDisplayState extends State<TagDisplay> {
  PersistentBottomSheetController sheetController;

  @override
  Widget build(BuildContext context) {
    Widget tagPlus(String category) {
      return Card(
        child: Builder(
          builder: (BuildContext context) {
            return InkWell(
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.add, size: 16),
              ),
              onTap: () async {
                sheetController = Scaffold.of(context).showBottomSheet(
                  (context) => TagEditor(
                    post: widget.post,
                    category: category,
                    onSubmit: sheetController?.close,
                    builder: widget.builder,
                  ),
                );
                sheetController.closed.then((_) {
                  widget.onEditorClose();
                });
              },
            );
          },
        ),
      );
    }

    return ValueListenableBuilder(
      valueListenable: widget.post.tags,
      builder: (BuildContext context, value, Widget child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: categories.keys
              .where((tagSet) =>
                  value[tagSet].length != 0 ||
                  (widget.post.isEditing.value && tagSet != 'invalid'))
              .map(
                (category) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text(
                        '${category[0].toUpperCase()}${category.substring(1)}',
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
                              for (String tag in value[category]) {
                                tags.add(
                                  TagCard(
                                    tag: tag,
                                    category: category,
                                    provider: widget.provider,
                                    onRemove: widget.post.isEditing.value
                                        ? () {
                                            widget.post.tags.value[category]
                                                .remove(tag);
                                            widget.post.tags.value =
                                                Map.from(value);
                                          }
                                        : null,
                                  ),
                                );
                              }
                              tags.add(CrossFade(
                                showChild: widget.post.isEditing.value,
                                child: tagPlus(category),
                              ));
                              return tags;
                            }(),
                          ),
                        )
                      ],
                    ),
                    Divider(),
                  ],
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class TagEditor extends StatefulWidget {
  final Post post;
  final String category;
  final Function() onSubmit;
  final Function(Future<bool> Function() submit) builder;

  TagEditor({
    @required this.post,
    @required this.category,
    this.onSubmit,
    this.builder,
  });

  @override
  _TagEditorState createState() => _TagEditorState();
}

class _TagEditorState extends State<TagEditor> {
  ValueNotifier isLoading = ValueNotifier(false);
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.builder?.call(() {
      return submit(context, controller.text);
    });
  }

  Future<bool> submit(BuildContext context, String result) async {
    isLoading.value = true;
    result = result.trim();
    if (result.isEmpty) {
      isLoading.value = false;
      widget.onSubmit?.call();
      return true;
    }
    List<String> tags = result.split(' ');
    widget.post.tags.value[widget.category].addAll(tags);
    widget.post.tags.value[widget.category].toSet().toList().sort();
    widget.post.tags.value = Map.from(widget.post.tags.value);
    if (widget.category != 'general') {
      () async {
        for (String tag in tags) {
          List validator = await client.autocomplete(tag);
          String origin;
          if (validator.length == 0) {
            origin = 'general';
          } else if (validator[0]['category'] != categories[widget.category]) {
            origin = categories.keys
                .firstWhere((k) => validator[0]['category'] == categories[k]);
          }
          if (origin != null) {
            widget.post.tags.value[widget.category].remove(tag);
            widget.post.tags.value[origin].add(tag);
            widget.post.tags.value[origin].toSet().toList().sort();
            widget.post.tags.value = Map.from(widget.post.tags.value);
            Scaffold.of(context).showSnackBar(SnackBar(
              duration: Duration(seconds: 1),
              content: Text('Moved $tag to $origin tags'),
              behavior: SnackBarBehavior.floating,
            ));
          }
          await Future.delayed(Duration(milliseconds: 200));
        }
      }();
    }
    widget.onSubmit?.call();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ValueListenableBuilder(
                valueListenable: isLoading,
                builder: (context, value, child) {
                  if (value) {
                    return child;
                  } else {
                    return Container();
                  }
                },
                child: Center(
                    child: Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Container(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator()),
                )),
              ),
              Expanded(
                child: TagInput(
                  labelText: widget.category,
                  onSubmit: (value) => submit(context, value),
                  controller: controller,
                  category: categories[widget.category],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class TagCard extends StatelessWidget {
  final String tag;
  final String category;
  final Function() onRemove;
  final PostProvider provider;

  TagCard({
    @required this.tag,
    @required this.category,
    @required this.provider,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => SearchPage(tags: tag),
        )),
        onLongPress: () =>
            wikiSheet(context: context, tag: tag, provider: provider),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: getCategoryColor(category),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          bottomLeft: Radius.circular(5)),
                    ),
                    child: CrossFade(
                      showChild: onRemove != null,
                      child: InkWell(
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.clear, size: 16),
                        ),
                        onTap: onRemove,
                      ),
                      secondChild: Container(width: 5),
                    ),
                  ),
                )
              ],
            ),
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(top: 4, bottom: 4, right: 8, left: 6),
                child: Text(
                  tag.replaceAll('_', ' '),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
