import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class DescriptionDisplay extends StatelessWidget {
  final Post post;

  const DescriptionDisplay({required this.post});

  @override
  Widget build(BuildContext context) {
    PostEditingController? editingController = PostEditor.of(context);

    return AnimatedSelector(
      animation: Listenable.merge([editingController]),
      selector: () => [
        editingController?.canEdit,
        editingController?.value?.description,
      ],
      builder: (context, child) {
        bool editing = (editingController?.editing ?? false);
        String description =
            editingController?.value?.description ?? post.description;
        return CrossFade(
          showChild: description.trim().isNotEmpty || editing,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CrossFade(
                showChild: editing,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Description',
                      style: TextStyle(fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: editingController!.canEdit
                          ? () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => DTextEditor(
                                    title: '#${post.id} description',
                                    content:
                                        editingController.value!.description,
                                    onSubmit: (context, text) {
                                      editingController.value =
                                          editingController.value!.copyWith(
                                        description: text,
                                      );
                                      return true;
                                    },
                                  ),
                                ),
                              )
                          : null,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: description.isNotEmpty
                            ? DText(description)
                            : Text(
                                'no description',
                                style: TextStyle(
                                  color: dimTextColor(context),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                      ),
                    ),
                  )
                ],
              ),
              const Divider(),
            ],
          ),
        );
      },
    );
  }
}
