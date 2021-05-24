import 'package:e1547/post.dart';
import 'package:e1547/tag.dart';
import 'package:flutter/material.dart';

class TagAddCard extends StatefulWidget {
  final Post post;
  final String category;
  final PostProvider provider;
  final Future<bool> Function(String value) onEditorSubmit;
  final Function(Future<bool> Function() submit) onEditorBuild;
  final Function onEditorClose;

  TagAddCard({
    @required this.post,
    @required this.provider,
    @required this.onEditorSubmit,
    this.category,
    this.onEditorBuild,
    this.onEditorClose,
  });

  @override
  _TagAddCardState createState() => _TagAddCardState();
}

class _TagAddCardState extends State<TagAddCard> {
  PersistentBottomSheetController sheetController;

  @override
  void dispose() {
    super.dispose();
    sheetController?.close();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Builder(
        builder: (BuildContext context) {
          return InkWell(
            child: Padding(
              padding: EdgeInsets.all(5),
              child: Icon(Icons.add, size: 16),
            ),
            onTap: () async {
              sheetController = Scaffold.of(context).showBottomSheet(
                (context) => TagEditor(
                  post: widget.post,
                  category: widget.category,
                  onSubmit: (value) async {
                    bool success = await widget.onEditorSubmit(value);
                    if (success) {
                      sheetController.close();
                    }
                    return success;
                  },
                  onBuild: widget.onEditorBuild,
                ),
              );
              sheetController.closed.then((_) => widget?.onEditorClose());
            },
          );
        },
      ),
    );
  }
}
