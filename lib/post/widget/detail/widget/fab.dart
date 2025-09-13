import 'package:e1547/domain/domain.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class PostDetailFloatingActionButton extends StatelessWidget {
  const PostDetailFloatingActionButton({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    PostEditingController editingController = context
        .watch<PostEditingController>();
    final domain = context.watch<Domain>();

    Future<void> editPost() async {
      ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
      editingController.setLoading(true);
      Map<String, String?>? body = editingController.value?.toForm();
      if (body != null) {
        try {
          await domain.posts.update(id: post.id, data: body);
          editingController.stopEditing();
        } on ClientException {
          editingController.setLoading(false);
          messenger.showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 1),
              content: Text('failed to edit Post #${post.id}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          throw ActionControllerException(
            message: 'failed to edit Post #${post.id}',
          );
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
            editingController.value = editingController.value!.copyWith(
              editReason: value,
            );
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
              child: FavoriteButton(post: post),
            ),
    );
  }
}
