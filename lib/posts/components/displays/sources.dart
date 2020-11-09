import 'package:e1547/dtextfield/dtext_field.dart';
import 'package:e1547/interface/cross_fade.dart';
import 'package:e1547/interface/text_editor.dart';
import 'package:e1547/posts/post.dart';
import 'package:flutter/material.dart';

class SourceDisplay extends StatefulWidget {
  final Post post;

  const SourceDisplay(this.post);

  @override
  _SourceDisplayState createState() => _SourceDisplayState();
}

class _SourceDisplayState extends State<SourceDisplay> {
  @override
  void initState() {
    super.initState();
    widget.post.sources.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    widget.post.sources.removeListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return CrossFade(
      showChild:
          widget.post.sources.value.length != 0 || widget.post.isEditing.value,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  right: 4,
                  left: 4,
                  top: 2,
                  bottom: 2,
                ),
                child: Text(
                  'Sources',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              CrossFade(
                showChild: widget.post.isEditing.value,
                child: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () async {
                    await Navigator.of(context)
                        .push(MaterialPageRoute<String>(builder: (context) {
                      return TextEditor(
                        title: '#${widget.post.id} sources',
                        content: widget.post.sources.value.join('\n'),
                        richEditor: false,
                        validator: (context, text) {
                          widget.post.sources.value = text.trim().split('\n');
                          return Future.value(true);
                        },
                      );
                    }));
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              right: 4,
              left: 4,
              top: 2,
              bottom: 2,
            ),
            child: widget.post.sources.value.join('\n').trim().isNotEmpty
                ? DTextField(widget.post.sources.value.join('\n'))
                : Padding(
                    padding: EdgeInsets.all(4),
                    child: Text('no sources',
                        style: TextStyle(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic)),
                  ),
          ),
          Divider(),
        ],
      ),
    );
  }
}
