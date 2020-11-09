import 'package:e1547/follows/components/follow_body.dart';
import 'package:e1547/interface/taglist_dialog.dart';
import 'package:e1547/services/client.dart';
import 'package:e1547/settings/settings.dart' show db;
import 'package:e1547/util/text_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class FollowingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FollowingPageState();
  }
}

class _FollowingPageState extends State<FollowingPage> {
  List<String> follows = [];

  @override
  void initState() {
    super.initState();
    db.follows.addListener(() async {
      follows = await db.follows.value;
      setState(() {});
    });
    db.follows.value.then((a) async => setState(() => follows = a));
  }

  @override
  Widget build(BuildContext context) {
    Widget floatingActionButton(BuildContext context) {
      TextEditingController _tagController = TextEditingController();
      PersistentBottomSheetController<String> _bottomSheetController;
      ValueNotifier<bool> isSearching = ValueNotifier(false);
      return ValueListenableBuilder(
        valueListenable: isSearching,
        builder: (context, value, child) {
          void submit() {
            if (_tagController.text.trim().isNotEmpty) {
              db.follows.value =
                  Future.value(follows..add(_tagController.text.trim()));
              _bottomSheetController?.close();
            }
          }

          return FloatingActionButton(
            child: isSearching.value ? Icon(Icons.check) : Icon(Icons.add),
            onPressed: () async {
              setFocusToEnd(_tagController);
              if (isSearching.value) {
                submit();
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
                              keepSuggestionsOnSuggestionSelected: true,
                              textFieldConfiguration: TextFieldConfiguration(
                                controller: _tagController,
                                autofocus: true,
                                maxLines: 1,
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(' ')
                                ],
                                decoration: InputDecoration(
                                    labelText: 'Follow Tag',
                                    border: UnderlineInputBorder()),
                                onSubmitted: (_) => submit(),
                              ),
                              onSuggestionSelected: (suggestion) {
                                _tagController.text = suggestion['name'];
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Following'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (context) => TagListDialog(
                    inital: follows.join('\n'),
                    title: Text('Following'),
                    onSubmit: (text) {
                      setState(() {
                        db.follows.value = Future.value(text.split('\n'));
                      });
                      return null;
                    },
                    inputFormatters: [FilteringTextInputFormatter.deny(' ')],
                  ),
                );
              }),
        ],
      ),
      body: FollowListBody(
        follows: follows,
      ),
      floatingActionButton: Builder(
        builder: (context) {
          return floatingActionButton(context);
        },
      ),
    );
  }
}
