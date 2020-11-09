import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class StepWidget extends StatelessWidget {
  final int number;
  final Widget content;

  const StepWidget({@required this.number, @required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(children: [
        Container(
          width: 36.0,
          height: 36.0,
          alignment: Alignment.center,
          child: Text(
            number.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26.0),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 16),
          child: content,
        ),
      ]),
    );
  }
}

class TutorialSteps extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StepWidget(
            number: 1,
            content: FlatButton(
              onPressed: () async {
                launch('https://${await db.host.value}/session/new');
              },
              child: Text(
                'Login via web browser',
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue[400]),
              ),
            )),
        StepWidget(
            number: 2,
            content: Padding(
                padding: EdgeInsets.all(16), child: Text('Enable API Access'))),
        StepWidget(
            number: 3,
            content: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Copy and paste your API key'))),
      ],
    );
  }
}
