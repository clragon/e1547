import 'package:e1547/app/app.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SourceDisplay extends StatelessWidget {
  const SourceDisplay({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    List<String> sources = context.select<PostEditingController?, List<String>>(
      (value) => value?.value?.sources ?? post.sources,
    );
    bool editing = context.select<PostEditingController?, bool>(
      (value) => value?.editing ?? false,
    );
    bool canEdit = context.select<PostEditingController?, bool>(
      (value) => value?.canEdit ?? false,
    );

    return HiddenWidget(
      show: sources.isNotEmpty || editing,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text('Sources', style: TextStyle(fontSize: 16)),
              ),
              if (editing)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: canEdit
                      ? () {
                          PostEditingController editingController = context
                              .read<PostEditingController>();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => TextEditor(
                                title: Text('#${post.id} sources'),
                                content: editingController.value!.sources.join(
                                  '\n',
                                ),
                                onSubmitted: (text) {
                                  editingController.value = editingController
                                      .value!
                                      .copyWith(
                                        sources: text.trim().split('\n'),
                                      );
                                  return null;
                                },
                                onClosed: Navigator.of(context).maybePop,
                              ),
                            ),
                          );
                        }
                      : null,
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: sources.join('\n').trim().isNotEmpty
                ? Wrap(
                    children: sources.map((e) => SourceCard(url: e)).toList(),
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
  }
}

class SourceCard extends StatelessWidget {
  const SourceCard({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    String url = this.url;
    if (RegExp(r'^-?https?://\S+').hasMatch(url)) {
      bool enabled;
      if (url.startsWith('-')) {
        enabled = false;
        url = url.substring(1);
      } else {
        enabled = true;
      }
      return Card(
        child: InkWell(
          onTap: enabled ? () => launch(url) : null,
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 24),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Center(
                      child: FaIcon(
                        getHostIcon(url) ?? Icons.link,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(indent: 4, endIndent: 4),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      linkToDisplay(url),
                      style: enabled
                          ? TextStyle(color: Colors.blue[400])
                          : const TextStyle(
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                    ),
                  ),
                ),
              ],
            ),
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
