import 'package:e1547/client/client.dart';
import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

Future<void> setCustomHost(BuildContext context) async {
  HostService config = context.read<HostService>();
  TextEditingController controller =
      TextEditingController(text: config.customHost);

  Future<void> submit() async {
    String? error;

    try {
      String host = linkToDisplay(controller.text);
      await config.setCustomHost(host);
    } on CustomHostDefaultException {
      error = 'Custom host cannot be default host';
    } on CustomHostIncompatibleException {
      error = 'Host API incompatible';
    } on CustomHostUnreachableException {
      error = 'Host cannot be reached';
    }

    if (error != null) {
      throw ActionControllerException(message: error);
    }
  }

  await showDialog(
    context: context,
    builder: (context) => LoadingDialog(
      submit: submit,
      title: const Text('Custom Host'),
      builder: (context, actionController) => TextField(
        controller: controller,
        keyboardType: TextInputType.url,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'url'),
        onSubmitted: (_) => actionController.action!(),
        enabled: !actionController.isLoading,
      ),
    ),
  );
}
