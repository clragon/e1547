import 'package:e1547/app/app.dart';
import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SourceDisplay extends StatelessWidget {
  const SourceDisplay({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    PostEditingController? editingController = PostEditor.maybeOf(context);

    return AnimatedSelector(
      animation: Listenable.merge([editingController]),
      selector: () => [
        editingController?.canEdit,
        editingController?.value?.sources,
      ],
      builder: (context, child) {
        bool isEditing = editingController?.editing ?? false;
        List<String> sources =
            editingController?.value?.sources ?? post.sources;
        return CrossFade(
          showChild: sources.isNotEmpty || isEditing,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      'Sources',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  CrossFade(
                    showChild: isEditing,
                    child: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: editingController!.canEdit
                          ? () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => TextEditor(
                                    title: '#${post.id} sources',
                                    content: editingController.value!.sources
                                        .join('\n'),
                                    onSubmit: (context, text) {
                                      editingController.value =
                                          editingController.value!.copyWith(
                                        sources: text.trim().split('\n'),
                                      );
                                      Navigator.of(context).maybePop();
                                      return null;
                                    },
                                  ),
                                ),
                              )
                          : null,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: sources.join('\n').trim().isNotEmpty
                    ? Wrap(
                        children:
                            sources.map((e) => SourceCard(url: e)).toList(),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          'no sources',
                          style: TextStyle(
                            color: dimTextColor(context),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
              ),
              const Divider(),
            ],
          ),
        );
      },
    );
  }
}

class SourceCard extends StatelessWidget {
  final String url;

  const SourceCard({required this.url});

  @override
  Widget build(BuildContext context) {
    if (linkParser.regex.hasMatch(url)) {
      IconData? icon = getHostIcon(url);
      return Card(
        child: InkWell(
          onTap: () => launch(url),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: FaIcon(
                    getHostIcon(url),
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(
                    linkToDisplay(url),
                    style: TextStyle(
                      color: Colors.blue[400],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Card(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Text(url),
              ),
            ),
          ],
        ),
      );
    }
  }
}
