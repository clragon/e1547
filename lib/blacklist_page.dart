import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'client.dart';
import 'interface.dart';
import 'persistence.dart' show db;

class BlacklistPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BlacklistPageState();
  }
}

class _BlacklistPageState extends State<BlacklistPage> {
  int _editing;
  bool _isSearching = false;
  List<String> _blacklist = [];
  TextEditingController _tagController = TextEditingController();
  PersistentBottomSheetController<String> _bottomSheetController;

  @override
  void initState() {
    super.initState();
    db.blacklist.addListener(() async {
      List<String> blacklist = await db.blacklist.value;
      setState(() => _blacklist = blacklist);
    });
    db.blacklist.value.then((a) async => setState(() => _blacklist = a));
  }

  Function() _addTags(BuildContext context, {int edit}) {
    return () async {
      setFocusToEnd(_tagController);
      if (_isSearching) {
        if (_editing != null) {
          if (_tagController.text.trim().isNotEmpty) {
            _blacklist[_editing] = _tagController.text;
          } else {
            _blacklist.removeAt(_editing);
          }
          db.blacklist.value = Future.value(_blacklist);
          _bottomSheetController?.close();
        } else {
          if (_tagController.text.trim().isNotEmpty) {
            _blacklist.add(_tagController.text);
            db.blacklist.value = Future.value(_blacklist);
            _bottomSheetController?.close();
          }
        }
      } else {
        if (edit != null) {
          _editing = edit;
          _tagController.text = _blacklist[_editing];
        } else {
          _tagController.text = '';
        }
        _bottomSheetController =
            Scaffold.of(context).showBottomSheet((context) => Container(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    TypeAheadField(
                      direction: AxisDirection.up,
                      hideOnLoading: true,
                      hideOnEmpty: true,
                      hideOnError: true,
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: _tagController,
                        autofocus: true,
                        maxLines: 1,
                        inputFormatters: [LowercaseTextInputFormatter()],
                        decoration: InputDecoration(
                            labelText: 'Add to blacklist',
                            border: UnderlineInputBorder()),
                      ),
                      onSuggestionSelected: (suggestion) {
                        List<String> tags = _tagController.text.split(' ');
                        List<String> before = [];
                        for (String tag in tags) {
                          before.add(tag);
                          if (before.join(' ').length >=
                              _tagController.selection.extent.offset) {
                            String operator = tags[tags.indexOf(tag)][0];
                            if (operator != '-' && operator != '~') {
                              operator = '';
                            }
                            tags[tags.indexOf(tag)] = operator + suggestion;
                            break;
                          }
                        }
                        _tagController.text = tags.join(' ');
                      },
                      itemBuilder: (BuildContext context, itemData) {
                        return ListTile(
                          title: Text(itemData),
                        );
                      },
                      suggestionsCallback: (String pattern) async {
                        List<String> tags = _tagController.text.split(' ');
                        List<String> before = [];
                        int selection = 0;
                        for (String tag in tags) {
                          before.add(tag);
                          if (before.join(' ').length >=
                              _tagController.selection.extent.offset) {
                            selection = tags.indexOf(tag);
                            break;
                          }
                        }
                        if (noDash(tags[selection].trim()).isNotEmpty) {
                          return (await client.tags(noDash(tags[selection])))
                              .map((t) => t['name'])
                              .toList();
                        } else {
                          return [];
                        }
                      },
                    ),
                  ]),
                ));
        setState(() {
          _isSearching = true;
        });
        _bottomSheetController.closed.then((a) {
          setState(() {
            _isSearching = false;
            _editing = null;
          });
        });
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    Widget cardWidget(String tag) {
      return Card(
          child: InkWell(
              onTap: () => wikiDialog(context, noDash(tag), actions: true),
              onLongPress: () =>
                  wikiDialog(context, noDash(tag), actions: true),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    height: 24,
                    width: 5,
                    decoration: BoxDecoration(
                      color: () {
                        if ('${tag[0]}' == '-') {
                          return Colors.green[300];
                        } else {
                          return Colors.red[300];
                        }
                      }(),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          bottomLeft: Radius.circular(5)),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(top: 4, bottom: 4, right: 8, left: 6),
                    child: Text(noDash(tag.replaceAll('_', ' '))),
                  ),
                ],
              )));
    }

    Widget body() {
      if (_blacklist.length == 0) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.block,
                size: 32,
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Text('Your blacklist is empty'),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: _blacklist.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Wrap(
                        direction: Axis.horizontal,
                        children: () {
                          List<Widget> rows = [];
                          if (_blacklist.length > 0) {
                            List<String> tags = _blacklist[index].split(' ');
                            for (String tag in tags) {
                              if (tag.isEmpty) {
                                continue;
                              }
                              rows.add(cardWidget(tag));
                            }
                            return rows;
                          } else {
                            return [Container()];
                          }
                        }(),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            PopupMenuItem(
                              value: 'edit',
                              child: popMenuListTile('Edit', Icons.edit),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: popMenuListTile('Delete', Icons.delete),
                            ),
                          ],
                          onSelected: (value) async {
                            switch (value) {
                              case 'edit':
                                _addTags(context, edit: index)();
                                break;
                              case 'delete':
                                setState(() {
                                  _blacklist.removeAt(index);
                                  db.blacklist.value = Future.value(_blacklist);
                                });
                                break;
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                Divider()
              ],
            ),
          );
        },
        physics: BouncingScrollPhysics(),
      );
    }

    Widget floatingActionButton(BuildContext context) {
      return FloatingActionButton(
        child: _isSearching ? Icon(Icons.check) : Icon(Icons.add),
        onPressed: _addTags(context),
      );
    }

    Widget editor() {
      TextEditingController controller = TextEditingController();
      controller.text = _blacklist.join('\n');
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Blacklist'),
            IconButton(
              icon: Icon(Icons.help_outline),
              onPressed: () => wikiDialog(context, 'e621:blacklist'),
            )
          ],
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.multiline,
          maxLines: null,
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('CANCEL'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('OK'),
            onPressed: () {
              setState(() {
                _blacklist = controller.text.split('\n');
                List<String> newList = [];
                for (String b in _blacklist) {
                  if (b.trim().isNotEmpty) {
                    newList.add(b);
                  }
                }
                _blacklist = newList;
                db.blacklist.value = Future.value(_blacklist);
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Blacklist'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (context) => editor(),
                );
              }),
        ],
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

String noDash(String s) {
  if (s.isNotEmpty) {
    if (s[0] == '-' || s[0] == '~') {
      return s.substring(1);
    } else {
      return s;
    }
  }
  return '';
}
