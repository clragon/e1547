import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';

class FileDisplay extends StatelessWidget {
  const FileDisplay({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Text(
            'File',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TagGesture(
                tag: 'rating:${post.rating.name}',
                child: Text(post.rating.title),
              ),
              Text('${post.file.width} x ${post.file.height}'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatDateTime(post.createdAt.toLocal())),
              Text(filesize(post.file.size, 1)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (post.updatedAt != null)
                Text(formatDateTime(post.updatedAt!.toLocal())),
              TagGesture(
                tag: 'type:${post.file.ext}',
                child: Text(post.file.ext),
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}
