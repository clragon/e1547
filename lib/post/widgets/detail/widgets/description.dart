import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class DescriptionDisplay extends StatelessWidget {
  final Post post;

  const DescriptionDisplay({required this.post});

  @override
  Widget build(BuildContext context) {
    return AnimatedSelector(
      animation: post,
      selector: () => [post.description, post.isEditing],
      builder: (context, child) {
        return CrossFade(
          showChild: post.description.isNotEmpty || post.isEditing,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CrossFade(
                showChild: post.isEditing,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Description',
                      style: TextStyle(fontSize: 16),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return TextEditor(
                                title: '#${post.id} description',
                                content: post.description,
                                validate: (context, text) async {
                                  post.description = text;
                                  post.notifyListeners();
                                  return true;
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: post.description.isNotEmpty
                            ? DText(post.description)
                            : Text(
                                'no description',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText2!
                                        .color!
                                        .withOpacity(0.35),
                                    fontStyle: FontStyle.italic),
                              ),
                      ),
                    ),
                  )
                ],
              ),
              Divider(),
            ],
          ),
        );
      },
    );
  }
}
