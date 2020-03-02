// TODO: do we really need this?

import 'dart:math' as math show max, min;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RangeDialog extends StatefulWidget {
  const RangeDialog({this.title, this.value, this.max, this.min});

  final String title;
  final int value;
  final int max;
  final int min;

  @override
  RangeDialogState createState() => new RangeDialogState();
}

class RangeDialogState extends State<RangeDialog> {
  final TextEditingController _controller = new TextEditingController();
  int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext ctx) {
    Widget numberWidget() {
      _controller.text = _value.toString();
      FocusScope.of(ctx)
          .requestFocus(new FocusNode()); // Clear text entry focus, if any.

      Widget number = new TextField(
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 48.0),
        textAlign: TextAlign.center,
        decoration: const InputDecoration(border: InputBorder.none),
        controller: _controller,
        onSubmitted: (v) => Navigator.of(ctx).pop(int.parse(v)),
      );

      return new Container(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: number,
      );
    }

    Widget sliderWidget() {
      return new Slider(
          min: math.min(widget.min != null ? widget.min.toDouble() : 0.0,
              _value.toDouble()),
          max: math.max(widget.max.toDouble(), _value.toDouble()),
          divisions: 50,
          value: _value.toDouble(),
          activeColor: Colors.cyanAccent,
          onChanged: (v) {
            setState(() => _value = v.toInt());
          });
    }

    Widget buttonsWidget() {
      List<Widget> buttons = [
        new FlatButton(
          child: const Text('cancel'),
          onPressed: () => Navigator.of(ctx).pop(),
        ),
        new RaisedButton(
          child: const Text('save'),
          onPressed: () {
            // We could pop up an error, but using the last known good value
            // works also.
            int textValue = int.parse(_controller.text);
            Navigator.of(ctx).pop(textValue ?? _value);
          },
        ),
      ];

      return new Padding(
        padding: const EdgeInsets.only(top: 20.0, right: 10.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: buttons,
        ),
      );
    }

    return new SimpleDialog(
      title: new Text(widget.title),
      children: [
        numberWidget(),
        sliderWidget(),
        buttonsWidget(),
      ],
    );
  }
}
