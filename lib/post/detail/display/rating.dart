import 'package:e1547/post.dart';
import 'package:flutter/material.dart';

IconData getIcon(String rating) {
  switch (rating) {
    case 's':
      return Icons.check_circle_outline;
    case 'q':
      return Icons.help_outline;
    case 'e':
      return Icons.warning;
    default:
      return Icons.error_outline;
  }
}

Map<String, String> ratings = {
  's': 'Safe',
  'q': 'Questionable',
  'e': 'Explicit',
};

class RatingDisplay extends StatelessWidget {
  final Post post;

  RatingDisplay({@required this.post});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: post.rating,
      builder: (BuildContext context, String value, Widget child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                right: 4,
                left: 4,
                top: 2,
                bottom: 2,
              ),
              child: Text(
                'Rating',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            ListTile(
              title: Text(ratings[value]),
              leading: Icon(!post.raw['flags']['rating_locked']
                  ? getIcon(value)
                  : Icons.lock),
              onTap: !post.raw['flags']['rating_locked']
                  ? () => showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return RatingDialog(onTap: (rating) {
                            post.rating.value = rating;
                          });
                        },
                      )
                  : null,
            ),
            Divider(),
          ],
        );
      },
    );
  }
}

class RatingDialog extends StatelessWidget {
  final Function(String rating) onTap;

  RatingDialog({@required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Rating'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: ratings.entries
            .map((entry) => ListTile(
                  title: Text(entry.value),
                  leading: Icon(getIcon(entry.key)),
                  onTap: () {
                    onTap(entry.key);
                    Navigator.of(context).pop();
                  },
                ))
            .toList(),
      ),
    );
  }
}
