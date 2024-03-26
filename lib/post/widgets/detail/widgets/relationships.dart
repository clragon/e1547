import 'package:e1547/client/client.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RelationshipDisplay extends StatelessWidget {
  const RelationshipDisplay({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    int? parentId = context.select<PostEditingController?, int?>(
        (value) => value?.value?.parentId ?? post.relationships.parentId);
    bool editing = context.select<PostEditingController?, bool>(
        (value) => value?.editing ?? false);
    bool canEdit = context.select<PostEditingController?, bool>(
        (value) => value?.canEdit ?? false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HiddenWidget(
          show: parentId != null || editing,
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
              ListTile(
                leading: const Icon(Icons.supervisor_account),
                title: Text(parentId?.toString() ?? 'none'),
                trailing: editing
                    ? IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: canEdit
                            ? () {
                                PostEditingController controller =
                                    context.read<PostEditingController>();
                                controller.show(
                                  context,
                                  ParentEditor(
                                    editingController: controller,
                                  ),
                                );
                              }
                            : null,
                      )
                    : const Icon(Icons.arrow_right),
                onTap: parentId != null
                    ? () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PostLoadingPage(parentId),
                          ),
                        )
                    : null,
              ),
              const Divider(),
            ],
          ),
        ),
        HiddenWidget(
          show: post.relationships.children.isNotEmpty &&
              post.relationships.hasActiveChildren &&
              !editing,
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
                (child) => ListTile(
                  leading: const Icon(Icons.supervised_user_circle),
                  title: Text(child.toString()),
                  trailing: const Icon(Icons.arrow_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PostLoadingPage(child),
                    ),
                  ),
                ),
              ),
              const Divider(),
            ],
          ),
        ),
      ],
    );
  }
}

class ParentEditor extends StatefulWidget {
  const ParentEditor({super.key, required this.editingController});

  final PostEditingController editingController;

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
        post: previous.post,
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
      Post parent = await context
          .read<Client>()
          .posts
          .get(id: int.parse(textController.text));
      widget.editingController.value = widget.editingController.value!.copyWith(
        parentId: parent.id,
      );
    } on ClientException {
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
