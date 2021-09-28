import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SourceDisplay extends StatelessWidget {
  final Post post;

  SourceDisplay({required this.post});

  @override
  Widget build(BuildContext context) {
    return AnimatedSelector(
      animation: post,
      selector: () => [post.sources, post.isEditing],
      builder: (context, child) {
        return CrossFade(
          showChild: post.sources.isNotEmpty || post.isEditing,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      'Sources',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  CrossFade(
                    showChild: post.isEditing,
                    child: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () async {
                        await Navigator.of(context)
                            .push(MaterialPageRoute<String>(builder: (context) {
                          return TextEditor(
                            title: '#${post.id} sources',
                            content: post.sources.join('\n'),
                            richEditor: false,
                            validator: (context, text) async {
                              post.sources = text.trim().split('\n');
                              post.notifyListeners();
                              return true;
                            },
                          );
                        }));
                      },
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: post.sources.join('\n').trim().isNotEmpty
                    ? Wrap(
                        children: post.sources
                            .map<Widget>(
                              (e) => Card(
                                child: InkWell(
                                  onTap: () => launch(e),
                                  child: Padding(
                                    padding: EdgeInsets.all(6),
                                    child: Text(
                                      linkToDisplay(e),
                                      style: TextStyle(
                                        color: Colors.blue[400],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      )
                    : Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          'no sources',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .color!
                                  .withOpacity(0.35),
                              fontStyle: FontStyle.italic),
                        ),
                      ),
              ),
              Divider(),
            ],
          ),
        );
      },
    );
  }
}
