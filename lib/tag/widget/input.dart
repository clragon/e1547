import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
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
          if (controller.text.isNotEmpty) {
            controller.text += ' ';
          }
          return controller;
        },
        keys: [controller],
        builder: (context, controller) => AutocompleteTextField<Tag>(
          controller: controller,
          submit: submit,
          direction: direction,
          readOnly: readOnly,
          labelText: labelText,
          decoration: decoration,
          inputFormatters: [
            LowercaseTextInputFormatter(),
            if (!multiInput) FilteringTextInputFormatter.deny(' '),
          ],
          private: PrivateTextFields.of(context),
          textInputAction: textInputAction,
          focusNode: focusNode,
          onSelected: (suggestion) {
            List<String> tags = controller.text.split(' ');
            int selection = findTag(tags, controller.selection.extent.offset);
            String tag = tags[selection];
            String operator = tag[0];
            if (['-', '~'].contains(operator)) {
              tags[selection] = tag.substring(1);
            } else {
              operator = '';
            }
            tags[selection] = operator + suggestion.name;
            controller.text = '${tags.join(' ')} ';
            controller.setFocusToEnd();
          },
          itemBuilder: (context, value) => Row(
            children: [
              Container(
                color: TagCategory.values
                    .firstWhereOrNull((e) => e.id == value.category)
                    ?.color,
                height: 54,
                width: 5,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    value.name,
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  NumberFormat.compact().format(value.count),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          suggestionsCallback: (pattern) async {
            Client client = context.read<Client>();
            List<String> tags = controller.text.split(' ');
            int selection = findTag(tags, controller.selection.extent.offset);
            String tag = tags[selection];
            if (tag.isEmpty) return [];
            return client.tags.autocomplete(
              search: tagToRaw(tags[selection]),
              category: category,
              limit: 3,
            );
          },
        ),
      ),
    );
  }
}
