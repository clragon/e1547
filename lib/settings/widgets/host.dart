import 'package:dio/dio.dart';
import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> setCustomHost(BuildContext context) async {
  TextEditingController controller =
      TextEditingController(text: context.read<Settings>().customHost.value);

  Future<void> submit() async {
    String? error;

    String host = linkToDisplay(controller.text);

    Dio dio = Dio(defaultDioOptions);

    if (host.isEmpty) {
      context.read<Settings>().customHost.value = null;
    } else {
      await Future.delayed(const Duration(seconds: 1));
      try {
        await dio.get('https://$host');
        switch (host) {
          case 'e621.net':
            context.read<Settings>().customHost.value = host;
            error = null;
            break;
          case 'e926.net':
            error = 'default host cannot be custom host';
            break;
          default:
            error = 'Host API incompatible';
            break;
        }
      } on DioError {
        error = 'Cannot reach host';
      }
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
