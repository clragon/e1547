import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:flutter/material.dart';

class SourceDisplay extends StatefulWidget {
  final Post post;

  const SourceDisplay({@required this.post});

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
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
                        validator: (context, text) async {
                          widget.post.sources.value = text.trim().split('\n');
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
            child: widget.post.sources.value.join('\n').trim().isNotEmpty
                ? DTextField(msg: widget.post.sources.value.join('\n'))
                : Padding(
                    padding: EdgeInsets.all(4),
                    child: Text('no sources',
                        style: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .color
                                .withOpacity(0.35),
                            fontStyle: FontStyle.italic)),
                  ),
          ),
          Divider(),
        ],
      ),
    );
  }
}
