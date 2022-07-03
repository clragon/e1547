import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ParentDisplay extends StatelessWidget {
  final Post post;

  const ParentDisplay({required this.post});

  @override
  Widget build(BuildContext context) {
    PostEditingController? editingController = PostEditor.maybeOf(context);

    return AnimatedSelector(
      animation: Listenable.merge([editingController]),
      selector: () => [
        editingController?.canEdit,
        editingController?.value?.parentId,
      ],
      builder: (context, child) {
        bool isEditing = editingController?.editing ?? false;
        int? parentId =
            editingController?.value?.parentId ?? post.relationships.parentId;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CrossFade(
              showChild: parentId != null || isEditing,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      'Parent',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  LoadingTile(
                    leading: const Icon(Icons.supervisor_account),
                    title: Text(parentId?.toString() ?? 'none'),
                    trailing: isEditing && editingController != null
                        ? IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: editingController.canEdit
                                ? () {
                                    editingController.show(
                                      context,
                                      ParentEditor(
                                        editingController: editingController,
                                      ),
                                    );
                                  }
                                : null,
                          )
                        : null,
                    onTap: () async {
                      if (parentId != null) {
                        try {
                          PostsController controller =
                              PostsController.single(parentId);
                          await controller.loadFirstPage();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PostDetailGallery(
                                controller: controller,
                              ),
                            ),
                          );
                        } on DioError {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 1),
                              content:
                                  Text('Coulnd\'t retrieve Post #$parentId'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const Divider(),
                ],
              ),
            ),
            CrossFade(
              showChild: post.relationships.children.isNotEmpty &&
                  post.relationships.hasActiveChildren &&
                  !isEditing,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
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
                      leading: const Icon(Icons.supervised_user_circle),
                      title: Text(child.toString()),
                      onTap: () async {
                        try {
                          PostsController controller =
                              PostsController.single(child);
                          await controller.loadFirstPage();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PostDetailGallery(
                                controller: controller,
                              ),
                            ),
                          );
                        } on DioError {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            duration: const Duration(seconds: 1),
                            content: Text(
                                'Coulnd\'t retrieve Post #${child.toString()}'),
                          ));
                        }
                      },
                    ),
                  ),
                  const Divider(),
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
  final PostEditingController editingController;

  const ParentEditor({required this.editingController});

  @override
  State<ParentEditor> createState() => _ParentEditorState();
}

class _ParentEditorState extends State<ParentEditor> {
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textController.text =
        widget.editingController.value?.parentId?.toString() ?? ' ';
    textController.setFocusToEnd();
    widget.editingController.setAction(submit);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 1),
      content: Text(message),
      behavior: SnackBarBehavior.floating,
    ));
    throw ActionControllerException(message: message);
  }

  Future<void> submit() async {
    if (textController.text.trim().isEmpty) {
      PostEdit previous = widget.editingController.value!;
      widget.editingController.value = PostEdit(
        editReason: previous.editReason,
        rating: previous.rating,
        description: previous.description,
        parentId: null,
        sources: previous.sources,
        tags: previous.tags,
      );
      return;
    }
    try {
      Post parent = await client.post(int.parse(textController.text));
      widget.editingController.value = widget.editingController.value!.copyWith(
        parentId: parent.id,
      );
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
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^ ?\d*')),
      ],
      decoration: const InputDecoration(labelText: 'Parent ID'),
      onSubmitted: (_) => widget.editingController.action!(),
      readOnly: widget.editingController.isLoading,
    );
  }
}
