import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/tag.dart';
import 'package:flutter/material.dart';

class TagDisplay extends StatelessWidget {
  final Post post;
  final PostProvider? provider;
  final Future<bool> Function(String value, String category) submit;
  final SheetActionController? controller;

  TagDisplay({
    required this.post,
    required this.provider,
    required this.submit,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: post,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: categories.keys
              .where((category) =>
                  post.tagMap[category]!.isNotEmpty ||
                  (post.isEditing && category != 'invalid'))
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
                              ...post.tagMap[category]!.map(
                                (tag) => TagCard(
                                  tag: tag,
                                  category: category,
                                  provider: provider,
                                  onRemove: post.isEditing
                                      ? () {
                                          post.tagMap[category]!.remove(tag);
                                          post.notifyListeners();
                                        }
                                      : null,
                                ),
                              ),
                              CrossFade(
                                showChild: post.isEditing,
                                child: TagAddCard(
                                  post: post,
                                  provider: provider,
                                  category: category,
                                  submit: (value) => submit(value, category),
                                  controller: controller,
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
  post.tagMap[category]!.addAll(tags);
  post.tagMap[category]!.toSet().toList().sort();
  post.notifyListeners();
  if (category != 'general') {
    () async {
      for (String tag in tags) {
        List validator = await client.tag(tag);
        String? target;
        if (validator.isEmpty) {
          target = 'general';
        } else if (validator[0]['category'] != categories[category]) {
          target = categories.keys
              .firstWhere((k) => validator[0]['category'] == categories[k]);
        }
        if (target != null) {
          post.tagMap[category]!.remove(tag);
          post.tagMap[target]!.add(tag);
          post.tagMap[target]!.toSet().toList().sort();
          post.notifyListeners();
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
