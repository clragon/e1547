import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class TagDisplay extends StatelessWidget {
  const TagDisplay({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    PostEditingController? editingController =
        context.watch<PostEditingController?>();

    return AnimatedSelector(
      animation: Listenable.merge([editingController]),
      selector: () => [
        editingController?.canEdit,
        editingController?.value?.tags.hashCode,
      ],
      builder: (context, child) {
        bool isEditing = (editingController?.editing ?? false);
        Map<String, List<String>>? tags =
            editingController?.value?.tags ?? post.tags;

        Widget title(String category) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              '${category[0].toUpperCase()}${category.substring(1)}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          );
        }

        Widget tagCategory(String category) {
          return Wrap(
            children: [
              ...tags[category]!.map(
                (tag) => TagCard(
                  tag: tag,
                  category: category,
                  editing: isEditing,
                  onRemove: editingController!.canEdit
                      ? () {
                          Map<String, List<String>> edited =
                              Map.from(editingController.value!.tags);
                          edited[category]!.remove(tag);
                          editingController.value =
                              editingController.value!.copyWith(
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
                              editingController,
                              value,
                              category,
                            )
                        : null,
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
              const Divider(),
            ],
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: TagCategory.names
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
    Future(() async {
      for (String tag in edited) {
        List<Tag> tags = await context.read<Client>().tags(tag);
        String? target;
        if (tags.isEmpty) {
          target = 'general';
        } else if (tags.first.name == tag &&
            tags.first.category != TagCategory.byName(category).id) {
          target = TagCategory.byId(tags.first.category).name;
        }
        if (target != null) {
          Map<String, List<String>> tags = Map.from(controller.value!.tags);
          tags[category]!.remove(tag);
          tags[target]!.add(tag);
          tags[target] = tags[target]!.toSet().toList();
          tags[target]!.sort();
          controller.value = controller.value!.copyWith(tags: tags);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(milliseconds: 500),
            content: Text('Moved $tag to $target tags'),
            behavior: SnackBarBehavior.floating,
          ));
        }
        await Future.delayed(const Duration(milliseconds: 200));
      }
    });
  }
  return true;
}
