import 'dart:async';

import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sub/flutter_sub.dart';
import 'package:intl/intl.dart';

class TagInput extends StatelessWidget {
  const TagInput({
    required this.submit,
    required this.controller,
    this.multiInput = true,
    this.category,
    this.direction,
    this.readOnly = false,
    this.labelText,
    this.decoration,
    this.textInputAction,
  });

  final SubmitString submit;
  final TextEditingController? controller;
  final bool multiInput;
  final int? category;
  final AxisDirection? direction;
  final bool readOnly;
  final String? labelText;
  final InputDecoration? decoration;
  final TextInputAction? textInputAction;

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
      builder: (context, controller) => SubEffect(
        effect: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.text = sortTags(controller.text);
            if (controller.text.isNotEmpty) {
              controller.text += ' ';
            }
          });
          return null;
        },
        keys: [controller],
        child: SearchInput<TagSuggestion>(
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
          onSuggestionSelected: (suggestion) {
            List<String> tags = controller.text.split(' ').trim();
            int selection = findTag(tags, controller.selection.extent.offset);
            String tag = tags[selection];
            String operator = tag[0];
            if (!['-', '~'].contains(operator)) operator = '';
            tags[selection] = operator + suggestion.name;
            controller.text = '${TagSet.from(tags)} ';
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
            List<String> tags = controller.text.split(' ').trim();
            int selection = findTag(tags, controller.selection.extent.offset);
            String tag = tags[selection];
            if (tag.isEmpty) return [];
            return context
                .read<Client>()
                .autocomplete(
                  tagToRaw(tags[selection]),
                  category: category,
                )
                .then((value) => value.take(3));
          },
        ),
      ),
    );
  }
}

class AdvancedTagInput extends StatefulWidget {
  const AdvancedTagInput({
    required this.submit,
    required this.controller,
    this.labelText,
    this.textInputAction,
  });

  final TextEditingController? controller;
  final SubmitString submit;
  final String? labelText;
  final TextInputAction? textInputAction;

  @override
  State<AdvancedTagInput> createState() => _AdvancedTagInputState();
}

class _AdvancedTagInputState extends State<AdvancedTagInput> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? TextEditingController();
  }

  @override
  void didUpdateWidget(covariant AdvancedTagInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        controller.dispose();
      }
      controller = widget.controller ?? TextEditingController();
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> withTags(Future<TagSet> Function(TagSet tags) editor) async {
    controller.text = '${await editor(TagSet.parse(controller.text))} ';
    controller.setFocusToEnd();
  }

  List<PopupMenuEntry<String>> popMenuFromMap(Map<String, String> strings) =>
      strings.keys.map((e) => PopupMenuItem(value: e, child: Text(e))).toList();

  @override
  Widget build(BuildContext context) {
    Widget filterByWidget() {
      Map<String, String> filterTypes = {
        'Score': 'score',
        'Favorites': 'favcount',
      };

      return PopupMenuButton<String>(
        icon: const Icon(Icons.filter_list),
        tooltip: 'Filter by',
        itemBuilder: (context) => popMenuFromMap(filterTypes),
        onSelected: (selection) {
          String? filterType = filterTypes[selection];

          withTags((tags) async {
            NumberRange? current =
                NumberRange.tryParse(tags[filterType!] ?? '');
            current ??= const NumberRange(20);
            current = NumberRange(current.value);

            await showDialog(
              context: context,
              builder: (context) => RangeDialog(
                title: Text('Minimum $filterType'),
                value: current,
                initialMode: RangeDialogMode.exact,
                canChangeMode: false,
                division: 10,
                max: 100,
                onSubmit: (value) => current = value,
              ),
            );

            if (current == null) {
              tags.remove(filterType);
            } else {
              current = NumberRange(
                current!.value,
                comparison: NumberComparison.greaterThanOrEqual,
              );
              tags[filterType] = current.toString();
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
        icon: const Icon(Icons.sort),
        tooltip: 'Sort by',
        itemBuilder: (context) => popMenuFromMap(orders),
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
        icon: const Icon(Icons.playlist_add_check),
        tooltip: 'Conditions',
        itemBuilder: (context) => popMenuFromMap(status),
        onSelected: (selection) async {
          String? key;
          String? value;

          switch (status[selection]) {
            case 'rating':
              await showRatingDialog(
                context: context,
                onSelected: (rating) {
                  key = 'rating';
                  value = rating.name;
                },
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

          await withTags((tags) async {
            if (key == null) {
              return tags;
            }
            if (key == 'status' && tags.containsKey('status')) {
              tags.remove('status');
              return tags;
            }
            if (key == 'inpool' && tags.containsKey('inpool')) {
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
          direction: AxisDirection.up,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
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
