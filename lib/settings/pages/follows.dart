import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/follow.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:e1547/tag.dart';
import 'package:e1547/wiki.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FollowingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FollowingPageState();
  }
}

class _FollowingPageState extends State<FollowingPage> {
  int editing;
  FollowList follows;
  bool isSearching = false;
  TextEditingController textController = TextEditingController();
  PersistentBottomSheetController<String> sheetController;
  ScrollController scrollController = ScrollController();

  Future<void> update() async {
    await db.follows.value.then((value) {
      if (mounted) {
        setState(() => follows = value);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    db.follows.addListener(update);
    update();
  }

  @override
  void dispose() {
    super.dispose();
    db.follows.removeListener(update);
  }

  @override
  Widget build(BuildContext context) {
    Future<void> addTags(BuildContext context, {int edit}) async {
      setFocusToEnd(textController);
      if (isSearching) {
        if (editing != null) {
          if (textController.text.trim().isNotEmpty) {
            follows[editing] = textController.text.trim();
          } else {
            follows.removeAt(editing);
          }
          sheetController?.close();
        } else {
          if (textController.text.trim().isNotEmpty) {
            follows.add(textController.text.trim());
            sheetController?.close();
          }
        }
      } else {
        if (edit != null) {
          editing = edit;
          textController.text = follows[editing];
        } else {
          textController.text = '';
        }
        sheetController = Scaffold.of(context).showBottomSheet((context) {
          return Container(
            padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TagInput(
                controller: textController,
                labelText: 'Add to follows',
                onSubmit: (_) => addTags(context),
              ),
            ]),
          );
        });
        setState(() {
          isSearching = true;
        });
        sheetController.closed.then((_) {
          setState(() {
            isSearching = false;
            editing = null;
          });
        });
      }
    }

    Widget body() {
      if (follows?.isEmpty ?? true) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bookmark,
                size: 32,
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Text('You are not following any tags'),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        controller: scrollController,
        padding: EdgeInsets.only(top: 8, bottom: 30),
        itemCount: follows.length,
        itemBuilder: (BuildContext context, int index) => FollowListTile(
          follow: follows.data[index],
          onRename: () {},
          onEdit: () => addTags(context, edit: index),
          onDelete: () => follows.remove(follows[index]),
        ),
        physics: BouncingScrollPhysics(),
      );
    }

    Widget floatingActionButton(BuildContext context) {
      return FloatingActionButton(
        child: isSearching ? Icon(Icons.check) : Icon(Icons.add),
        onPressed: () => addTags(context),
      );
    }

    Widget editor() {
      TextEditingController controller = TextEditingController();
      controller.text = follows.join('\n');
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Following'),
          ],
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.multiline,
          maxLines: null,
        ),
        actions: <Widget>[
          TextButton(
            child: Text('CANCEL'),
            onPressed: Navigator.of(context).pop,
          ),
          TextButton(
            child: Text('OK'),
            onPressed: () {
              List<String> tags = controller.text.split('\n');
              tags.removeWhere((tag) => tag.trim().isEmpty);
              tags = tags.map((e) => e.trim()).toList();
              follows.edit(tags);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    }

    return Scaffold(
      appBar: ScrollingAppbarFrame(
        child: AppBar(
          title: Text('Following'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async => showDialog(
                context: context,
                builder: (context) => editor(),
              ),
            ),
          ],
        ),
        controller: scrollController,
      ),
      body: body(),
      floatingActionButton: Builder(
        builder: (context) {
          return floatingActionButton(context);
        },
      ),
    );
  }
}

class FollowListTile extends StatefulWidget {
  final Function onEdit;
  final Function onDelete;
  final Function onRename;
  final Follow follow;

  FollowListTile({
    @required this.follow,
    @required this.onEdit,
    @required this.onDelete,
    @required this.onRename,
  }) : super(key: ObjectKey(follow));

  @override
  _FollowListTileState createState() => _FollowListTileState();
}

class _FollowListTileState extends State<FollowListTile> {
  String thumbnail;

  Future<void> update() async {
    thumbnail = await widget.follow.thumbnail;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    update();
  }

  @override
  Widget build(BuildContext context) {
    Widget cardWidget(String tag) {
      return Card(
        child: TagGesture(
          tag: tag,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Text(tagToTitle(tag)),
              ),
            ],
          ),
        ),
      );
    }

    Widget contextMenu() {
      return PopupMenuButton<String>(
        icon: IconShadow(
          icon: Icon(
            Icons.more_vert,
            color: Theme.of(context).iconTheme.color,
          ),
          shadowColor: Theme.of(context).shadowColor,
        ),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          if (widget.follow.tags.split(' ').length > 1)
            PopupMenuItem(
              value: 'rename',
              child: PopTile(title: 'Rename', icon: Icons.label),
            ),
          PopupMenuItem(
            value: 'edit',
            child: PopTile(title: 'Edit', icon: Icons.edit),
          ),
          PopupMenuItem(
            value: 'delete',
            child: PopTile(title: 'Delete', icon: Icons.delete),
          ),
        ],
        onSelected: (value) async {
          switch (value) {
            case 'rename':
              widget.onRename();
              break;
            case 'edit':
              widget.onEdit();
              break;
            case 'delete':
              widget.onDelete();
              break;
          }
        },
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: thumbnail != null
                    ? Opacity(
                        opacity: 0.8,
                        child: CachedNetworkImage(
                          imageUrl: thumbnail,
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                          fit: BoxFit.cover,
                        ),
                      )
                    : SizedBox.shrink(),
              ),
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          SearchPage(tags: widget.follow.tags))),
                  onLongPress: () => wikiSheet(
                      context: context, tag: tagToName(widget.follow.tags)),
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            widget.follow.title,
                            style: TextStyle(shadows: textShadow),
                          ),
                        ),
                      ],
                    ),
                    subtitle: (widget.follow.tags.split(' ').length > 1)
                        ? Row(children: <Widget>[
                            Expanded(
                              child: Wrap(
                                direction: Axis.horizontal,
                                children: widget.follow.tags
                                    .split(' ')
                                    .map((tag) => cardWidget(tag))
                                    .toList(),
                              ),
                            ),
                          ])
                        : null,
                    trailing: contextMenu(),
                  ),
                ),
              )
            ],
          ),
          Divider()
        ],
      ),
    );
  }
}
