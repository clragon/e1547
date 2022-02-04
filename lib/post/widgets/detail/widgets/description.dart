import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class DescriptionDisplay extends StatelessWidget {
  final Post post;
  final PostEditingController? editingController;

  const DescriptionDisplay({required this.post, this.editingController});

  @override
  Widget build(BuildContext context) {
    return AnimatedSelector(
      animation: Listenable.merge([editingController]),
      selector: () => [
        editingController?.description,
        editingController?.isEditing,
      ],
      builder: (context, child) {
        bool editing = (editingController?.isEditing ?? false);
        String description = editingController?.description ?? post.description;
        return CrossFade(
          showChild: description.isNotEmpty || editing,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CrossFade(
                showChild: editing,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Description',
                      style: TextStyle(fontSize: 16),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TextEditor(
                            title: '#${post.id} description',
                            content: editingController!.description,
                            validate: (context, text) async {
                              editingController!.description = text;
                              return true;
                            },
                          ),
                        ),
                      ),
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
              Divider(),
            ],
          ),
        );
      },
    );
  }
}
