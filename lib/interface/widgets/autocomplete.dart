import 'dart:async';

import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class AutocompleteTextField<T> extends StatelessWidget {
  const AutocompleteTextField({
    super.key,
    required this.onSelected,
    required this.suggestionsCallback,
    required this.itemBuilder,
    required this.submit,
    this.controller,
    this.direction,
    this.readOnly = false,
    this.autofocus = true,
    this.private = false,
    this.labelText,
    this.decoration,
    this.textInputAction,
    this.focusNode,
    this.inputFormatters,
  });

  final SubmitString submit;
  final TextEditingController? controller;
  final VerticalDirection? direction;
  final bool readOnly;
  final String? labelText;
  final InputDecoration? decoration;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final ValueSetter<T> onSelected;
  final Widget Function(BuildContext context, T value) itemBuilder;
  final FutureOr<List<T>?> Function(String search) suggestionsCallback;
  final bool autofocus;
  final bool private;

  @override
  Widget build(BuildContext context) {
    bool hasFab = Scaffold.maybeOf(context)?.hasFloatingActionButton ?? false;
    return TypeAheadField<T>(
      controller: controller,
      direction: direction,
      hideOnEmpty: true,
      hideOnSelect: false,
      builder: (context, controller, focusNode) => TextField(
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
        readOnly: readOnly,
        enableIMEPersonalizedLearning: !private,
      ),
      decorationBuilder: (context, child) {
        Widget result = Card(
          margin: EdgeInsets.zero,
          color: Theme.of(context).colorScheme.background,
          child: child,
        );

        if (hasFab) {
          return ClipPath.shape(
            shape: const AutocompleteCutout(),
            child: result,
          );
        }
        return result;
      },
      loadingBuilder: (context) => const ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedCircularProgressIndicator(size: 24),
          ],
        ),
      ),
      errorBuilder: (context, error) => const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconMessage(
            icon: Icon(Icons.error),
            title: Text('Failed to load suggestions'),
          ),
        ],
      ),
      onSelected: onSelected,
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
  const AutocompleteCutout();

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRect(rect);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    const shape = CircularNotchedRectangle();

    Size size = rect.size;
    double edgeDistance = 16;
    double padding = 2;
    double offset = 4;
    double width = 56;
    double radius = width / 2;

    return shape
        .getOuterPath(
          rect,
          Rect.fromCircle(
            center: Offset(size.width - radius - edgeDistance, 0),
            radius: radius + padding,
          ),
        )
        .transform((Matrix4.diagonal3Values(1, -1, 1)
              ..translate(0.0, -size.height - offset))
            .storage);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
