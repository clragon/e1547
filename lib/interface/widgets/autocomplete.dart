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
  final ValueSetter<T> onSelected;
  final Widget Function(BuildContext context, T value) itemBuilder;
  final FutureOr<List<T>> Function(String search) suggestionsCallback;

  @override
  Widget build(BuildContext context) {
    bool hasFab = Scaffold.maybeOf(context)?.hasFloatingActionButton ?? false;
    return TypeAheadField<T>(
      hideOnEmpty: true,
      hideOnSelect: false,
      builder: (context, controller, focusNode) {
        return TextField(
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
        );
      },
      decorationBuilder: (context, child) {
        if (hasFab) {
          return const ClipRect(
            clipBehavior: Clip.antiAlias,
            child: DecoratedBox(
              decoration: ShapeDecoration(
                shape: AutocompleteCutout(),
              ),
            ),
          );
        }
        return child;
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
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Size size = rect.size;
    double edgeDistance = 16;
    double padding = 2;
    double offset = 5.5;
    double width = 56;
    double radius = width / 2;

    return Path.combine(
      PathOperation.difference,
      Path()
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..lineTo(0, 0),
      Path()
        ..addOval(
          Rect.fromCircle(
            center: Offset(
                size.width - radius - edgeDistance, size.height + offset),
            radius: radius + padding,
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
