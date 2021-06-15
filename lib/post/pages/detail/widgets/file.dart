import 'package:e1547/interface/data/text.dart';
import 'package:e1547/post.dart';
import 'package:e1547/tag.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'rating.dart';

class FileDisplay extends StatelessWidget {
  final Post post;
  final PostProvider provider;
  final DateFormat dateFormat = DateFormat('dd.MM.yy HH:mm');

  FileDisplay({@required this.post, this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            children: [
              TagGesture(
                child: Text(ratings[post.rating.value]),
                tag: 'rating:${post.rating.value}',
                provider: provider,
              ),
              Text('${post.file.value.width} x ${post.file.value.height}'),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dateFormat.format(DateTime.parse(post.creation).toLocal())),
              Text(formatBytes(post.file.value.size, 1)),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (post.updated != null)
                Text(dateFormat.format(DateTime.parse(post.updated).toLocal())),
              TagGesture(
                child: Text(post.file.value.ext),
                tag: 'type:${post.file.value.ext}',
                provider: provider,
              ),
            ],
          ),
        ),
        Divider(),
      ],
    );
  }
}
