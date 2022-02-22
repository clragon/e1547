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
        editingController?.value?.description,
        editingController?.editing,
      ],
      builder: (context, child) {
        bool editing = (editingController?.editing ?? false);
        String description =
            editingController?.value?.description ?? post.description;
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
                            content: editingController!.value!.description,
                            onSubmit: (context, text) {
                              editingController!.value =
                                  editingController!.value!.copyWith(
                                description: text,
                              );
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
