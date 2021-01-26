import 'package:e1547/interface.dart';
import 'package:e1547/thread.dart';
import 'package:flutter/material.dart';

class ThreadPreview extends StatelessWidget {
  final Thread thread;
  final VoidCallback onPressed;

  ThreadPreview(
    this.thread, {
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Widget title() {
      return Row(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
              child: Text(
                thread.title,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                margin: EdgeInsets.only(left: 22, top: 8, bottom: 8, right: 16),
                child: Text(
                  thread.posts.toString(),
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 0,
                  bottom: 8,
                ),
                child: Text(
                  getAge(thread.updated),
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          )
        ],
      );
    }

    return Card(
        child: InkWell(
            onTap: this.onPressed,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Center(child: title()),
                ),
                () {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [],
                  );
                }(),
              ],
            )));
  }
}
