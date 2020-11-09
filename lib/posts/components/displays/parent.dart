import 'package:e1547/interface/cross_fade.dart';
import 'package:e1547/posts/components/detail.dart';
import 'package:e1547/posts/post.dart';
import 'package:e1547/services/client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ParentDisplay extends StatefulWidget {
  final Post post;
  final void Function() onEdit;

  const ParentDisplay(this.post, this.onEdit);

  @override
  _ParentDisplayState createState() => _ParentDisplayState();
}

class _ParentDisplayState extends State<ParentDisplay> {
  @override
  void initState() {
    super.initState();
    widget.post.parent.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    widget.post.parent.removeListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CrossFade(
        showChild:
            widget.post.parent.value != null || widget.post.isEditing.value,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                right: 4,
                left: 4,
                top: 2,
                bottom: 2,
              ),
              child: Text(
                'Parent',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            loadingListTile(
              leading: Icon(Icons.supervisor_account),
              title: Text(widget.post.parent.value?.toString() ?? 'none'),
              trailing: widget.post.isEditing.value
                  ? Builder(
                      builder: (BuildContext context) {
                        return IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: widget.onEdit,
                        );
                      },
                    )
                  : null,
              onTap: () async {
                if (widget.post.parent.value != null) {
                  Post post = await client.post(widget.post.parent.value);
                  if (post != null) {
                    Navigator.of(context)
                        .push(MaterialPageRoute<Null>(builder: (context) {
                      return PostWidget(post: post);
                    }));
                  } else {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      duration: Duration(seconds: 1),
                      content: Text(
                          'Coulnd\'t retrieve Post #${widget.post.parent.value}'),
                    ));
                  }
                }
              },
            ),
            Divider(),
          ],
        ),
      ),
      CrossFade(
        showChild:
            widget.post.children.length != 0 && !widget.post.isEditing.value,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: () {
              List<Widget> items = [];
              items.add(
                Padding(
                  padding: EdgeInsets.only(
                    right: 4,
                    left: 4,
                    top: 2,
                    bottom: 2,
                  ),
                  child: Text(
                    'Children',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              );
              for (int child in widget.post.children) {
                items.add(loadingListTile(
                  leading: Icon(Icons.supervised_user_circle),
                  title: Text(child.toString()),
                  onTap: () async {
                    Post post = await client.post(child);
                    if (post != null) {
                      await Navigator.of(context)
                          .push(MaterialPageRoute<Null>(builder: (context) {
                        return PostWidget(post: post);
                      }));
                    } else {
                      Scaffold.of(context).showSnackBar(SnackBar(
                        duration: Duration(seconds: 1),
                        content: Text(
                            'Coulnd\'t retrieve Post #${child.toString()}'),
                      ));
                    }
                  },
                ));
              }
              items.add(Divider());
              if (items.length == 0) {
                items.add(Container());
              }
              return items;
            }()),
      ),
    ]);
  }
}

class ParentInput extends StatelessWidget {
  final bool isLoading;
  final Future<void> Function() onSubmit;
  final TextEditingController textController;

  const ParentInput(
      {@required this.textController,
      @required this.onSubmit,
      @required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(
            children: <Widget>[
              CrossFade(
                showChild: isLoading,
                child: Center(
                    child: Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Container(
                      height: 20,
                      width: 20,
                      child: Padding(
                        padding: EdgeInsets.all(2),
                        child: CircularProgressIndicator(),
                      )),
                )),
              ),
              Expanded(
                child: TextField(
                  controller: textController,
                  autofocus: true,
                  maxLines: 1,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^ ?\d*')),
                  ],
                  decoration: InputDecoration(
                      labelText: 'Parent ID', border: UnderlineInputBorder()),
                  onSubmitted: (_) => onSubmit(),
                ),
              ),
            ],
          )
        ]));
  }
}
