import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class TagSearchFilterTag extends BuilderFilterTag {
  TagSearchFilterTag({
    required super.tag,
    super.name,
  }) : super(
          builder: (context, state) => TagSearchFilter(state: state),
        );
}

class TagSearchFilter extends StatelessWidget {
  const TagSearchFilter({
    super.key,
    required this.state,
  });

  final FilterTagState state;

  @override
  Widget build(BuildContext context) {
    FilterTagThemeData theme = FilterTagTheme.of(context);
    return SubTextValue(
      value: state.value,
      onChanged: (value) => state.onChanged(QueryMap.parse(value).toString()),
      shouldUpdate: (oldValue, newValue) =>
          QueryMap.parse(oldValue).toString() != newValue,
      builder: (context, controller) => TagInput(
        textInputAction: TextInputAction.search,
        direction: AxisDirection.up,
        labelText: state.filter.name,
        decoration: theme.decoration,
        focusNode: theme.focusNode,
        controller: controller,
        submit: (value) => state.onSubmit?.call(value),
      ),
    );
  }
}

class EditTagDialog extends StatelessWidget {
  const EditTagDialog({
    super.key,
    this.tag,
    required this.onSubmit,
    this.actionController,
    this.title,
  });

  final String? tag;
  final ValueSetter<String> onSubmit;
  final ActionController? actionController;
  final String? title;

  @override
  Widget build(BuildContext context) {
    bool isDesktop = Theme.of(context).isDesktop;
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: isDesktop ? 600 : 0,
      ),
      child: Material(
        child: PromptFilterList(
          tags: QueryMap({'tags': tag}),
          onSubmit: (value) => onSubmit(value['tags']!),
          submitIcon: isDesktop ? const Icon(Icons.add) : null,
          filters: [
            PrimaryFilterConfig(
              filter: TagSearchFilterTag(
                tag: 'tags',
                name: title ?? 'Tags',
              ),
            ),
          ],
          controller: actionController,
        ),
      ),
    );
  }
}

class AddTagFloatingActionButton extends StatelessWidget {
  const AddTagFloatingActionButton({
    super.key,
    this.tag,
    required this.onSubmit,
    this.title,
  });

  final String? tag;
  final ValueSetter<String> onSubmit;
  final String? title;

  @override
  Widget build(BuildContext context) {
    bool isDesktop = Theme.of(context).isDesktop;
    return SubValue<PromptActionController>(
      create: () =>
          isDesktop ? DialogActionController() : SheetActionController(),
      keys: [isDesktop],
      builder: (context, actionController) => PromptFloatingActionButton(
        controller: actionController,
        builder: (context, actionController) => EditTagDialog(
          tag: tag,
          onSubmit: onSubmit,
          actionController: actionController,
          title: title,
        ),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
