import 'dart:async';

import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

typedef SubmitString = FutureOr<void> Function(String result);

class ControlledTextWrapper extends StatefulWidget {
  const ControlledTextWrapper({
    super.key,
    required this.submit,
    required this.actionController,
    required this.builder,
    this.textController,
  });

  final SubmitString submit;
  final TextEditingController? textController;
  final ActionController actionController;
  final Widget Function(
    BuildContext context,
    TextEditingController controller,
    SubmitString submit,
  ) builder;

  @override
  State<ControlledTextWrapper> createState() => _ControlledTextWrapperState();
}

class _ControlledTextWrapperState extends State<ControlledTextWrapper> {
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();
    textController = widget.textController ?? TextEditingController();
    textController.setFocusToEnd();
    widget.actionController
        .setAction(() async => widget.submit(textController.text));
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
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
  const ControlledTextField({
    super.key,
    required this.actionController,
    required this.submit,
    this.labelText,
    this.textController,
  });

  final String? labelText;
  final SubmitString submit;
  final TextEditingController? textController;
  final ActionController actionController;

  @override
  Widget build(BuildContext context) {
    return ControlledTextWrapper(
      submit: submit,
      textController: textController,
      actionController: actionController,
      builder: (context, controller, submit) => TextField(
        controller: controller,
        autofocus: true,
        keyboardType: TextInputType.text,
        onSubmitted: submit,
        decoration: InputDecoration(labelText: labelText),
        enabled: !actionController.isLoading,
      ),
    );
  }
}
