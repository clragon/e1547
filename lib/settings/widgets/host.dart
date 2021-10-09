import 'package:dio/dio.dart';
import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';

Future<void> setCustomHost(BuildContext context) async {
  TextEditingController controller =
      TextEditingController(text: settings.customHost.value);

  Future<void> submit() async {
    String? error;

    String host = linkToDisplay(controller.text);

    Dio dio = Dio(defaultDioOptions);

    if (host.isEmpty) {
      settings.customHost.value = null;
    } else {
      await Future.delayed(Duration(seconds: 1));
      try {
        await dio.get('https://$host');
        switch (host) {
          case 'e621.net':
            settings.customHost.value = host;
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
      throw LoadingDialogException(message: error);
    }
  }

  await showDialog(
    context: context,
    builder: (BuildContext context) => LoadingDialog(
      submit: submit,
      title: Text('Custom Host'),
      builder: (context, submit) => TextField(
        controller: controller,
        keyboardType: TextInputType.url,
        autofocus: true,
        maxLines: 1,
        decoration: InputDecoration(labelText: 'url'),
        onSubmitted: (_) => submit(),
      ),
    ),
  );
}
