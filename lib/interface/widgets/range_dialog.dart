import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RangeDialog extends StatefulWidget {
  const RangeDialog({
    required this.title,
    required this.onSubmit,
    this.min = 0,
    this.value = 0,
    required this.max,
    this.division,
    this.strict = false,
  });

  final Widget title;
  final int value;
  final int max;
  final int min;
  final int? division;
  final bool strict;
  final ValueChanged<int?> onSubmit;

  @override
  State<RangeDialog> createState() => _RangeDialogState();
}

class _RangeDialogState extends State<RangeDialog> {
  late final TextEditingController controller =
      TextEditingController(text: widget.value.toString());

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void submit(String output) {
    widget.onSubmit(int.tryParse(output));
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.title,
      content: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          int value = int.tryParse(controller.text) ?? widget.value;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextField(
                  keyboardType: TextInputType.number,
                  style: Theme.of(context).textTheme.displaySmall,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(border: InputBorder.none),
                  controller: controller,
                  onSubmitted: submit,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              Slider(
                min: min(widget.min, value).toDouble(),
                max: max(widget.max, value).toDouble(),
                divisions: widget.division,
                value: value.toDouble(),
                activeColor: Theme.of(context).colorScheme.secondary,
                onChanged: (value) =>
                    controller.text = value.toInt().toString(),
              ),
            ],
          );
        },
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
