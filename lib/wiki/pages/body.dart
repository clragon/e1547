import 'package:async/async.dart';
import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:flutter/material.dart';

class WikiBody extends StatefulWidget {
  final String tag;

  WikiBody({@required this.tag});

  @override
  _WikiBodyState createState() => _WikiBodyState();
}

class _WikiBodyState extends State<WikiBody> {
  final AsyncMemoizer memoizer = AsyncMemoizer();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: memoizer.runOnce(() => client.wiki(widget.tag, 1)),
      builder: (context, snapshot) => CrossFade(
          duration: Duration(milliseconds: 200),
          showChild: snapshot.connectionState == ConnectionState.done,
          child: () {
            if (snapshot.data == null) {
              return Text('unable to retrieve wiki entry',
                  style: TextStyle(fontStyle: FontStyle.italic));
            }
            if (snapshot.data.length != 0) {
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DTextField(msg: snapshot.data[0]['body']),
                physics: BouncingScrollPhysics(),
              );
            } else {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'no wiki entry',
                    style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .color
                            .withOpacity(0.5),
                        fontStyle: FontStyle.italic),
                  )
                ],
              );
            }
          }(),
          secondChild: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                      padding: EdgeInsets.all(16),
                      child: Container(
                        height: 26,
                        width: 26,
                        child: CircularProgressIndicator(),
                      ))
                ],
              ),
            ],
          )),
    );
  }
}
