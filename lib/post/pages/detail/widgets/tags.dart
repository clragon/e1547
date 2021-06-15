import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/tag.dart';
import 'package:flutter/material.dart';

class TagDisplay extends StatelessWidget {
  final Post post;
  final PostProvider provider;
  final Future<bool> Function(String value, String category) onEditorSubmit;
  final Function(Future<bool> Function() submit) onEditorBuild;
  final Function onEditorClose;

  TagDisplay({
    @required this.post,
    @required this.provider,
    @required this.onEditorSubmit,
    this.onEditorClose,
    this.onEditorBuild,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: post.tags,
      builder: (BuildContext context, value, Widget child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: categories.keys
              .where((tagSet) =>
                  value[tagSet].isNotEmpty ||
                  (post.isEditing.value && tagSet != 'invalid'))
              .map(
                (category) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text(
                        '${category[0].toUpperCase()}${category.substring(1)}',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            direction: Axis.horizontal,
                            children: [
                              ...value[category].map(
                                (tag) => TagCard(
                                  tag: tag,
                                  category: category,
                                  provider: provider,
                                  onRemove: post.isEditing.value
                                      ? () {
                                          post.tags.value[category].remove(tag);
                                          post.tags.value = Map.from(value);
                                        }
                                      : null,
                                ),
                              ),
                              CrossFade(
                                showChild: post.isEditing.value,
                                child: TagAddCard(
                                  post: post,
                                  provider: provider,
                                  category: category,
                                  onEditorSubmit: (value) =>
                                      onEditorSubmit(value, category),
                                  onEditorBuild: onEditorBuild,
                                  onEditorClose: onEditorClose,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Divider(),
                  ],
                ),
              )
              .toList(),
        );
      },
    );
  }
}

Future<bool> onPostTagsEdit(
  BuildContext context,
  Post post,
  String value,
  String category,
) async {
  value = value.trim();
  if (value.isEmpty) {
    return true;
  }
  List<String> tags = value.split(' ');
  post.tags.value[category].addAll(tags);
  post.tags.value[category].toSet().toList().sort();
  post.tags.value = Map.from(post.tags.value);
  if (category != 'general') {
    () async {
      for (String tag in tags) {
        List validator = await client.autocomplete(tag);
        String target;
        if (validator.isEmpty) {
          target = 'general';
        } else if (validator[0]['category'] != categories[category]) {
          target = categories.keys
              .firstWhere((k) => validator[0]['category'] == categories[k]);
        }
        if (target != null) {
          post.tags.value[category].remove(tag);
          post.tags.value[target].add(tag);
          post.tags.value[target].toSet().toList().sort();
          post.tags.value = Map.from(post.tags.value);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: Duration(seconds: 1),
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
