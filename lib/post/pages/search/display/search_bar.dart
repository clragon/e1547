import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/tag.dart';
import 'package:flutter/material.dart';

class PostSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String result) onSubmit;

  PostSearchBar({
    @required this.controller,
    @required this.onSubmit,
  });

  void withTags(Future<Tagset> Function(Tagset tags) editor) async {
    controller.text =
        (await editor(Tagset.parse(controller.text))).toString() + ' ';
    setFocusToEnd(controller);
  }

  List<PopupMenuEntry<String>> Function(BuildContext) menuEntryBuilder(
      List<String> text) {
    return (context) {
      List<PopupMenuEntry<String>> items = [];
      for (int i = 0; i < text.length; i++) {
        String t = text[i];
        items.add(PopupMenuItem(child: Text(t), value: t));
      }
      return items;
    };
  }

  @override
  Widget build(BuildContext context) {
    Widget filterByWidget() {
      return PopupMenuButton<String>(
          icon: Icon(Icons.filter_list),
          tooltip: 'Filter by',
          itemBuilder: menuEntryBuilder(
            ['Score', 'Favorites'],
          ),
          onSelected: (selection) {
            String filterType = {
              'Score': 'score',
              'Favorites': 'favcount',
            }[selection];

            withTags((tags) async {
              String valueString = tags[filterType];
              int value =
                  valueString == null ? 0 : int.parse(valueString.substring(2));

              int min;
              await showDialog(
                context: context,
                builder: (context) => RangeDialog(
                  title: Text('Minimum $filterType'),
                  value: value,
                  division: 10,
                  max: 100,
                  onSubmit: (int value) => min = value,
                ),
              );

              if (min == null) {
                return tags;
              }

              if (min == 0) {
                tags.remove(filterType);
              } else {
                tags[filterType] = '>=$min';
              }
              return tags;
            });
          });
    }

    Widget sortByWidget() {
      Map<String, String> orders = {
        'New': 'new',
        'Score': 'score',
        'Favorites': 'favcount',
        'Rank': 'rank',
        'Random': 'random',
      };

      return PopupMenuButton<String>(
        icon: Icon(Icons.sort),
        tooltip: 'Sort by',
        itemBuilder: menuEntryBuilder(
          orders.keys.toList(),
        ),
        onSelected: (String selection) {
          String orderType = orders[selection];

          withTags((tags) async {
            if (orderType == 'new') {
              tags.remove('order');
            } else {
              tags['order'] = orderType;
            }

            return tags;
          });
        },
      );
    }

    Widget statusWidget() {
      Map<String, String> status = {
        'Rating': 'rating',
        'Deleted': 'deleted',
        'Pool': 'pool',
      };

      return PopupMenuButton<String>(
          icon: Icon(Icons.playlist_add_check),
          tooltip: 'Conditions',
          itemBuilder: menuEntryBuilder(
            status.keys.toList(),
          ),
          onSelected: (selection) async {
            String key;
            String value;

            switch (status[selection]) {
              case 'rating':
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return RatingDialog(onTap: (rating) {
                      key = 'rating';
                      value = rating;
                    });
                  },
                );
                break;
              case 'deleted':
                key = 'status';
                value = 'deleted';
                break;
              case 'favorited':
                // unimplemented
                break;
              case 'type':
                // unimplemented
                break;
              case 'pool':
                key = 'inpool';
                value = 'true';
                break;
            }

            withTags((tags) async {
              if (key == null) {
                return tags;
              }
              if (key == 'status' && tags.contains('status')) {
                tags.remove('status');
                return tags;
              }
              if (key == 'inpool' && tags.contains('inpool')) {
                tags.remove('inpool');
                return tags;
              }
              tags[key] = value;
              return tags;
            });
          });
    }

    return Container(
      padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        TagInput(
          controller: controller,
          labelText: 'Tags',
          onSubmit: onSubmit,
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            statusWidget(),
            filterByWidget(),
            sortByWidget(),
          ]),
        ),
      ]),
    );
  }
}
