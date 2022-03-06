import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

Map<Rating, IconData> ratingIcons = {
  Rating.s: Icons.check,
  Rating.q: Icons.help,
  Rating.e: Icons.warning,
};

Map<Rating, String> ratingTexts = {
  Rating.s: 'Safe',
  Rating.q: 'Questionable',
  Rating.e: 'Explicit',
};

class RatingDisplay extends StatelessWidget {
  final Post post;

  const RatingDisplay({required this.post});

  @override
  Widget build(BuildContext context) {
    PostEditingController? editingController = PostEditor.of(context);

    return AnimatedSelector(
      animation: Listenable.merge([editingController]),
      selector: () => [
        editingController?.canEdit,
        editingController?.value?.rating,
      ],
      builder: (context, child) {
        Rating rating = editingController?.value?.rating ?? post.rating;
        bool canEdit =
            (editingController?.canEdit ?? false) && !post.flags.ratingLocked;
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
              onTap: canEdit
                  ? () => showDialog(
                        context: context,
                        builder: (context) => RatingDialog(
                          onTap: (value) => editingController!.value =
                              editingController.value!.copyWith(rating: value),
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
