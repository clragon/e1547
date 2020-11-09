import 'package:e1547/interface/input_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TagListDialog extends StatefulWidget {
  final Widget title;
  final String inital;
  final Future<String> Function(String) onSubmit;
  final List<TextInputFormatter> inputFormatters;

  const TagListDialog({
    @required this.title,
    @required this.onSubmit,
    this.inital,
    this.inputFormatters,
  });

  @override
  _TagListDialogState createState() => _TagListDialogState();
}

class _TagListDialogState extends State<TagListDialog> {
  bool loading = false;
  TextEditingController controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller = TextEditingController(text: widget.inital);
  }

  @override
  Widget build(BuildContext context) {
    return InputDialog(
        title: widget.title,
        builder: (context, loading, error, submit) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType: TextInputType.multiline,
                inputFormatters: widget.inputFormatters ?? [],
                maxLines: null,
                onSubmitted: (_) => submit(),
              ),
              ErrorDisplay(error: error),
            ],
          );
        },
        onSubmit: () => widget.onSubmit(controller.text));
  }
}
