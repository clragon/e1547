import 'package:e1547/pool.dart';
import 'package:e1547/posts_page.dart';
import 'package:e1547/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'client.dart';
import 'interface.dart';
import 'main.dart';
import 'persistence.dart' show db;

class FollowingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FollowingPageState();
  }
}

class _FollowingPageState extends State<FollowingPage> {
  List<String> _follows = [];
  bool _refresh = false;

  @override
  void initState() {
    super.initState();
    db.follows.addListener(() async {
      List<String> follows = await db.follows.value;
      setState(() => _follows = follows);
    });
    db.follows.value.then((a) async => setState(() => _follows = a));
  }

  @override
  Widget build(BuildContext context) {
    Widget body() {
      return ListView.builder(
        itemCount: _follows.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: () {
                          return [
                            InkWell(
                                onTap: () => wikiDialog(
                                    context, _follows[index],
                                    actions: true),
                                child: Card(
                                    child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(_follows[index]),
                                )))
                          ];
                        }(),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () async {
                            if (_follows[index].startsWith('pool:')) {
                              Pool p = await client.pool(
                                  int.parse(_follows[index].split(':')[1]));
                              Navigator.of(context).push(
                                  MaterialPageRoute<Null>(builder: (context) {
                                return PoolPage(p);
                              }));
                            } else {
                              Navigator.of(context).push(
                                  MaterialPageRoute<Null>(builder: (context) {
                                return SearchPage(
                                    tags: Tagset.parse(_follows[index]));
                              }));
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            db.follows.value =
                                Future.value(_follows..removeAt(index));
                            _refresh = true;
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
      TextEditingController _tagController = TextEditingController();
      PersistentBottomSheetController<String> _bottomSheetController;
      ValueNotifier<bool> isSearching = ValueNotifier(false);
      return ValueListenableBuilder(
        valueListenable: isSearching,
        builder: (context, value, child) {
          return FloatingActionButton(
            child: isSearching.value ? Icon(Icons.check) : Icon(Icons.add),
            onPressed: () async {
              setFocusToEnd(_tagController);
              if (isSearching.value) {
                if (_tagController.text.trim() != '') {
                  _refresh = true;
                  db.follows.value =
                      Future.value(_follows..add(_tagController.text.trim()));
                  _bottomSheetController?.close();
                }
              } else {
                _tagController.text = '';
                _bottomSheetController =
                    Scaffold.of(context).showBottomSheet((context) => Container(
                          padding: EdgeInsets.only(
                              left: 10.0, right: 10.0, bottom: 10),
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                            TypeAheadField(
                              direction: AxisDirection.up,
                              hideOnLoading: true,
                              hideOnEmpty: true,
                              hideOnError: true,
                              textFieldConfiguration: TextFieldConfiguration(
                                controller: _tagController,
                                autofocus: true,
                                maxLines: 1,
                                inputFormatters: [
                                  BlacklistingTextInputFormatter(' ')
                                ],
                                decoration: InputDecoration(
                                    labelText: 'Follow Tag',
                                    border: UnderlineInputBorder()),
                              ),
                              onSuggestionSelected: (suggestion) {
                                _tagController.text = suggestion.toLowerCase();
                              },
                              itemBuilder: (BuildContext context, itemData) {
                                return ListTile(
                                  title: Text(itemData['name']),
                                );
                              },
                              suggestionsCallback: (String pattern) {
                                if (pattern.trim().isNotEmpty) {
                                  return client.tags(pattern);
                                } else {
                                  return [];
                                }
                              },
                            ),
                          ]),
                        ));
                isSearching.value = true;
                _bottomSheetController.closed.then((a) {
                  isSearching.value = false;
                });
              }
            },
          );
        },
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (_refresh) {
          refreshPage(context);
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Following'),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                if (_refresh) {
                  refreshPage(context);
                } else {
                  Navigator.pop(context);
                }
              }),
        ),
        body: body(),
        floatingActionButton: Builder(
          builder: (context) {
            return floatingActionButton(context);
          },
        ),
      ),
    );
  }
}
