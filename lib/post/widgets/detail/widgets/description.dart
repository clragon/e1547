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

    return HiddenWidget(
      show: description.trim().isNotEmpty || editing,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HiddenWidget(
            show: editing,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'Description',
                    style: TextStyle(fontSize: 16),
                  ),
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
                                onSubmitted: (text) {
                                  editingController.value =
                                      editingController.value!.copyWith(
                                    description: text,
                                  );
                                  return null;
                                },
                                onClosed: Navigator.of(context).maybePop,
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
