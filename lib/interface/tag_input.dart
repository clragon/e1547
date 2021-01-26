import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class TagInput extends StatelessWidget {
  final String labelText;
  final Function onSubmit;
  final TextEditingController controller;
  final bool multiInput;
  final int category;

  TagInput({
    @required this.labelText,
    @required this.onSubmit,
    @required this.controller,
    this.category,
    this.multiInput = true,
  }) {
    setFocusToEnd(controller);
    controller.text = sortTags(controller.text);
    if (controller.text != '') {
      controller.text = controller.text + ' ';
    }
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField(
      direction: AxisDirection.up,
      hideOnEmpty: true,
      hideOnError: true,
      keepSuggestionsOnSuggestionSelected: true,
      textFieldConfiguration: TextFieldConfiguration(
          controller: controller,
          autofocus: true,
          maxLines: 1,
          inputFormatters: !multiInput
              ? [
                  LowercaseTextInputFormatter(),
                  FilteringTextInputFormatter.deny(' ')
                ]
              : [LowercaseTextInputFormatter()],
          decoration: InputDecoration(
              labelText: labelText, border: UnderlineInputBorder()),
          onSubmitted: (_) {
            if (onSubmit != null) {
              onSubmit();
            }
          }),
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
            tags[tags.indexOf(tag)] = operator + suggestion['name'];
            break;
          }
        }
        controller.text = tags.join(' ') + ' ';
        setFocusToEnd(controller);
      },
      itemBuilder: (BuildContext context, itemData) {
        String count = itemData['post_count'].toString();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  color: getCategoryColor(categories.entries
                      .firstWhere((e) => e.value == itemData['category'],
                          orElse: () => MapEntry('', 0))
                      .key),
                  height: 54,
                  width: 5,
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    itemData['name'],
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                itemData['post_count'] >= 1000
                    ? '${count.substring(0, count.length - 3)}k'
                    : count.toString(),
                style: TextStyle(fontSize: 16),
              ),
            )
          ],
        );
      },
      loadingBuilder: (BuildContext context) => Container(height: 0),
      noItemsFoundBuilder: (BuildContext context) {
        return ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(),
              ),
            ],
          ),
        );
      },
      suggestionsCallback: (String pattern) async {
        List<String> tags = controller.text.split(' ');
        List<String> before = [];
        int selection = 0;
        for (String tag in tags) {
          before.add(tag);
          if (before.join(' ').length >= controller.selection.extent.offset) {
            selection = tags.indexOf(tag);
            break;
          }
        }
        if (noDash(tags[selection].trim()).isNotEmpty) {
          return (await client.autocomplete(noDash(tags[selection]),
              category: category));
        } else {
          return [];
        }
      },
    );
  }
}
