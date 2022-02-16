import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class ControlledTextWrapper extends StatefulWidget {
  final SubmitString submit;
  final TextEditingController? textController;
  final ActionController actionController;
  final Widget Function(
    BuildContext context,
    TextEditingController controller,
    SubmitString submit,
  ) builder;

  const ControlledTextWrapper({
    required this.submit,
    required this.actionController,
    required this.builder,
    this.textController,
  });

  @override
  _ControlledTextWrapperState createState() => _ControlledTextWrapperState();
}

class _ControlledTextWrapperState extends State<ControlledTextWrapper> {
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();
    textController = widget.textController ?? TextEditingController();
    setFocusToEnd(textController);
    widget.actionController
        .setAction(() async => widget.submit(textController.text));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.actionController,
      builder: (context, child) => widget.builder(
        context,
        textController,
        (_) => widget.actionController.action!(),
      ),
    );
  }
}

class ControlledTextField extends StatelessWidget {
  final String? labelText;
  final SubmitString submit;
  final TextEditingController? textController;
  final ActionController actionController;

  const ControlledTextField({
    required this.actionController,
    required this.submit,
    this.labelText,
    this.textController,
  });

  @override
  Widget build(BuildContext context) {
    return ControlledTextWrapper(
      submit: submit,
      textController: textController,
      actionController: actionController,
      builder: (context, controller, submit) => TextField(
        controller: controller,
        autofocus: true,
        maxLines: 1,
        keyboardType: TextInputType.text,
        onSubmitted: submit,
        decoration: InputDecoration(labelText: labelText),
        enabled: !actionController.isLoading,
      ),
    );
  }
}
