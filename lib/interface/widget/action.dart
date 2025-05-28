import 'dart:async';

import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sub/flutter_sub.dart';

typedef SubmitString = FutureOr<void> Function(String result);

class ControlledTextWrapper extends StatelessWidget {
  const ControlledTextWrapper({
    super.key,
    required this.submit,
    required this.builder,
    this.actionController,
    this.textController,
  });

  final SubmitString submit;
  final TextEditingController? textController;
  final PromptActionController? actionController;
  final Widget Function(
    BuildContext context,
    TextEditingController controller,
    SubmitString submit,
  )
  builder;

  @override
  Widget build(BuildContext context) {
    PromptActionController actionController =
        this.actionController ?? PromptActions.of(context);
    return SubDefault<TextEditingController>(
      value: textController,
      create: () => TextEditingController(),
      builder: (context, textController) => SubEffect(
        effect: () {
          textController.setFocusToEnd();
          actionController.setAction(() => submit(textController.text));
          return null;
        },
        keys: [textController, actionController],
        child: PromptActions(
          controller: actionController,
          child: AnimatedBuilder(
            animation: actionController,
            builder: (context, child) => builder(
              context,
              textController,
              (_) => actionController.action!(),
            ),
          ),
        ),
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
    this.keyboardType,
    this.inputFormatters,
  });

  final String? labelText;
  final SubmitString submit;
  final TextEditingController? textController;
  final PromptActionController actionController;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return ControlledTextWrapper(
      submit: submit,
      textController: textController,
      actionController: actionController,
      builder: (context, controller, submit) => TextField(
        controller: controller,
        enableIMEPersonalizedLearning: !PrivateTextFields.of(context),
        keyboardType: keyboardType,
        autofocus: true,
        inputFormatters: inputFormatters,
        onSubmitted: submit,
        decoration: InputDecoration(
          labelText: labelText,
          suffix: const PromptTextFieldSuffix(),
        ),
        readOnly: actionController.isLoading,
      ),
    );
  }
}
