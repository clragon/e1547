import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class TagDisplay extends StatelessWidget {
  final Post post;
  final PostController? controller;
  final SheetActionController? actionController;
  final PostEditingController? editingController;

  const TagDisplay({
    required this.post,
    required this.controller,
    this.actionController,
    this.editingController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSelector(
      animation: Listenable.merge([editingController]),
      selector: () => [
        editingController?.canEdit,
        editingController?.value?.tags.hashCode,
      ],
      builder: (context, child) {
        bool isEditing =
            (editingController?.editing ?? false) && actionController != null;
        Map<String, List<String>>? tags =
            editingController?.value?.tags ?? post.tags;

        Widget title(String category) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              '${category[0].toUpperCase()}${category.substring(1)}',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          );
        }

        Widget tagCategory(String category) {
          return Wrap(
            direction: Axis.horizontal,
            children: [
              ...tags[category]!.map(
                (tag) => TagCard(
                  tag: tag,
                  category: category,
                  controller: controller,
                  editing: isEditing,
                  onRemove: editingController!.canEdit
                      ? () {
                          Map<String, List<String>> edited =
                              Map.from(editingController!.value!.tags);
                          edited[category]!.remove(tag);
                          editingController!.value =
                              editingController!.value!.copyWith(
                            tags: edited,
                          );
                        }
                      : null,
                ),
              ),
              if (category != 'invalid')
                CrossFade(
                  showChild: isEditing,
                  child: TagAddCard(
                    category: category,
                    submit: editingController!.canEdit
                        ? (value) => onPostTagsEdit(
                              context,
                              editingController!,
                              value,
                              category,
                            )
                        : null,
                    controller: actionController!,
                  ),
                ),
            ],
          );
        }

        Widget categoryTile(String category) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title(category),
              Row(children: [Expanded(child: tagCategory(category))]),
              Divider(),
            ],
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: categories.keys
              .where((category) =>
                  tags[category]!.isNotEmpty ||
                  (isEditing && category != 'invalid'))
              .map((category) => categoryTile(category))
              .toList(),
        );
      },
    );
  }
}

Future<bool> onPostTagsEdit(
  BuildContext context,
  PostEditingController controller,
  String value,
  String category,
) async {
  value = value.trim();
  if (value.isEmpty) {
    return true;
  }
  List<String> edited = value.split(' ');
  Map<String, List<String>> tags = Map.from(controller.value!.tags);
  tags[category]!.addAll(edited);
  tags[category] = tags[category]!.toSet().toList();
  tags[category]!.sort();
  controller.value = controller.value!.copyWith(tags: tags);
  if (category != 'general') {
    () async {
      for (String tag in edited) {
        List validator = await client.tag(tag);
        String? target;
        if (validator.isEmpty) {
          target = 'general';
        } else if (validator[0]['category'] != categories[category]) {
          target = categories.keys
              .firstWhere((k) => validator[0]['category'] == categories[k]);
        }
        if (target != null) {
          Map<String, List<String>> tags = Map.from(controller.value!.tags);
          tags[category]!.remove(tag);
          tags[target]!.add(tag);
          tags[target] = tags[target]!.toSet().toList();
          tags[target]!.sort();
          controller.value = controller.value!.copyWith(tags: tags);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: Duration(milliseconds: 500),
            content: Text('Moved $tag to $target tags'),
            behavior: SnackBarBehavior.floating,
          ));
        }
        await Future.delayed(Duration(milliseconds: 200));
      }
    }();
  }
  return true;
}
