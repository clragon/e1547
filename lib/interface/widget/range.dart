import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum NumberComparison {
  lessThan,
  lessThanOrEqual,
  greaterThan,
  greaterThanOrEqual
}

/// Specifies a range of numbers.
///
/// The range can be specified in one of the following formats:
///  - `value` - A single number.
///  - `<value` - A number less than the given value.
///  - `<=value` - A number less than or equal to the given value.
///  - `>value` - A number greater than the given value.
///  - `>=value` - A number greater than or equal to the given value.
///  - `value..endValue` - A range of numbers between the given values.
class NumberRange {
  const NumberRange(
    this.value, {
    this.endValue,
    this.comparison,
  })  : assert(
          endValue == null || endValue >= value,
          'End value cannot be less than start value.',
        ),
        assert(
          comparison == null || endValue == null,
          'Cannot specify both comparison and end value.',
        );

  final int value;
  final NumberComparison? comparison;
  final int? endValue;

  static RegExp pattern = RegExp(
      r'^(?<operator>[><]=?)?\s*(?<value>\d+)(?:\.\.(?<endValue>\d+))?$');

  @override
  String toString() {
    if (endValue != null) {
      return '$value..$endValue';
    }
    switch (comparison) {
      case NumberComparison.lessThan:
        return '<$value';
      case NumberComparison.lessThanOrEqual:
        return '<=$value';
      case NumberComparison.greaterThan:
        return '>$value';
      case NumberComparison.greaterThanOrEqual:
        return '>=$value';
      case null:
        return '$value';
    }
  }

  /// Returns true if the given number satisfies the range.
  bool has(num num) {
    if (endValue != null) {
      return num > value && num < endValue!;
    }

    switch (comparison) {
      case NumberComparison.lessThan:
        return num < value;
      case NumberComparison.lessThanOrEqual:
        return num <= value;
      case NumberComparison.greaterThan:
        return num > value;
      case NumberComparison.greaterThanOrEqual:
        return num >= value;
      case null:
        return num == value;
    }
  }

  /// Returns a new NumberRange where [value] and [endValue] are ensured to be within [lower] and [upper].
  NumberRange clamp(int? lower, int? upper) {
    return NumberRange(
      value.clamp(lower ?? value, upper ?? value),
      endValue: endValue?.clamp(lower ?? endValue!, upper ?? endValue!),
      comparison: comparison,
    );
  }

  /// Creates a NumberRange from a string.
  static NumberRange parse(String input) {
    final match = pattern.firstMatch(input);

    if (match != null) {
      final operator = match.namedGroup('operator');
      final value = int.parse(match.namedGroup('value')!);

      final endValueStr = match.namedGroup('endValue');
      if (endValueStr != null) {
        final endValue = int.parse(endValueStr);
        if (endValue < value) {
          throw FormatException(
            'End value cannot be less than start value',
            input,
          );
        }
        return NumberRange(value, endValue: endValue);
      }

      switch (operator) {
        case '<=':
          return NumberRange(value,
              comparison: NumberComparison.lessThanOrEqual);
        case '<':
          return NumberRange(value, comparison: NumberComparison.lessThan);
        case '>=':
          return NumberRange(value,
              comparison: NumberComparison.greaterThanOrEqual);
        case '>':
          return NumberRange(value, comparison: NumberComparison.greaterThan);
        default:
          return NumberRange(value);
      }
    } else {
      throw FormatException(
        'Invalid NumberRange format',
        input,
      );
    }
  }

  /// Creates a NumberRange from a string, or returns null if the string is invalid.
  static NumberRange? tryParse(String input) {
    try {
      return NumberRange.parse(input);
    } on FormatException {
      return null;
    }
  }
}

class NumberRangeInputFormatter extends FilteringTextInputFormatter {
  NumberRangeInputFormatter({
    this.min,
    this.max,
  }) : super.allow(
          RegExp(r'^([><]=?(\d+)?)|((\d+)\.?\.?(\d+)?)$'),
        );

  final double? min;
  final double? max;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    NumberRange? newRange = NumberRange.tryParse(newValue.text);

    if (newRange != null) {
      return newValue.copyWith(
        text: newRange.clamp(min?.toInt(), max?.toInt()).toString(),
      );
    }

    return newValue;
  }
}

enum RangeDialogMode {
  exact,
  smallerOrEqual,
  greaterOrEqual,
  fixedRange;

  static RangeDialogMode fromComparison(NumberComparison? comparison) {
    switch (comparison) {
      case null:
        return RangeDialogMode.exact;
      case NumberComparison.lessThan:
        return RangeDialogMode.smallerOrEqual;
      case NumberComparison.lessThanOrEqual:
        return RangeDialogMode.smallerOrEqual;
      case NumberComparison.greaterThan:
        return RangeDialogMode.greaterOrEqual;
      case NumberComparison.greaterThanOrEqual:
        return RangeDialogMode.greaterOrEqual;
    }
  }
}

class RangeDialog extends StatefulWidget {
  const RangeDialog({
    super.key,
    this.value,
    required this.onSubmit,
    this.min = 0,
    required this.max,
    this.division,
    this.title,
    this.enforceMax,
    this.initialMode,
    this.canChangeMode,
  });

  /// The title of the dialog.
  final Widget? title;

  /// The initial value of the dialog.
  final NumberRange? value;

  /// The minimum value of the dialog.
  /// Defaults to 0.
  final double min;

  /// The maximum value of the dialog.
  /// Defaults to 100.
  final double max;

  /// The number of divisions to display in the slider.
  final int? division;

  /// Whether to enforce the maximum value.
  /// If false, the user may enter a value higher than [max].
  /// Defaults to true.
  final bool? enforceMax;

  /// The initial mode of the dialog.
  final RangeDialogMode? initialMode;

  /// Whether the user can change the mode of the dialog.
  final bool? canChangeMode;

  /// Called when the user submits the dialog.
  final ValueChanged<NumberRange?> onSubmit;

  @override
  State<RangeDialog> createState() => _RangeDialogState();
}

class _RangeDialogState extends State<RangeDialog> {
  late final TextEditingController controller =
      TextEditingController(text: widget.value?.toString() ?? '0');
  late RangeDialogMode mode = widget.initialMode ??
      RangeDialogMode.fromComparison(widget.value?.comparison);
  String? errorMessage;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void submit(String output) {
    try {
      NumberRange? range;
      if (output.isNotEmpty) {
        range = NumberRange.parse(output);
      }
      widget.onSubmit(range);
      Navigator.of(context).maybePop();
    } on FormatException {
      setState(() => errorMessage = 'Invalid format');
    }
  }

  double? limitNumber(double? value) {
    if (value == null) return null;
    return min(widget.max, max(widget.min, value));
  }

  double getSliderValue() {
    NumberRange? range = NumberRange.tryParse(controller.text);
    return limitNumber(range?.value.toDouble()) ?? widget.min;
  }

  double getSliderEndValue() {
    NumberRange? range = NumberRange.tryParse(controller.text);
    return min(
      widget.max,
      max(
        limitNumber(range?.value.toDouble()) ?? widget.min,
        limitNumber(range?.endValue?.toDouble()) ?? widget.max,
      ),
    );
  }

  RangeDialogMode getCurrentMode() {
    if (widget.canChangeMode == false) {
      return mode;
    }
    String value = controller.text;
    if (RegExp(r'^\d*$').hasMatch(value)) {
      return RangeDialogMode.exact;
    } else if (RegExp(r'^<\d*$').hasMatch(value)) {
      return RangeDialogMode.smallerOrEqual;
    } else if (RegExp(r'^<=\d*$').hasMatch(value)) {
      return RangeDialogMode.smallerOrEqual;
    } else if (RegExp(r'^>\d*$').hasMatch(value)) {
      return RangeDialogMode.greaterOrEqual;
    } else if (RegExp(r'^>=\d*$').hasMatch(value)) {
      return RangeDialogMode.greaterOrEqual;
    } else if (RegExp(r'^\d*\.\.\d*$').hasMatch(value)) {
      return RangeDialogMode.fixedRange;
    } else {
      return RangeDialogMode.exact;
    }
  }

  String getTextValue() {
    NumberRange currentRange = NumberRange.tryParse(controller.text) ??
        NumberRange(widget.min.toInt());

    switch (mode) {
      case RangeDialogMode.exact:
        return NumberRange(currentRange.value).toString();
      case RangeDialogMode.smallerOrEqual:
        return NumberRange(currentRange.value,
                comparison: NumberComparison.lessThanOrEqual)
            .toString();
      case RangeDialogMode.greaterOrEqual:
        return NumberRange(currentRange.value,
                comparison: NumberComparison.greaterThanOrEqual)
            .toString();
      case RangeDialogMode.fixedRange:
        int endValue = currentRange.endValue ?? widget.max.toInt();
        return NumberRange(currentRange.value, endValue: endValue).toString();
    }
  }

  void setTextByValue(double value, [double? endValue]) {
    NumberRange? updatedRange;

    switch (mode) {
      case RangeDialogMode.exact:
        updatedRange = NumberRange(value.toInt());
        break;
      case RangeDialogMode.smallerOrEqual:
        updatedRange = NumberRange(value.toInt(),
            comparison: NumberComparison.lessThanOrEqual);
        break;
      case RangeDialogMode.greaterOrEqual:
        updatedRange = NumberRange(value.toInt(),
            comparison: NumberComparison.greaterThanOrEqual);
        break;
      case RangeDialogMode.fixedRange:
        updatedRange = NumberRange(value.toInt(), endValue: endValue?.toInt());
        break;
    }

    controller.text = updatedRange.toString();
  }

  Widget _buildComparisonIcon(IconData icon) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 40,
        minHeight: 40,
      ),
      child: Center(
        child: FaIcon(icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.title,
      content: AnimatedBuilder(
        animation: controller,
        builder: (context, child) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  TextField(
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      errorText: errorMessage,
                    ),
                    controller: controller,
                    onChanged: (value) => setState(() {
                      errorMessage = null;
                      mode = getCurrentMode();
                    }),
                    onSubmitted: submit,
                    inputFormatters: [
                      NumberRangeInputFormatter(
                        min: widget.min,
                        max: (widget.enforceMax ?? true) ? widget.max : null,
                      )
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: [
                if (widget.canChangeMode ?? true)
                  DropdownButton<RangeDialogMode>(
                    value: mode,
                    underline: const SizedBox(),
                    icon: const SizedBox(),
                    items: [
                      DropdownMenuItem(
                        value: RangeDialogMode.exact,
                        child: _buildComparisonIcon(FontAwesomeIcons.equals),
                      ),
                      DropdownMenuItem(
                        value: RangeDialogMode.smallerOrEqual,
                        child: _buildComparisonIcon(
                            FontAwesomeIcons.lessThanEqual),
                      ),
                      DropdownMenuItem(
                        value: RangeDialogMode.greaterOrEqual,
                        child: _buildComparisonIcon(
                            FontAwesomeIcons.greaterThanEqual),
                      ),
                      DropdownMenuItem(
                        value: RangeDialogMode.fixedRange,
                        child: _buildComparisonIcon(FontAwesomeIcons.leftRight),
                      ),
                    ],
                    onChanged: (newMode) {
                      if (newMode != null) {
                        setState(() {
                          mode = newMode;
                          controller.text = getTextValue();
                        });
                      }
                    },
                  ),
                Expanded(
                  child: mode == RangeDialogMode.fixedRange
                      ? RangeSlider(
                          values: RangeValues(
                            getSliderValue(),
                            getSliderEndValue(),
                          ),
                          min: widget.min,
                          max: widget.max,
                          divisions: widget.division,
                          onChanged: (values) => setTextByValue(
                            values.start,
                            values.end,
                          ),
                        )
                      : Slider(
                          value: getSliderValue(),
                          min: widget.min,
                          max: widget.max,
                          divisions: widget.division,
                          onChanged: (value) => setTextByValue(value),
                        ),
                )
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).maybePop,
          child: const Text('CANCEL'),
        ),
        TextButton(
          child: const Text('OK'),
          onPressed: () => submit(controller.text),
        ),
      ],
    );
  }
}
