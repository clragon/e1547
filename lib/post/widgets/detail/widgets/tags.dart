import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class TagDisplay extends StatelessWidget {
  const TagDisplay({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    Map<String, List<String>> tags =
        context.select<PostEditingController?, Map<String, List<String>>>(
            (value) => value?.value?.tags ?? post.tags);
    bool editing = context.select<PostEditingController?, bool>(
        (value) => value?.editing ?? false);
    bool canEdit = context.select<PostEditingController?, bool>(
        (value) => value?.canEdit ?? false);
    PostEditingController? editingController =
        context.watch<PostEditingController?>();

    Widget tagCategory(String category) {
      return Wrap(
        children: [
          ...tags[category]!.map(
            (tag) => TagCard(
              tag: tag,
              category: category,
              editing: editing,
              onRemove: canEdit
                  ? () {
                      Map<String, List<String>> edited =
                          Map.from(editingController!.value!.tags);
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
            CrossFade.builder(
              showChild: editing,
              builder: (context) => TagAddCard(
                category: category,
                submit: canEdit
                    ? (value) => onPostTagsEdit(
                          context,
                          editingController!,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              '${category[0].toUpperCase()}${category.substring(1)}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          Row(children: [Expanded(child: tagCategory(category))]),
          const Divider(),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: TagCategory.names
          .where((category) =>
              tags[category]!.isNotEmpty || (editing && category != 'invalid'))
          .map((category) => categoryTile(category))
          .toList(),
    );
  }
}

bool onPostTagsEdit(
  BuildContext context,
  PostEditingController controller,
  String value,
  String category,
) {
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
  final client = context.read<Client>();
  Future<void>(() async {
    for (String tag in edited) {
      List<Tag> tags = await rateLimit(
        client.tags(
          page: 1,
          limit: 1,
          query: QueryMap({'search[name_matches]': tag}),
        ),
        const Duration(milliseconds: 200),
      );
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
      }
    }
  });
  return true;
}
