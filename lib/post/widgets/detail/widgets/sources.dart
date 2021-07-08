import 'package:e1547/dtext.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SourceDisplay extends StatelessWidget {
  final Post post;

  SourceDisplay({@required this.post});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: post.sources,
      builder: (BuildContext context, value, Widget child) {
        return CrossFade(
          showChild: value.isNotEmpty || post.isEditing.value,
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
                    showChild: post.isEditing.value,
                    child: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () async {
                        await Navigator.of(context)
                            .push(MaterialPageRoute<String>(builder: (context) {
                          return TextEditor(
                            title: '#${post.id} sources',
                            content: value.join('\n'),
                            richEditor: false,
                            validator: (context, text) async {
                              post.sources.value = text.trim().split('\n');
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
                child: value.join('\n').trim().isNotEmpty
                    ? Wrap(
                        children: value
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
                                  .bodyText1
                                  .color
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
