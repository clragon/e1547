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
  final PostEditingController? editingController;

  const RatingDisplay({required this.post, this.editingController});

  @override
  Widget build(BuildContext context) {
    return AnimatedSelector(
      animation: Listenable.merge([editingController]),
      selector: () => [editingController?.isEditing, editingController?.rating],
      builder: (context, child) {
        Rating rating = editingController?.rating ?? post.rating;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 2,
              ),
              child: Text(
                'Rating',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            ListTile(
              title: Text(ratingTexts[rating]!),
              leading: Icon(
                  !post.flags.ratingLocked ? ratingIcons[rating] : Icons.lock),
              onTap: (editingController?.isEditing ?? false) &&
                      !post.flags.ratingLocked
                  ? () => showDialog(
                        context: context,
                        builder: (context) => RatingDialog(
                          onTap: (value) => editingController!.rating = value,
                        ),
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
  final void Function(Rating rating) onTap;

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
                Navigator.of(context).maybePop();
              },
            ),
          )
          .toList(),
    );
  }
}
