import 'package:e1547/dtext.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:flutter/material.dart';

class DescriptionDisplay extends StatelessWidget {
  final Post post;

  DescriptionDisplay({@required this.post});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: post.description,
        builder: (context, value, child) {
          return CrossFade(
            showChild: value.isNotEmpty || post.isEditing.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CrossFade(
                  showChild: post.isEditing.value,
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
                              MaterialPageRoute<String>(builder: (context) {
                            return TextEditor(
                              title: '#${post.id} description',
                              content: value,
                              validator: (context, text) async {
                                post.description.value = text;
                                return true;
                              },
                            );
                          }));
                        },
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: value.isNotEmpty
                              ? DTextField(source: value)
                              : Text('no description',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          .color
                                          .withOpacity(0.35),
                                      fontStyle: FontStyle.italic)),
                        ),
                      ),
                    )
                  ],
                ),
                Divider(),
              ],
            ),
          );
        });
  }
}
