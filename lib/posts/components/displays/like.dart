import 'package:e1547/posts/post.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

class Upvote extends StatefulWidget {
  final Post post;

  const Upvote(this.post);

  @override
  _UpvoteState createState() => _UpvoteState();
}

class _UpvoteState extends State<Upvote> {
  @override
  void initState() {
    super.initState();
    widget.post.voteStatus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    widget.post.voteStatus.removeListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return LikeButton(
      isLiked: widget.post.voteStatus.value == VoteStatus.upvoted,
      likeBuilder: (bool isLiked) {
        return Icon(
          Icons.arrow_upward,
          color:
              isLiked ? Colors.deepOrange : Theme.of(context).iconTheme.color,
        );
      },
      onTap: (isLiked) async {
        if (widget.post.isLoggedIn && !widget.post.isDeleted) {
          if (isLiked) {
            tryVote(context, widget.post, true, false);
            return false;
          } else {
            tryVote(context, widget.post, true, true);
            return true;
          }
        } else {
          return false;
        }
      },
    );
  }
}

class Downvote extends StatefulWidget {
  final Post post;

  const Downvote(this.post);

  @override
  _DownvoteState createState() => _DownvoteState();
}

class _DownvoteState extends State<Downvote> {
  @override
  void initState() {
    super.initState();
    widget.post.voteStatus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    widget.post.voteStatus.removeListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return LikeButton(
      isLiked: widget.post.voteStatus.value == VoteStatus.downvoted,
      circleColor: CircleColor(start: Colors.blue, end: Colors.cyanAccent),
      bubblesColor: BubblesColor(
          dotPrimaryColor: Colors.blue, dotSecondaryColor: Colors.cyanAccent),
      likeBuilder: (bool isLiked) {
        return Icon(
          Icons.arrow_downward,
          color: isLiked ? Colors.blue : Theme.of(context).iconTheme.color,
        );
      },
      onTap: (isLiked) async {
        if (widget.post.isLoggedIn && !widget.post.isDeleted) {
          if (isLiked) {
            tryVote(context, widget.post, false, false);
            return false;
          } else {
            tryVote(context, widget.post, false, true);
            return true;
          }
        } else {
          return false;
        }
      },
    );
  }
}

class VoteCount extends StatefulWidget {
  final Post post;

  const VoteCount(this.post);

  @override
  _VoteCountState createState() => _VoteCountState();
}

class _VoteCountState extends State<VoteCount> {
  @override
  void initState() {
    super.initState();
    widget.post.score.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    widget.post.score.removeListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text(widget.post.score.value.toString()),
    );
  }
}

class VoteDisplay extends StatelessWidget {
  final Post post;

  const VoteDisplay(this.post);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Upvote(post),
        VoteCount(post),
        Downvote(post),
      ],
    );
  }
}

class LikeCount extends StatefulWidget {
  final Post post;

  const LikeCount(this.post);

  @override
  _LikeCountState createState() => _LikeCountState();
}

class _LikeCountState extends State<LikeCount> {
  @override
  void initState() {
    super.initState();
    widget.post.favorites.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    widget.post.favorites.removeListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        ValueListenableBuilder(
          valueListenable: widget.post.favorites,
          builder: (context, value, child) {
            return Text(value.toString());
          },
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.favorite),
        ),
      ],
    );
  }
}

class LikeDisplay extends StatelessWidget {
  final Post post;

  const LikeDisplay(this.post);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            VoteDisplay(post),
            LikeCount(post),
          ],
        ),
        Divider(),
      ],
    );
  }
}
