import 'package:e1547/post.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

class LikeDisplay extends StatefulWidget {
  final Post post;

  const LikeDisplay({@required this.post});

  @override
  _LikeDisplayState createState() => _LikeDisplayState();
}

class _LikeDisplayState extends State<LikeDisplay> {
  @override
  void initState() {
    super.initState();
    widget.post.voteStatus.addListener(() => setState(() {}));
    widget.post.favorites.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    widget.post.description.removeListener(() => setState(() {}));
    widget.post.favorites.removeListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                LikeButton(
                  isLiked: widget.post.voteStatus.value == VoteStatus.upvoted,
                  likeBuilder: (bool isLiked) {
                    return Icon(
                      Icons.arrow_upward,
                      color: isLiked
                          ? Colors.deepOrange
                          : Theme.of(context).iconTheme.color,
                    );
                  },
                  onTap: (isLiked) async {
                    if (widget.post.isLoggedIn) {
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
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: ValueListenableBuilder(
                    valueListenable: widget.post.score,
                    builder: (context, value, child) {
                      return Text((value ?? 0).toString());
                    },
                  ),
                ),
                LikeButton(
                  isLiked: widget.post.voteStatus.value == VoteStatus.downvoted,
                  circleColor:
                      CircleColor(start: Colors.blue, end: Colors.cyanAccent),
                  bubblesColor: BubblesColor(
                      dotPrimaryColor: Colors.blue,
                      dotSecondaryColor: Colors.cyanAccent),
                  likeBuilder: (bool isLiked) {
                    return Icon(
                      Icons.arrow_downward,
                      color: isLiked
                          ? Colors.blue
                          : Theme.of(context).iconTheme.color,
                    );
                  },
                  onTap: (isLiked) async {
                    if (widget.post.isLoggedIn) {
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
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text((widget.post.favorites.value ?? 0).toString()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.favorite),
                ),
              ],
            )
          ],
        ),
        Divider(),
      ],
    );
  }
}
