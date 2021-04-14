import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ParentDisplay extends StatefulWidget {
  final Post post;
  final Function() onEditorClose;
  final Function(Future<bool> Function() submit) builder;

  ParentDisplay({@required this.post, this.onEditorClose, this.builder});

  @override
  _ParentDisplayState createState() => _ParentDisplayState();
}

class _ParentDisplayState extends State<ParentDisplay> {
  PersistentBottomSheetController sheetController;

  @override
  Widget build(BuildContext context) {
    PersistentBottomSheetController sheetController;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ValueListenableBuilder(
        valueListenable: widget.post.parent,
        builder: (BuildContext context, value, Widget child) {
          return CrossFade(
            showChild: value != null || widget.post.isEditing.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'Parent',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                LoadingTile(
                  leading: Icon(Icons.supervisor_account),
                  title: Text(value?.toString() ?? 'none'),
                  trailing: widget.post.isEditing.value
                      ? Builder(
                          builder: (BuildContext context) {
                            return IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                sheetController =
                                    Scaffold.of(context).showBottomSheet(
                                  (context) {
                                    return ParentEditor(
                                      post: widget.post,
                                      onSubmit: () {
                                        sheetController?.close();
                                      },
                                      builder: widget.builder,
                                    );
                                  },
                                );
                                sheetController.closed.then((_) {
                                  widget.onEditorClose();
                                });
                              },
                            );
                          },
                        )
                      : null,
                  onTap: () async {
                    if (value != null) {
                      Post post = await client.post(value);
                      if (post != null) {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return PostDetail(post: post);
                        }));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: Duration(seconds: 1),
                          content: Text('Coulnd\'t retrieve Post #$value'),
                        ));
                      }
                    }
                  },
                ),
                Divider(),
              ],
            ),
          );
        },
      ),
      CrossFade(
        showChild:
            widget.post.children.isNotEmpty && !widget.post.isEditing.value,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: EdgeInsets.only(
              right: 4,
              left: 4,
              top: 2,
              bottom: 2,
            ),
            child: Text(
              'Children',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          ...widget.post.children.map(
            (child) => LoadingTile(
              leading: Icon(Icons.supervised_user_circle),
              title: Text(child.toString()),
              onTap: () async {
                Post post = await client.post(child);
                if (post != null) {
                  await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => PostDetail(post: post)));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    duration: Duration(seconds: 1),
                    content:
                        Text('Coulnd\'t retrieve Post #${child.toString()}'),
                  ));
                }
              },
            ),
          ),
          Divider(),
        ]),
      ),
    ]);
  }
}

class ParentEditor extends StatefulWidget {
  final Post post;
  final Function() onSubmit;
  final Function(Future<bool> Function() submit) builder;

  ParentEditor({
    @required this.post,
    this.onSubmit,
    this.builder,
  });

  @override
  _ParentEditorState createState() => _ParentEditorState();
}

class _ParentEditorState extends State<ParentEditor> {
  ValueNotifier<bool> isLoading = ValueNotifier(false);
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textController.text = widget.post.parent.value?.toString() ?? ' ';
    setFocusToEnd(textController);
    widget.builder?.call(submit);
  }

  Future<bool> submit() async {
    isLoading.value = true;
    if (textController.text.trim().isEmpty) {
      widget.post.parent.value = null;
      isLoading.value = false;
      widget.onSubmit?.call();
      return true;
    }
    if (int.tryParse(textController.text) != null) {
      Post parent = await client.post(int.tryParse(textController.text));
      if (parent != null) {
        widget.post.parent.value = parent.id;
        widget.onSubmit?.call();
        return true;
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: 1),
      content: Text('Invalid parent post'),
      behavior: SnackBarBehavior.floating,
    ));
    isLoading.value = false;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(
            children: <Widget>[
              ValueListenableBuilder(
                valueListenable: isLoading,
                builder: (context, value, child) {
                  return CrossFade(
                    showChild: value,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: Container(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator()),
                        ),
                      ),
                    ),
                  );
                },
              ),
              Expanded(
                child: TextField(
                  controller: textController,
                  autofocus: true,
                  maxLines: 1,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^ ?\d*')),
                  ],
                  decoration: InputDecoration(
                      labelText: 'Parent ID', border: UnderlineInputBorder()),
                  onSubmitted: (_) => submit(),
                ),
              ),
            ],
          )
        ]));
  }
}
