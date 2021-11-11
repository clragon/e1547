import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class TagDisplay extends StatelessWidget {
  final Post post;
  final PostController? provider;
  final Future<bool> Function(String value, String category) submit;
  final SheetActionController controller;

  const TagDisplay({
    required this.post,
    required this.provider,
    required this.submit,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
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

    Widget tags(Post post, String category) {
      return Wrap(
        direction: Axis.horizontal,
        children: [
          ...post.tags[category]!.map(
            (tag) => TagCard(
              tag: tag,
              category: category,
              controller: provider,
              onRemove: post.isEditing
                  ? () {
                      post.tags[category]!.remove(tag);
                      post.tags = Map.from(post.tags);
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
      );
    }

    Widget categoryTile(Post post, String category) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title(category),
          Row(children: [
            Expanded(
              child: tags(post, category),
            )
          ]),
          Divider(),
        ],
      );
    }

    return AnimatedSelector(
      animation: post,
      selector: () => [post.tags.hashCode, post.isEditing],
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: categories.keys
              .where((category) =>
                  post.tags[category]!.isNotEmpty ||
                  post.isEditing && category != 'invalid')
              .map((category) => categoryTile(post, category))
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
  post.tags[category]!.addAll(tags);
  post.tags[category]!.toSet().toList().sort();
  post.tags = Map.of(post.tags);
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
          post.tags[category]!.remove(tag);
          post.tags[target]!.add(tag);
          post.tags[target] = post.tags[target]!.toSet().toList();
          post.tags[target]!.sort();
          post.tags = Map.of(post.tags);
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
