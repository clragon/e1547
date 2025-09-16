import 'package:e1547/client/client.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sub/flutter_sub.dart';

class RelationshipDisplay extends StatelessWidget {
  const RelationshipDisplay({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    int? parentId = context.select<PostEditingController?, int?>(
      (value) => value?.value?.parentId ?? post.relationships.parentId,
    );
    bool editing = context.select<PostEditingController?, bool>(
      (value) => value?.editing ?? false,
    );
    bool canEdit = context.select<PostEditingController?, bool>(
      (value) => value?.canEdit ?? false,
    );

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
                child: Text('Parent', style: TextStyle(fontSize: 16)),
              ),
              ListTile(
                leading: const Icon(Icons.supervisor_account),
                title: Text(parentId?.toString() ?? 'none'),
                trailing: editing
                    ? IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: canEdit
                            ? () {
                                PostEditingController controller = context
                                    .read<PostEditingController>();
                                controller.show(
                                  context,
                                  ParentEditor(editingController: controller),
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
          show:
              post.relationships.children.isNotEmpty &&
              (post.relationships.hasActiveChildren ?? true) &&
              !editing,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text('Children', style: TextStyle(fontSize: 16)),
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

class ParentEditor extends StatelessWidget {
  const ParentEditor({super.key, required this.editingController});

  final PostEditingController editingController;

  @override
  Widget build(BuildContext context) {
    return SubTextEditingController(
      text: editingController.value?.parentId?.toString(),
      builder: (context, textController) => SubEffect(
        effect: () {
          textController.setFocusToEnd();
          return null;
        },
        child: ControlledTextField(
          actionController: editingController,
          submit: (value) async {
            if (value.trim().isEmpty) {
              PostEdit previous = editingController.value!;
              editingController.value = PostEdit(
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
              Post parent = await context.read<Client>().posts.get(
                id: int.parse(value),
              );
              editingController.value = editingController.value!.copyWith(
                parentId: parent.id,
              );
            } on ClientException {
              throw const ActionControllerException(
                message: 'Invalid parent post',
              );
            } on FormatException {
              throw const ActionControllerException(message: 'Invalid input');
            }
          },
          textController: TextEditingController(
            text: editingController.value?.parentId?.toString(),
          ),
          labelText: 'Parent ID',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^ ?\d*')),
          ],
        ),
      ),
    );
  }
}
