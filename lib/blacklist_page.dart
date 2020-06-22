import 'package:flutter/cupertino.dart';
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
  List<String> _blacklist = [];

  @override
  void initState() {
    super.initState();
    db.blacklist.value.then((a) async => setState(() => _blacklist = a));
  }

  int _editing = -1;
  bool _isSearching = false;
  TextEditingController _tagController = TextEditingController();
  PersistentBottomSheetController<String> _bottomSheetController;

  Function() _onPressedFloatingActionButton(BuildContext context,
      {int edit = -1}) {
    return () async {
      void onCloseBottomSheet() {
        setState(() {
          _isSearching = false;
          _editing = -1;
        });
      }

      if (!_isSearching) {
        if (edit != -1) {
          _editing = edit;
          _tagController = TextEditingController()..text = _blacklist[_editing];
        } else {
          _tagController = TextEditingController()..text = '';
        }
      }
      setFocusToEnd(_tagController);

      if (_isSearching) {
        if (_editing != -1) {
          _blacklist[_editing] = _tagController.text;
        } else {
          _blacklist.add(_tagController.text);
        }
        db.blacklist.value = Future.value(_blacklist);
        _bottomSheetController?.close();
      } else {
        _bottomSheetController =
            Scaffold.of(context).showBottomSheet((context) => new Container(
                  padding: const EdgeInsets.only(
                      left: 10.0, right: 10.0, bottom: 10),
                  child: new Column(mainAxisSize: MainAxisSize.min, children: [
                    TypeAheadField(
                      direction: AxisDirection.up,
                      hideOnLoading: true,
                      hideOnEmpty: true,
                      hideOnError: true,
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: _tagController,
                        autofocus: true,
                        maxLines: 1,
                        inputFormatters: [new LowercaseTextInputFormatter()],
                        decoration: InputDecoration(
                            labelText: 'Add to blacklist',
                            border: UnderlineInputBorder()),
                      ),
                      onSuggestionSelected: (suggestion) {
                        List<String> tags =
                            _tagController.text.toString().split(' ');
                        if (suggestion
                            .contains(noDash(tags[tags.length - 1]))) {
                          String operator = tags[tags.length - 1][0];
                          if (operator == '-' || operator == '~') {
                            tags[tags.length - 1] = operator + suggestion;
                          } else {
                            tags[tags.length - 1] = suggestion;
                          }
                        } else {
                          tags.add(suggestion);
                        }
                        String query = '';
                        for (String tag in tags) {
                          query = query + tag + ' ';
                        }
                        setState(() {
                          _tagController.text = query;
                        });
                      },
                      itemBuilder: (BuildContext context, itemData) {
                        return new ListTile(
                          title: Text(itemData),
                        );
                      },
                      suggestionsCallback: (String pattern) {
                        List<String> tags = pattern.split(' ');
                        return client.tags(noDash(tags[tags.length - 1]), 0);
                      },
                    ),
                  ]),
                ));

        setState(() {
          _isSearching = true;
        });

        _bottomSheetController.closed.then((a) => onCloseBottomSheet());
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    Widget listHolder(String title, List<Widget> list) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(title),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Wrap(
                  direction: Axis.horizontal,
                  children: list,
                ),
              ),
            ],
          )
        ],
      );
    }

    Widget body() {
      return ListView.builder(
        itemCount: _blacklist.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: () {
                          List<Widget> rows = [];
                          List<Widget> blackTags = [];
                          List<Widget> whiteTags = [];
                          if (_blacklist.length > 0) {
                            List<String> tags = _blacklist[index].split(' ');
                            for (String tag in tags) {
                              if (tag == '') {
                                continue;
                              }
                              Widget card = InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => wikiDialog(
                                          context, noDash(tag),
                                          actions: true),
                                    );
                                  },
                                  child: Card(
                                      child: Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Text(noDash(tag)),
                                  )));
                              if ('${tag[0]}' == '-') {
                                whiteTags.add(card);
                              } else {
                                blackTags.add(card);
                              }
                            }
                            if (blackTags.length > 0) {
                              rows.add(listHolder(
                                  'Filter posts with these tags:', blackTags));
                            }
                            if (whiteTags.length > 0) {
                              rows.add(listHolder(
                                  'Except if they have these tags:',
                                  whiteTags));
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
                              value: 'delete',
                              child: Padding(
                                padding: EdgeInsets.all(4),
                                child: Text('Delete'),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'edit',
                              child: Padding(
                                padding: EdgeInsets.all(4),
                                child: Text(
                                  'Edit',
                                  maxLines: 1,
                                ),
                              ),
                            )
                          ],
                          onSelected: (value) async {
                            switch (value) {
                              case 'delete':
                                setState(() {
                                  _blacklist.removeAt(index);
                                  db.blacklist.value = Future.value(_blacklist);
                                });
                                break;
                              case 'edit':
                                _onPressedFloatingActionButton(context,
                                    edit: index)();
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
        child: _isSearching ? const Icon(Icons.check) : const Icon(Icons.add),
        onPressed: _onPressedFloatingActionButton(context),
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
              onPressed: () =>
                  showDialog(context: context, child: wikiDialog(context, 'e621:blacklist')),
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
  if (s != '') {
    if (s[0] == '-' || s[0] == '~') {
      return s.substring(1);
    } else {
      return s;
    }
  }
  return '';
}
