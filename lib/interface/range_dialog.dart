import 'dart:math';

import 'package:flutter/material.dart';

class RangeDialog extends StatefulWidget {
  RangeDialog({this.title, this.value, this.max, this.min, this.division});

  final Widget title;
  final int value;
  final int max;
  final int min;
  final int division;

  @override
  _RangeDialogState createState() => _RangeDialogState();
}

class _RangeDialogState extends State<RangeDialog> {
  final TextEditingController _controller = TextEditingController();
  int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    Widget numberWidget() {
      _controller.text = _value.toString();
      FocusScope.of(context)
          .requestFocus(FocusNode()); // Clear text entry focus, if any.

      Widget number = TextField(
        keyboardType: TextInputType.number,
        style: TextStyle(fontSize: 48.0),
        textAlign: TextAlign.center,
        decoration: InputDecoration(border: InputBorder.none),
        controller: _controller,
        onSubmitted: (v) => Navigator.of(context).pop(int.parse(v)),
      );

      return Container(
        padding: EdgeInsets.only(bottom: 20.0),
        child: number,
      );
    }

    Widget sliderWidget() {
      return Slider(
          min: min(widget.min != null ? widget.min.toDouble() : 0.0,
              _value.toDouble()),
          max: max(widget.max.toDouble(), _value.toDouble()),
          divisions: widget.division,
          value: _value.toDouble(),
          activeColor: Theme.of(context).accentColor,
          onChanged: (v) {
            setState(() => _value = v.toInt());
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
          onPressed: () {
            int textValue = int.parse(_controller.text);
            Navigator.of(context).pop(textValue ?? _value);
          },
        ),
      ],
    );
  }
}
