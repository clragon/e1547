import 'package:e1547/denylist/components/deny_body.dart';
import 'package:e1547/interface/taglist_dialog.dart';
import 'package:e1547/services/client.dart';
import 'package:e1547/settings/settings.dart' show db;
import 'package:e1547/util/text_helper.dart';
import 'package:e1547/wiki/wiki_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class DenyListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DenyListPageState();
  }
}

class _DenyListPageState extends State<DenyListPage> {
  int editing;
  bool isSearching = false;
  List<String> denylist = [];
  TextEditingController tagController = TextEditingController();
  PersistentBottomSheetController<String> bottomSheetController;

  @override
  void initState() {
    super.initState();
    db.denylist.addListener(() async {
      denylist = await db.denylist.value;
      setState(() {});
    });
    db.denylist.value.then((list) => setState(() => denylist = list));
  }

  Function() addTags(BuildContext context, {int edit}) {
    return () async {
      setFocusToEnd(tagController);
      if (isSearching) {
        if (editing != null) {
          if (tagController.text.trim().isNotEmpty) {
            denylist[editing] = tagController.text.trim();
          } else {
            denylist.removeAt(editing);
          }
          db.denylist.value = Future.value(denylist);
          bottomSheetController?.close();
        } else {
          if (tagController.text.trim().isNotEmpty) {
            denylist.add(tagController.text.trim());
            db.denylist.value = Future.value(denylist);
            bottomSheetController?.close();
          }
        }
      } else {
        if (edit != null) {
          editing = edit;
          tagController.text = denylist[editing];
        } else {
          tagController.text = '';
        }
        bottomSheetController = Scaffold.of(context).showBottomSheet((context) {
          return Container(
            padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TypeAheadField(
                direction: AxisDirection.up,
                hideOnLoading: true,
                hideOnEmpty: true,
                hideOnError: true,
                keepSuggestionsOnSuggestionSelected: true,
                textFieldConfiguration: TextFieldConfiguration(
                  controller: tagController,
                  autofocus: true,
                  maxLines: 1,
                  inputFormatters: [LowercaseTextInputFormatter()],
                  decoration: InputDecoration(
                      labelText: 'Add to blacklist',
                      border: UnderlineInputBorder()),
                  onSubmitted: (_) {
                    addTags(context)();
                  },
                ),
                onSuggestionSelected: (suggestion) {
                  List<String> tags = tagController.text.split(' ');
                  List<String> before = [];
                  for (String tag in tags) {
                    before.add(tag);
                    if (before.join(' ').length >=
                        tagController.selection.extent.offset) {
                      String operator = tags[tags.indexOf(tag)][0];
                      if (operator != '-' && operator != '~') {
                        operator = '';
                      }
                      tags[tags.indexOf(tag)] = operator + suggestion;
                      break;
                    }
                  }
                  tagController.text = tags.join(' ') + ' ';
                  setFocusToEnd(tagController);
                },
                itemBuilder: (BuildContext context, itemData) {
                  return ListTile(
                    title: Text(itemData),
                  );
                },
                suggestionsCallback: (String pattern) async {
                  List<String> tags = tagController.text.split(' ');
                  List<String> before = [];
                  int selection = 0;
                  for (String tag in tags) {
                    before.add(tag);
                    if (before.join(' ').length >=
                        tagController.selection.extent.offset) {
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
          );
        });
        setState(() {
          isSearching = true;
        });
        bottomSheetController.closed.then((a) {
          setState(() {
            isSearching = false;
            editing = null;
          });
        });
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    Widget floatingActionButton(BuildContext context) {
      return FloatingActionButton(
        child: isSearching ? Icon(Icons.check) : Icon(Icons.add),
        onPressed: addTags(context),
      );
    }

    Widget appBar() {
      return AppBar(
        title: Text('Blacklist'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (context) => TagListDialog(
                      inital: denylist.join('\n'),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Blacklist'),
                          IconButton(
                            icon: Icon(Icons.help_outline),
                            onPressed: () =>
                                wikiDialog(context, 'e621:blacklist'),
                          )
                        ],
                      ),
                      onSubmit: (text) {
                        setState(() {
                          List<String> newList = text.split('\n');
                          for (String line in denylist) {
                            if (line.trim().isNotEmpty) {
                              newList.add(line.trim());
                            }
                          }
                          denylist = newList;
                          db.denylist.value = Future.value(denylist);
                        });
                        return null;
                      }),
                );
              }),
        ],
      );
    }

    return Scaffold(
      appBar: appBar(),
      body: DenyListBody(
        denylist: denylist,
        onEdit: (index) {
          addTags(context, edit: index)();
        },
        onDelete: (index) {
          setState(() {
            denylist.removeAt(index);
            db.denylist.value = Future.value(denylist);
          });
        },
      ),
      floatingActionButton: Builder(
        builder: (context) {
          return floatingActionButton(context);
        },
      ),
    );
  }
}
