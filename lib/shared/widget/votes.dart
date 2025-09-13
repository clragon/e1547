import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:like_button/like_button.dart';

part 'votes.freezed.dart';
part 'votes.g.dart';

@freezed
abstract class VoteInfo with _$VoteInfo {
  const factory VoteInfo({
    required int score,
    @Default(VoteStatus.unknown) VoteStatus status,
  }) = _VoteInfo;

  const VoteInfo._();

  factory VoteInfo.fromJson(Map<String, dynamic> json) =>
      _$VoteInfoFromJson(json);

  VoteInfo withVote(bool upvote, [bool replace = false]) => switch (upvote) {
    true => switch (status) {
      VoteStatus.upvoted =>
        replace ? this : copyWith(score: score - 1, status: VoteStatus.unknown),
      VoteStatus.downvoted => copyWith(
        score: score + 2,
        status: VoteStatus.upvoted,
      ),
      VoteStatus.unknown => copyWith(
        score: score + 1,
        status: VoteStatus.upvoted,
      ),
    },
    false => switch (status) {
      VoteStatus.upvoted => copyWith(
        score: score - 2,
        status: VoteStatus.downvoted,
      ),
      VoteStatus.downvoted =>
        replace ? this : copyWith(score: score + 1, status: VoteStatus.unknown),
      VoteStatus.unknown => copyWith(
        score: score - 1,
        status: VoteStatus.downvoted,
      ),
    },
  };
}

enum VoteStatus { upvoted, unknown, downvoted }

typedef VoteRequest = ({bool upvote, bool replace});

@freezed
abstract class VoteResult with _$VoteResult {
  const factory VoteResult({required int score, required int ourScore}) =
      _VoteResult;

  factory VoteResult.fromJson(Map<String, dynamic> json) =>
      _$VoteResultFromJson(json);
}

extension VoteResultInfoExtension on VoteResult {
  VoteInfo get info => VoteInfo(
    score: score,
    status: switch (ourScore) {
      1 => VoteStatus.upvoted,
      -1 => VoteStatus.downvoted,
      _ => VoteStatus.unknown,
    },
  );
}

class VoteDisplay extends StatelessWidget {
  const VoteDisplay({
    super.key,
    required this.status,
    required this.score,
    this.onUpvote,
    this.onDownvote,
    this.padding,
  });

  final VoteStatus status;
  final int score;
  final void Function(bool isVoted)? onUpvote;
  final void Function(bool isVoted)? onDownvote;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkResponse(
          onTap: onUpvote != null ? () {} : null,
          child: LikeButton(
            isLiked: status == VoteStatus.upvoted,
            circleColor: const CircleColor(
              start: Colors.orange,
              end: Colors.amber,
            ),
            bubblesColor: const BubblesColor(
              dotPrimaryColor: Colors.amber,
              dotSecondaryColor: Colors.orange,
              dotThirdColor: Colors.deepOrange,
              dotLastColor: Colors.redAccent,
            ),
            likeBuilder: (bool isLiked) => Icon(
              Icons.arrow_upward,
              color: isLiked ? Colors.deepOrange : null,
            ),
            onTap: (isLiked) async {
              onUpvote?.call(isLiked);
              return null;
            },
          ),
        ),
        Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            score.toString(),
            style: TextStyle(
              color: switch (status) {
                VoteStatus.upvoted => Colors.deepOrange,
                VoteStatus.downvoted => Colors.blue,
                VoteStatus.unknown => null,
              },
            ),
          ),
        ),
        InkResponse(
          onTap: onDownvote != null ? () {} : null,
          child: LikeButton(
            isLiked: status == VoteStatus.downvoted,
            circleColor: const CircleColor(
              start: Colors.blue,
              end: Colors.cyanAccent,
            ),
            bubblesColor: const BubblesColor(
              dotPrimaryColor: Colors.cyanAccent,
              dotSecondaryColor: Colors.blue,
              dotThirdColor: Colors.indigoAccent,
              dotLastColor: Colors.indigo,
            ),
            likeBuilder: (bool isLiked) =>
                Icon(Icons.arrow_downward, color: isLiked ? Colors.blue : null),
            onTap: (isLiked) async {
              onDownvote?.call(isLiked);
              return null;
            },
          ),
        ),
      ],
    );
  }
}
