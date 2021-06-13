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
  List<Follow> follows;
  Function fabAction;
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

  Widget tagEditor({
    TextEditingController controller,
    @required Function(String value) onSubmit,
  }) {
    controller ??= TextEditingController();
    setFocusToEnd(controller);

    return Padding(
      padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        TagInput(
          controller: controller,
          labelText: 'Add to follows',
          onSubmit: onSubmit,
        ),
      ]),
    );
  }

  Widget aliasEditor({
    TextEditingController controller,
    @required Function(String value) onSubmit,
  }) {
    controller ??= TextEditingController();
    setFocusToEnd(controller);

    return Padding(
      padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(
          controller: controller,
          autofocus: true,
          maxLines: 1,
          decoration: InputDecoration(
            labelText: 'Follow Alias',
          ),
          onSubmitted: onSubmit,
        )
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    void addTags(BuildContext context, [int edit]) {
      void submit(String value, {int edit}) {
        value = value.trim();
        Follow result = Follow.fromString(value);

        if (edit != null) {
          if (value.isNotEmpty) {
            follows[edit] = result;
          } else {
            follows.removeAt(edit);
          }
          db.follows.value = Future.value(follows);
          sheetController?.close();
        } else {
          if (value.isNotEmpty) {
            follows.add(result);
            db.follows.value = Future.value(follows);
            sheetController?.close();
          }
        }
      }

      TextEditingController controller =
          TextEditingController(text: edit != null ? follows[edit].tags : null);

      sheetController = Scaffold.of(context).showBottomSheet((context) {
        return tagEditor(
          controller: controller,
          onSubmit: (value) => submit(value, edit: edit),
        );
      });

      setState(() {
        fabAction = () => submit(controller.text, edit: edit);
      });

      sheetController.closed.then((_) {
        setState(() {
          fabAction = null;
        });
      });
    }

    void editAlias(BuildContext context, int edit) {
      void submit(String value, int edit) {
        value = value.trim();
        if (follows[edit].alias != value) {
          if (value.isNotEmpty) {
            follows[edit].alias = value;
          } else {
            follows[edit].alias = null;
          }
          db.follows.value = Future.value(follows);
          sheetController?.close();
        }
      }

      TextEditingController controller =
          TextEditingController(text: follows[edit].title);

      sheetController = Scaffold.of(context).showBottomSheet((context) {
        return aliasEditor(
          controller: controller,
          onSubmit: (value) => submit(value, edit),
        );
      });

      setState(() {
        fabAction = () => submit(controller.text, edit);
      });

      sheetController.closed.then((_) {
        setState(() {
          fabAction = null;
        });
      });
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
          follow: follows[index],
          onRename: () => editAlias(context, index),
          onEdit: () => addTags(context, index),
          onDelete: () {
            follows.removeAt(index);
            db.follows.value = Future.value(follows);
          },
        ),
        physics: BouncingScrollPhysics(),
      );
    }

    Widget floatingActionButton(BuildContext context) {
      return FloatingActionButton(
        child: fabAction != null ? Icon(Icons.check) : Icon(Icons.add),
        onPressed: () => fabAction != null ? fabAction() : addTags(context),
      );
    }

    Widget editor() {
      TextEditingController controller = TextEditingController();
      controller.text = follows.tags.join('\n');
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Following'),
          ],
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.multiline,
          maxLines: null,
        ),
        actions: [
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
              db.follows.value = follows.editWith(tags);
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
          actions: [
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
            children: [
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
        children: [
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
                            style: thumbnail != null
                                ? TextStyle(shadows: getTextShadows())
                                : null,
                          ),
                        ),
                      ],
                    ),
                    subtitle: (widget.follow.tags.split(' ').length > 1)
                        ? Row(children: [
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
