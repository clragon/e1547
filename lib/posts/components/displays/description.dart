import 'package:e1547/dtextfield/dtext_field.dart';
import 'package:e1547/interface/cross_fade.dart';
import 'package:e1547/interface/text_editor.dart';
import 'package:e1547/posts/post.dart';
import 'package:flutter/material.dart';

class DescriptionDisplay extends StatefulWidget {
  final Post post;

  const DescriptionDisplay(this.post);

  @override
  _DescriptionDisplayState createState() => _DescriptionDisplayState();
}

class _DescriptionDisplayState extends State<DescriptionDisplay> {
  @override
  void initState() {
    super.initState();
    widget.post.description.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    widget.post.description.removeListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return CrossFade(
      showChild: widget.post.description.value.isNotEmpty ||
          widget.post.isEditing.value,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CrossFade(
            showChild: widget.post.isEditing.value,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Description',
                  style: TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () async {
                    await Navigator.of(context)
                        .push(MaterialPageRoute<String>(builder: (context) {
                      return TextEditor(
                        title: '#${widget.post.id} description',
                        content: widget.post.description.value,
                        validator: (context, text) {
                          widget.post.description.value = text;
                          return Future.value(true);
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
            children: <Widget>[
              Expanded(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: widget.post.description.value.isNotEmpty
                        ? DTextField(widget.post.description.value)
                        : Text('no description',
                            style: TextStyle(
                                color: Colors.grey[600],
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
  }
}
