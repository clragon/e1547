import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sub/flutter_sub.dart';
import 'package:intl/intl.dart';

class TagInput extends StatelessWidget {
  const TagInput({
    super.key,
    required this.submit,
    required this.controller,
    this.multiInput = true,
    this.category,
    this.direction,
    this.readOnly = false,
    this.labelText,
    this.decoration,
    this.textInputAction,
    this.focusNode,
  });

  final SubmitString submit;
  final TextEditingController? controller;
  final bool multiInput;
  final int? category;
  final VerticalDirection? direction;
  final bool readOnly;
  final String? labelText;
  final InputDecoration? decoration;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;

  int findTag(List<String> tags, int offset) {
    List<String> before = [];
    for (final tag in tags) {
      before.add(tag);
      if (before.join(' ').length >= offset) {
        return tags.indexOf(tag);
      }
    }
    return tags.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    return SubDefault<TextEditingController>(
      value: controller,
      create: TextEditingController.new,
      builder: (context, controller) => SubValue(
        create: () {
          controller.text = sortTags(controller.text);
          if (controller.text.isNotEmpty) {
            controller.text += ' ';
          }
          return controller;
        },
        keys: [controller],
        builder: (context, controller) => AutocompleteTextField<TagSuggestion>(
          controller: controller,
          submit: (result) => submit(sortTags(result)),
          direction: direction,
          readOnly: readOnly,
          labelText: labelText,
          decoration: decoration,
          inputFormatters: [
            LowercaseTextInputFormatter(),
            if (!multiInput) FilteringTextInputFormatter.deny(' '),
          ],
          textInputAction: textInputAction,
          focusNode: focusNode,
          onSelected: (suggestion) {
            List<String> tags = controller.text.split(' ');
            int selection = findTag(tags, controller.selection.extent.offset);
            String tag = tags[selection];
            String operator = tag[0];
            if (!['-', '~'].contains(operator)) operator = '';
            tags[selection] = operator + suggestion.name;
            controller.text = '${QueryMap.parse(tags.join(' '))} ';
            controller.setFocusToEnd();
          },
          itemBuilder: (context, itemData) => Row(
            children: [
              Container(
                color: TagCategory.values
                    .firstWhereOrNull((e) => e.id == itemData.category)
                    ?.color,
                height: 54,
                width: 5,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  itemData.name,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  NumberFormat.compact().format(itemData.postCount),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          suggestionsCallback: (pattern) async {
            List<String> tags = controller.text.split(' ');
            int selection = findTag(tags, controller.selection.extent.offset);
            String tag = tags[selection];
            if (tag.isEmpty) return [];
            return context
                .read<Client>()
                .autocomplete(
                  search: tagToRaw(tags[selection]),
                  category: category,
                )
                .then((value) => value.take(3).toList());
          },
        ),
      ),
    );
  }
}
