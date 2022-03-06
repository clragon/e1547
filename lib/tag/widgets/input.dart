import 'dart:async';

import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';

typedef SubmitString = FutureOr<void> Function(String result);

class TagInput extends StatefulWidget {
  final String? labelText;
  final SubmitString submit;
  final TextEditingController? controller;
  final bool multiInput;
  final int? category;
  final bool readOnly;
  final TextInputAction? textInputAction;

  const TagInput({
    required this.labelText,
    required this.submit,
    required this.controller,
    this.multiInput = true,
    this.category,
    this.readOnly = false,
    this.textInputAction,
  });

  @override
  _TagInputState createState() => _TagInputState();
}

class _TagInputState extends State<TagInput> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? TextEditingController();
    controller.text = sortTags(controller.text);
    if (controller.text != '') {
      controller.text = controller.text + ' ';
    }
    controller.setFocusToEnd();
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<AutocompleteTag>(
      direction: AxisDirection.up,
      hideOnEmpty: true,
      hideOnError: true,
      hideKeyboard: widget.readOnly,
      keepSuggestionsOnSuggestionSelected: true,
      textFieldConfiguration: TextFieldConfiguration(
        controller: controller,
        autofocus: true,
        maxLines: 1,
        inputFormatters: [
          LowercaseTextInputFormatter(),
          if (!widget.multiInput) FilteringTextInputFormatter.deny(' '),
        ],
        decoration: InputDecoration(labelText: widget.labelText),
        onSubmitted: (result) => widget.submit(sortTags(result)),
        textInputAction: widget.textInputAction,
      ),
      onSuggestionSelected: (suggestion) {
        List<String> tags = sortTags(controller.text).split(' ');
        List<String> before = [];
        for (String tag in tags) {
          before.add(tag);
          if (before.join(' ').length >= controller.selection.extent.offset) {
            String operator = tags[tags.indexOf(tag)][0];
            if (operator != '-' && operator != '~') {
              operator = '';
            }
            tags[tags.indexOf(tag)] = operator + suggestion.name;
            break;
          }
        }
        controller.text = tags.join(' ') + ' ';
        controller.setFocusToEnd();
      },
      itemBuilder: (context, itemData) => Row(
        children: [
          Container(
            color: getCategoryColor(categories.entries
                .firstWhere((e) => e.value == itemData.category,
                    orElse: () => MapEntry('', 0))
                .key),
            height: 54,
            width: 5,
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              itemData.name,
              style: TextStyle(fontSize: 16),
            ),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              NumberFormat.compact().format(itemData.postCount),
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
      loadingBuilder: (context) => SizedBox(),
      noItemsFoundBuilder: (context) => ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedCircularProgressIndicator(size: 24),
          ],
        ),
      ),
      suggestionsCallback: (pattern) async {
        List<String> tags = controller.text.split(' ');
        List<String> before = [];
        int selection = 0;
        for (final tag in tags) {
          before.add(tag);
          if (before.join(' ').length >= controller.selection.extent.offset) {
            selection = tags.indexOf(tag);
            break;
          }
        }
        if (tagToName(tags[selection].trim()).isNotEmpty &&
            !tags[selection].contains(':')) {
          return client.autocomplete(tagToName(tags[selection]),
              category: widget.category);
        } else {
          return [];
        }
      },
    );
  }
}

class AdvancedTagInput extends StatefulWidget {
  final TextEditingController? controller;
  final SubmitString submit;
  final String? labelText;
  final TextInputAction? textInputAction;

  const AdvancedTagInput({
    required this.submit,
    required this.controller,
    this.labelText,
    this.textInputAction,
  });

  @override
  _AdvancedTagInputState createState() => _AdvancedTagInputState();
}

class _AdvancedTagInputState extends State<AdvancedTagInput> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? TextEditingController();
  }

  Future<void> withTags(Future<Tagset> Function(Tagset tags) editor) async {
    controller.text =
        (await editor(Tagset.parse(controller.text))).toString() + ' ';
    controller.setFocusToEnd();
  }

  List<PopupMenuEntry<String>> fromMap(Map<String, String> strings) =>
      strings.keys.map((e) => PopupMenuItem(child: Text(e), value: e)).toList();

  @override
  Widget build(BuildContext context) {
    Widget filterByWidget() {
      Map<String, String> filterTypes = {
        'Score': 'score',
        'Favorites': 'favcount',
      };

      return PopupMenuButton<String>(
        icon: Icon(Icons.filter_list),
        tooltip: 'Filter by',
        itemBuilder: (context) => fromMap(filterTypes),
        onSelected: (selection) {
          String? filterType = filterTypes[selection];

          withTags((tags) async {
            String? valueString = tags[filterType!];
            int value =
                valueString == null ? 0 : int.parse(valueString.substring(2));

            int? min;
            await showDialog(
              context: context,
              builder: (context) => RangeDialog(
                title: Text('Minimum $filterType'),
                value: value,
                division: 10,
                max: 100,
                onSubmit: (value) => min = value,
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
        },
      );
    }

    Widget sortByWidget() {
      Map<String, String> orders = {
        'Default': 'default',
        'New': 'new',
        'Score': 'score',
        'Favorites': 'favcount',
        'Rank': 'rank',
        'Random': 'random',
      };

      return PopupMenuButton<String>(
        icon: Icon(Icons.sort),
        tooltip: 'Sort by',
        itemBuilder: (context) => fromMap(orders),
        onSelected: (String selection) {
          String? orderType = orders[selection];

          withTags((tags) async {
            if (orderType == 'default') {
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
        itemBuilder: (context) => fromMap(status),
        onSelected: (selection) async {
          String? key;
          String? value;

          switch (status[selection]) {
            case 'rating':
              await showDialog(
                context: context,
                builder: (context) => RatingDialog(
                  onTap: (rating) {
                    key = 'rating';
                    value = rating.name;
                  },
                ),
              );
              break;
            case 'deleted':
              key = 'status';
              value = 'deleted';
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
            tags[key!] = value;
            return tags;
          });
        },
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TagInput(
          labelText: widget.labelText,
          controller: controller,
          submit: widget.submit,
          textInputAction: widget.textInputAction,
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              statusWidget(),
              filterByWidget(),
              sortByWidget(),
            ],
          ),
        ),
      ],
    );
  }
}
