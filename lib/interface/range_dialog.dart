import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RangeDialog extends StatefulWidget {
  final Widget title;
  final int value;
  final int max;
  final int min;
  final int division;
  final bool strict;
  final Function(int value) onSubmit;

  RangeDialog({
    @required this.title,
    @required this.onSubmit,
    this.min = 0,
    this.value = 0,
    this.max,
    this.division,
    this.strict = false,
  });

  @override
  _RangeDialogState createState() => _RangeDialogState();
}

class _RangeDialogState extends State<RangeDialog> {
  final TextEditingController controller = TextEditingController();
  int value;

  @override
  void initState() {
    super.initState();
    value = widget.value;
    controller.addListener(() {
      value = int.tryParse(controller.text) ?? value;
    });
  }

  void submit(String output) {
    widget.onSubmit(int.tryParse(output));
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    Widget numberWidget() {
      controller.text = value.toString();
      FocusScope.of(context).requestFocus(FocusNode());

      return Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: TextField(
          keyboardType: TextInputType.number,
          style: TextStyle(fontSize: 48),
          textAlign: TextAlign.center,
          decoration: InputDecoration(border: InputBorder.none),
          controller: controller,
          onSubmitted: submit,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      );
    }

    Widget sliderWidget() {
      return Slider(
          min: min(widget.min, value).toDouble(),
          max: max(widget.max, value).toDouble(),
          divisions: widget.division,
          value: value.toDouble(),
          activeColor: Theme.of(context).accentColor,
          onChanged: (output) {
            setState(() => value = output.toInt());
          });
    }

    return AlertDialog(
      title: widget.title,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          numberWidget(),
          sliderWidget(),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text('cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('save'),
          onPressed: () => submit(controller.text),
        ),
      ],
    );
  }
}
