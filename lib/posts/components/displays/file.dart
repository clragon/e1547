import 'package:e1547/posts/post.dart';
import 'package:e1547/posts/posts_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FileDisplay extends StatelessWidget {
  final Post post;

  const FileDisplay(this.post);

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('dd.MM.yy HH:mm');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            right: 4,
            left: 4,
            top: 2,
            bottom: 2,
          ),
          child: Text(
            'File',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            right: 4,
            left: 4,
            top: 2,
            bottom: 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(ratings[post.rating.value]),
              Text(
                  '${post.image.value.file['width']} x ${post.image.value.file['height']}'),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            right: 4,
            left: 4,
            top: 2,
            bottom: 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(dateFormat.format(DateTime.parse(post.creation).toLocal())),
              Text(formatBytes(post.image.value.file['size'], 1)),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            right: 4,
            left: 4,
            top: 2,
            bottom: 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              post.updated != null
                  ? Text(
                      dateFormat.format(DateTime.parse(post.updated).toLocal()))
                  : Container(),
              InkWell(
                  child: Text(post.image.value.file['ext']),
                  onTap: () =>
                      Navigator.of(context).push(MaterialPageRoute<Null>(
                        builder: (context) => SearchPage(
                            tags: 'type:${post.image.value.file['ext']}'),
                      ))),
            ],
          ),
        ),
        Divider(),
      ],
    );
  }
}
