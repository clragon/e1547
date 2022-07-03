import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';

class FileDisplay extends StatelessWidget {
  final PostController post;

  const FileDisplay({required this.post});

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
                tag: 'rating:${post.value.rating.name}',
                controller: post.parent,
                child: Text(ratingTexts[post.value.rating]!),
              ),
              Text('${post.value.file.width} x ${post.value.file.height}'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(getCurrentDateTimeFormat()
                  .format(post.value.createdAt.toLocal())),
              Text(filesize(post.value.file.size, 1)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (post.value.updatedAt != null)
                Text(getCurrentDateTimeFormat()
                    .format(post.value.updatedAt!.toLocal())),
              TagGesture(
                tag: 'type:${post.value.file.ext}',
                controller: post.parent,
                child: Text(post.value.file.ext),
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}
