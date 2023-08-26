import 'package:e1547/interface/interface.dart';
import 'package:e1547/markup/markup.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class DescriptionDisplay extends StatelessWidget {
  const DescriptionDisplay({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    String description = context.select<PostEditingController?, String>(
        (value) => value?.value?.description ?? post.description);
    bool editing = context.select<PostEditingController?, bool>(
        (value) => value?.editing ?? false);
    bool canEdit = context.select<PostEditingController?, bool>(
        (value) => value?.canEdit ?? false);

    return CrossFade.builder(
      showChild: description.trim().isNotEmpty || editing,
      builder: (context) => Column(
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
                  onPressed: canEdit
                      ? () {
                          PostEditingController editingController =
                              context.read<PostEditingController>();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => DTextEditor(
                                title: Text('#${post.id} description'),
                                content: description,
                                onSubmit: (context, text) {
                                  editingController.value =
                                      editingController.value!.copyWith(
                                    description: text,
                                  );
                                  Navigator.of(context).maybePop();
                                  return null;
                                },
                              ),
                            ),
                          );
                        }
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
  }
}
