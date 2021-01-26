import 'package:e1547/interface/text_tools.dart';
import 'package:e1547/post.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'rating.dart';

class FileDisplay extends StatelessWidget {
  final Post post;
  final DateFormat dateFormat = DateFormat('dd.MM.yy HH:mm');

  FileDisplay({@required this.post});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Text(
            'File',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(ratings[post.rating.value]),
              Text('${post.file.value.width} x ${post.file.value.height}'),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(dateFormat.format(DateTime.parse(post.creation).toLocal())),
              Text(formatBytes(post.file.value.size, 1)),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              post.updated != null
                  ? Text(
                      dateFormat.format(DateTime.parse(post.updated).toLocal()))
                  : Container(),
              InkWell(
                  child: Text(post.file.value.ext),
                  onTap: () =>
                      Navigator.of(context).push(MaterialPageRoute<Null>(
                        builder: (context) =>
                            SearchPage(tags: 'type:${post.file.value.ext}'),
                      ))),
            ],
          ),
        ),
        Divider(),
      ],
    );
  }
}
