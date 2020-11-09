import 'package:flutter/material.dart';

import 'cross_fade.dart';

class InputDialog extends StatefulWidget {
  final Widget title;
  final Widget Function(BuildContext context, bool loading, String error,
      void Function() submit) builder;
  final Future<String> Function() onSubmit;

  const InputDialog(
      {@required this.title, @required this.builder, @required this.onSubmit});

  @override
  _InputDialogState createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  bool loading = false;
  String error;

  @override
  Widget build(BuildContext context) {
    void submit() async {
      setState(() {
        error = null;
        loading = true;
      });
      error = await widget.onSubmit();
      if (error == null) {
        Navigator.of(context).pop();
      }
      setState(() {
        loading = false;
      });
    }

    return AlertDialog(
      title: widget.title,
      content: widget.builder(context, loading, error, submit),
      actions: <Widget>[
        FlatButton(
          child: Text('CANCEL'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text('OK'),
          onPressed: submit,
        ),
      ],
    );
  }
}

class ErrorDisplay extends StatelessWidget {
  final String error;

  const ErrorDisplay({@required this.error});

  @override
  Widget build(BuildContext context) {
    return CrossFade(
      duration: Duration(milliseconds: 200),
      showChild: error != null,
      child: Padding(
        padding: EdgeInsets.only(top: 8),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              size: 16,
              color: Theme.of(context).errorColor,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                error ?? '',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).errorColor,
                ),
              ),
            )
          ],
        ),
      ),
      secondChild: Container(),
    );
  }
}
