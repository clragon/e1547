import 'package:e1547/pool.dart';
import 'package:e1547/posts_page.dart';
import 'package:e1547/tag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'client.dart';
import 'input.dart';
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
    db.follows.value.then((a) async => setState(() => _follows = a));
  }

  bool _isSearching = false;
  TextEditingController _tagController = TextEditingController();
  PersistentBottomSheetController<String> _bottomSheetController;

  Function() _onPressedFloatingActionButton(BuildContext context) {
    return () async {
      void onCloseBottomSheet() {
        setState(() {
          _isSearching = false;
        });
      }

      if (!_isSearching) {
        _tagController = TextEditingController()..text = '';
      }
      setFocusToEnd(_tagController);

      if (_isSearching) {
        _follows.add(_tagController.text);
        _refresh = true;
        db.follows.value = Future.value(_follows);
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
                        inputFormatters: [new BlacklistingTextInputFormatter(' ')],
                        decoration: InputDecoration(
                            labelText: 'Follow Tag',
                            border: UnderlineInputBorder()),
                      ),
                      onSuggestionSelected: (suggestion) {
                        String tag = _tagController.text.toString().toLowerCase();
                        tag = (suggestion);
                        setState(() {
                          _tagController.text = tag;
                        });
                      },
                      itemBuilder: (BuildContext context, itemData) {
                        return new ListTile(
                          title: Text(itemData),
                        );
                      },
                      suggestionsCallback: (String pattern) {
                        List<String> tags = pattern.split(' ');
                        return client.tags(tags[tags.length - 1], 0);
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
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => wikiDialog(
                                        context, _follows[index],
                                        actions: true),
                                  );
                                },
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
                              Pool p = await client.poolById(int.parse(_follows[index].split(':')[1]));
                              Navigator.of(context)
                                  .push(new MaterialPageRoute<Null>(builder: (context) {
                                return new PoolPage(p);
                              }));
                            } else {
                              Navigator.of(context).push(
                                  new MaterialPageRoute<Null>(builder: (context) {
                                    return new SearchPage(tags:
                                        Tagset.parse(_follows[index]));
                                  }));
                            }

                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _follows.removeAt(index);
                              db.follows.value = Future.value(_follows);
                              _refresh = true;
                            });
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
