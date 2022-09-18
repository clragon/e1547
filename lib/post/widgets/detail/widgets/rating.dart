import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

extension ExtraRatingData on Rating {
  Widget get icon {
    switch (this) {
      case Rating.s:
        return const Icon(Icons.check);
      case Rating.q:
        return const Icon(Icons.help);
      case Rating.e:
        return const Icon(Icons.warning);
    }
  }

  String get title {
    switch (this) {
      case Rating.s:
        return 'Safe';
      case Rating.q:
        return 'Questionable';
      case Rating.e:
        return 'Explicit';
    }
  }
}

class RatingDisplay extends StatelessWidget {
  const RatingDisplay({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    PostEditingController? editingController =
        context.watch<PostEditingController?>();

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
            const Padding(
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
              title: Text(rating.title),
              leading: !post.flags.ratingLocked
                  ? rating.icon
                  : const Icon(Icons.lock),
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
            const Divider(),
          ],
        );
      },
    );
  }
}

class RatingDialog extends StatelessWidget {
  const RatingDialog({required this.onTap});

  final void Function(Rating rating) onTap;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Rating'),
      children: Rating.values
          .map(
            (rating) => ListTile(
              title: Text(rating.title),
              leading: rating.icon,
              onTap: () {
                onTap(rating);
                Navigator.of(context).maybePop();
              },
            ),
          )
          .toList(),
    );
  }
}
