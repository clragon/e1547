import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

Map<Rating, IconData> ratingIcons = {
  Rating.S: Icons.check,
  Rating.Q: Icons.help,
  Rating.E: Icons.warning,
};

Map<Rating, String> ratingTexts = {
  Rating.S: 'Safe',
  Rating.Q: 'Questionable',
  Rating.E: 'Explicit',
};

class RatingDisplay extends StatelessWidget {
  final Post post;

  const RatingDisplay({required this.post});

  @override
  Widget build(BuildContext context) {
    return AnimatedSelector(
      animation: post,
      selector: () => [post.rating],
      builder: (context, child) {
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
              title: Text(ratingTexts[post.rating]!),
              leading: Icon(!post.flags.ratingLocked
                  ? ratingIcons[post.rating]
                  : Icons.lock),
              onTap: !post.flags.ratingLocked
                  ? () => showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return RatingDialog(onTap: (rating) {
                            post.rating = rating;
                            post.notifyListeners();
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
  final Function(Rating rating) onTap;

  const RatingDialog({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('Rating'),
      children: ratingTexts.entries
          .map(
            (entry) => ListTile(
              title: Text(entry.value),
              leading: Icon(ratingIcons[entry.key]),
              onTap: () {
                onTap(entry.key);
                Navigator.of(context).pop();
              },
            ),
          )
          .toList(),
    );
  }
}
