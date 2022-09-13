import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class PostDetailFloatingActionButton extends StatelessWidget {
  const PostDetailFloatingActionButton({super.key, required this.controller});

  final PostController controller;

  Post get post => controller.value;

  set post(Post value) => controller.value = value;

  @override
  Widget build(BuildContext context) {
    PostEditingController editingController =
        context.watch<PostEditingController>();

    Future<void> editPost() async {
      editingController.setLoading(true);
      Map<String, String?>? body = editingController.value?.toForm();
      if (body != null) {
        try {
          await context
              .read<Client>()
              .updatePost(editingController.post.id, body);
          post = post.copyWith(tags: editingController.value!.tags);
          await controller.reset();
          editingController.stopEditing();
        } on DioError {
          editingController.setLoading(false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 1),
              content: Text('failed to edit Post #${post.id}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          throw ActionControllerException(
              message: 'failed to edit Post #${post.id}');
        }
      }
    }

    Future<void> submitEdit() async {
      editingController.show(
        context,
        ControlledTextField(
          actionController: editingController,
          labelText: 'Reason',
          submit: (value) async {
            editingController.value =
                editingController.value!.copyWith(editReason: value);
            return editPost();
          },
        ),
      );
    }

    return FloatingActionButton(
      heroTag: null,
      clipBehavior: Clip.antiAlias,
      backgroundColor: Theme.of(context).cardColor,
      foregroundColor: Theme.of(context).iconTheme.color,
      onPressed: editingController.editing
          ? editingController.action ?? submitEdit
          : () {},
      child: editingController.editing
          ? Icon(editingController.isShown ? Icons.add : Icons.check)
          : Padding(
              padding: const EdgeInsets.only(left: 2),
              child: FavoriteButton(controller: controller),
            ),
    );
  }
}
