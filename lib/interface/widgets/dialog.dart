import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

class LoadingDialogException implements Exception {
  final String message;

  LoadingDialogException({required this.message});
}

class LoadingDialog extends StatefulWidget {
  final Widget? title;
  final Future<void> Function() submit;
  final Widget Function(
    BuildContext context,
    Future<void> Function() submit,
  ) builder;

  const LoadingDialog({
    this.title,
    required this.submit,
    required this.builder,
  });

  @override
  _LoadingDialogState createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog> {
  bool success = false;
  bool isLoading = false;
  LoadingDialogException? error;

  Future<void> submit() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      await widget.submit();
    } on LoadingDialogException catch (e) {
      error = e;
    }
    setState(() {
      isLoading = false;
    });
    if (error == null) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.title,
      content: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CrossFade(
                  showChild: isLoading,
                  child: Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: SizedCircularProgressIndicator(size: 16),
                  ),
                ),
                Expanded(
                  child: widget.builder(context, submit),
                ),
              ],
            ),
            SafeCrossFade(
              showChild: error != null,
              builder: (context) => Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: DefaultTextStyle(
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color: Theme.of(context).errorColor,
                        fontSize: 14,
                      ),
                  child: IconTheme(
                    data: Theme.of(context).iconTheme.copyWith(
                          color: Theme.of(context).errorColor,
                          size: 14,
                        ),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(Icons.error_outline),
                        ),
                        Text(error!.message)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text('CANCEL'),
          onPressed: Navigator.of(context).maybePop,
        ),
        TextButton(
          child: Text('OK'),
          onPressed: submit,
        ),
      ],
    );
  }
}
