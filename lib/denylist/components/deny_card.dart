import 'package:e1547/util/text_helper.dart';
import 'package:e1547/wiki/wiki_page.dart';
import 'package:flutter/material.dart';

class DenyTagCard extends StatelessWidget {
  final String tag;

  const DenyTagCard(this.tag);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: InkWell(
            onTap: () => wikiDialog(context, noDash(tag), actions: true),
            onLongPress: () => wikiDialog(context, noDash(tag), actions: true),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: 24,
                  width: 5,
                  decoration: BoxDecoration(
                    color: () {
                      if ('${tag[0]}' == '-') {
                        return Colors.green[300];
                      } else {
                        return Colors.red[300];
                      }
                    }(),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5),
                        bottomLeft: Radius.circular(5)),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.only(top: 4, bottom: 4, right: 8, left: 6),
                  child: Text(noDash(tag.replaceAll('_', ' '))),
                ),
              ],
            )));
  }
}
