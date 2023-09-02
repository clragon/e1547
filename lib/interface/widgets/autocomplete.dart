import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class AutocompleteTextField<T> extends StatelessWidget {
  const AutocompleteTextField({
    super.key,
    required this.onSuggestionSelected,
    required this.suggestionsCallback,
    required this.itemBuilder,
    required this.submit,
    this.controller,
    this.direction,
    this.readOnly = false,
    this.labelText,
    this.decoration,
    this.textInputAction,
    this.focusNode,
    this.inputFormatters,
  });

  final SubmitString submit;
  final TextEditingController? controller;
  final AxisDirection? direction;
  final bool readOnly;
  final String? labelText;
  final InputDecoration? decoration;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final SuggestionSelectionCallback<T> onSuggestionSelected;
  final ItemBuilder<T> itemBuilder;
  final SuggestionsCallback<T> suggestionsCallback;

  @override
  Widget build(BuildContext context) {
    bool hasFab = Scaffold.maybeOf(context)?.hasFloatingActionButton ?? false;
    return TypeAheadField<T>(
      direction: direction ?? AxisDirection.up,
      hideOnEmpty: true,
      hideOnError: true,
      hideKeyboard: readOnly,
      keepSuggestionsOnSuggestionSelected: true,
      suggestionsBoxDecoration: hasFab
          ? const SuggestionsBoxDecoration(
              shape: AutocompleteCutout(),
              clipBehavior: Clip.antiAlias,
            )
          : const SuggestionsBoxDecoration(),
      textFieldConfiguration: TextFieldConfiguration(
        controller: controller,
        autofocus: true,
        focusNode: focusNode,
        inputFormatters: inputFormatters,
        decoration: decoration?.copyWith(
              labelText: labelText,
            ) ??
            InputDecoration(labelText: labelText),
        onSubmitted: submit,
        textInputAction: textInputAction ?? TextInputAction.search,
      ),
      loadingBuilder: (context) => const SizedBox(),
      noItemsFoundBuilder: (context) => const ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedCircularProgressIndicator(size: 24),
          ],
        ),
      ),
      onSuggestionSelected: onSuggestionSelected,
      itemBuilder: itemBuilder,
      suggestionsCallback: suggestionsCallback,
    );
  }
}

/// A [ShapeBorder] that cuts out a half circle at the top right corner.
///
/// This is used to make space for a [FloatingActionButton].
/// This is a crude implementation and does not respect different [FloatingActionButton] positions or sizes.
class AutocompleteCutout extends ShapeBorder {
  const AutocompleteCutout({this.usePadding = true});

  final bool usePadding;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Size size = rect.size;
    const double edgeDistance = 3.5;
    double width = 62;
    double padding = 4;
    double start = size.width - (edgeDistance - padding);

    return Path.combine(
      PathOperation.difference,
      Path()
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(start, size.height)
        ..lineTo(0, size.height)
        ..lineTo(0, 0),
      Path()
        ..addOval(
          Rect.fromCircle(
            center:
                Offset(start - (width / 2) - edgeDistance, size.height + 5.5),
            radius: width / 2,
          ),
        )
        ..close(),
    );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
