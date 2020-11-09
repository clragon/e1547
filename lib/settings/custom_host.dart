import 'package:e1547/interface/cross_fade.dart';
import 'package:e1547/interface/input_dialog.dart';
import 'package:e1547/services/http.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';

class HostDialog extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Widget progress(bool loading) {
      return CrossFade(
          showChild: loading,
          child: Padding(
            padding: EdgeInsets.only(right: 8),
            child: Padding(
              padding: EdgeInsets.all(4),
              child: Container(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(),
              ),
            ),
          ));
    }

    Widget input(String error, void Function() submit) {
      return Theme(
        data: error != null
            ? Theme.of(context)
                .copyWith(accentColor: Theme.of(context).errorColor)
            : Theme.of(context),
        child: FutureBuilder(
          future: db.customHost.value,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              controller.text = snapshot.data;
              return TextField(
                controller: controller,
                keyboardType: TextInputType.url,
                autofocus: true,
                maxLines: 1,
                decoration: InputDecoration(
                    labelText: 'url', border: UnderlineInputBorder()),
                onSubmitted: (_) => submit(),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      );
    }

    return InputDialog(
        title: Text('Custom Host'),
        builder: (context, loading, error, submit) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  progress(loading),
                  Expanded(child: input(error, submit)),
                ],
              ),
              ErrorDisplay(error: error),
            ],
          );
        },
        onSubmit: () async {
          String error;
          String host = controller.text.trim();
          host = host.replaceAll(RegExp(r'^http(s)?://'), '');
          host = host.replaceAll(RegExp(r'^(www.)?'), '');
          host = host.replaceAll(RegExp(r'/$'), '');
          HttpHelper http = HttpHelper();
          await Future.delayed(Duration(seconds: 1));
          try {
            if ((await http
                .get(host, '/')
                .then((response) => response.statusCode != 200))) {
              error = 'Cannot reach host';
            } else {
              if (host == 'e621.net') {
                db.customHost.value = Future.value(host);
                error = null;
              } else {
                error = 'Host API incompatible';
              }
            }
          } catch (SocketException) {
            error = 'Cannot reach host';
          }
          return error;
        });
  }
}
