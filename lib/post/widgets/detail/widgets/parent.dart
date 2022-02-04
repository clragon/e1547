import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ParentDisplay extends StatelessWidget {
  final Post post;
  final SheetActionController? actionController;
  final PostEditingController? editingController;

  const ParentDisplay(
      {required this.post, this.actionController, this.editingController});

  @override
  Widget build(BuildContext context) {
    return AnimatedSelector(
      animation: Listenable.merge([editingController]),
      selector: () => [
        editingController?.isEditing,
        editingController?.parentId,
      ],
      builder: (context, child) {
        bool isEditing = editingController?.isEditing ?? false;
        int? parentId =
            editingController?.parentId ?? post.relationships.parentId;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CrossFade(
              showChild: parentId != null || isEditing,
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
                    title: Text(parentId?.toString() ?? 'none'),
                    trailing: isEditing && actionController != null
                        ? Builder(
                            builder: (context) => IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                actionController!.show(
                                  context,
                                  ParentEditor(
                                    actionController: actionController!,
                                    editingController: editingController!,
                                  ),
                                );
                              },
                            ),
                          )
                        : null,
                    onTap: () async {
                      if (parentId != null) {
                        try {
                          Post post = await client.post(parentId);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PostDetail(post: post),
                            ),
                          );
                        } on DioError {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: Duration(seconds: 1),
                              content:
                                  Text('Coulnd\'t retrieve Post #$parentId'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  Divider(),
                ],
              ),
            ),
            CrossFade(
              showChild: post.relationships.children.isNotEmpty && !isEditing,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    child: Text(
                      'Children',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  ...post.relationships.children.map(
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
                            content: Text(
                                'Coulnd\'t retrieve Post #${child.toString()}'),
                          ));
                        }
                      },
                    ),
                  ),
                  Divider(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class ParentEditor extends StatefulWidget {
  final ActionController actionController;
  final PostEditingController editingController;

  const ParentEditor({
    required this.actionController,
    required this.editingController,
  });

  @override
  _ParentEditorState createState() => _ParentEditorState();
}

class _ParentEditorState extends State<ParentEditor> {
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textController.text = widget.editingController.parentId?.toString() ?? ' ';
    setFocusToEnd(textController);
    widget.actionController.setAction(submit);
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: 1),
      content: Text(message),
      behavior: SnackBarBehavior.floating,
    ));
    throw ActionControllerException(message: message);
  }

  Future<void> submit() async {
    if (textController.text.trim().isEmpty) {
      widget.editingController.parentId = null;
      return;
    }
    try {
      Post parent = await client.post(int.parse(textController.text));
      widget.editingController.parentId = parent.id;
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
      onSubmitted: (_) => widget.actionController.action!(),
      readOnly: widget.actionController.isLoading,
    );
  }
}
