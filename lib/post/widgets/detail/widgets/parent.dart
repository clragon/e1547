import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ParentDisplay extends StatefulWidget {
  final Post post;
  final SheetActionController controller;

  const ParentDisplay({required this.post, required this.controller});

  @override
  _ParentDisplayState createState() => _ParentDisplayState();
}

class _ParentDisplayState extends State<ParentDisplay> {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AnimatedSelector(
        animation: widget.post,
        selector: () => [
          widget.post.relationships.parentId,
          widget.post.isEditing,
        ],
        builder: (context, child) {
          return CrossFade(
            showChild: widget.post.relationships.parentId != null ||
                widget.post.isEditing,
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
                  title: Text(
                      widget.post.relationships.parentId?.toString() ?? 'none'),
                  trailing: widget.post.isEditing
                      ? Builder(
                          builder: (BuildContext context) {
                            return IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                widget.controller.show(
                                  context,
                                  ParentEditor(
                                    post: widget.post,
                                    controller: widget.controller,
                                  ),
                                );
                              },
                            );
                          },
                        )
                      : null,
                  onTap: () async {
                    if (widget.post.relationships.parentId != null) {
                      try {
                        Post post = await client
                            .post(widget.post.relationships.parentId!);
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return PostDetail(post: post);
                        }));
                      } on DioError {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: Duration(seconds: 1),
                          content: Text(
                              'Coulnd\'t retrieve Post #${widget.post.relationships.parentId}'),
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
        showChild: widget.post.relationships.children.isNotEmpty &&
            !widget.post.isEditing,
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
          ...widget.post.relationships.children.map(
            (child) => LoadingTile(
              leading: Icon(Icons.supervised_user_circle),
              title: Text(child.toString()),
              onTap: () async {
                try {
                  Post post = await client.post(child);
                  await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => PostDetail(post: post)));
                } on DioError {
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
  final ActionController controller;

  const ParentEditor({
    required this.post,
    required this.controller,
  });

  @override
  _ParentEditorState createState() => _ParentEditorState();
}

class _ParentEditorState extends State<ParentEditor> {
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textController.text = widget.post.relationships.parentId?.toString() ?? ' ';
    setFocusToEnd(textController);
    widget.controller.setAction(submit);
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: 1),
      content: Text(message),
      behavior: SnackBarBehavior.floating,
    ));
    throw ControllerException(message: message);
  }

  Future<void> submit() async {
    if (textController.text.trim().isEmpty) {
      widget.post.relationships.parentId = null;
      widget.post.notifyListeners();
      return;
    }
    try {
      if (int.tryParse(textController.text) != null) {
        Post parent = await client.post(int.parse(textController.text));
        widget.post.relationships.parentId = parent.id;
        widget.post.notifyListeners();
        return;
      }
    } on DioError {
      showError('Invalid parent post');
    } on FormatException {
      showError('Invalid input');
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textController,
      autofocus: true,
      maxLines: 1,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^ ?\d*')),
      ],
      decoration: InputDecoration(labelText: 'Parent ID'),
      onSubmitted: (_) => widget.controller.action!(),
      enabled: !widget.controller.isLoading,
    );
  }
}
