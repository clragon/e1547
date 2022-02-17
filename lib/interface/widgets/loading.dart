import 'package:e1547/client/client.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/topic/topic.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';

class PostLoadingPage extends StatefulWidget {
  final int id;

  const PostLoadingPage(this.id);

  @override
  _PostLoadingPageState createState() => _PostLoadingPageState();
}

class _PostLoadingPageState extends State<PostLoadingPage> {
  late Future<Post> post = client.post(widget.id);

  @override
  Widget build(BuildContext context) {
    return FuturePageLoader<Post>(
      future: post,
      builder: (context, value) => PostDetail(post: value),
      title: Text('Post #${widget.id}'),
      onLoading: Text('Loading post'),
      onError: Text('Failed to load post'),
      onEmpty: Text('Invalid post id'),
    );
  }
}

class CommentLoadingPage extends StatefulWidget {
  final int id;

  const CommentLoadingPage(this.id);

  @override
  _CommentLoadingPageState createState() => _CommentLoadingPageState();
}

class _CommentLoadingPageState extends State<CommentLoadingPage> {
  late Future<Comment> comment = client.comment(widget.id);

  @override
  Widget build(BuildContext context) {
    return FuturePageLoader<Comment>(
      future: comment,
      builder: (context, value) => CommentsPage(postId: value.postId),
      title: Text('Comment #${widget.id}'),
      onLoading: Text('Loading comment'),
      onError: Text('Failed to load comment'),
      onEmpty: Text('Invalid comment id'),
    );
  }
}

class PoolLoadingPage extends StatefulWidget {
  final int id;

  const PoolLoadingPage(this.id);

  @override
  _PoolLoadingPageState createState() => _PoolLoadingPageState();
}

class _PoolLoadingPageState extends State<PoolLoadingPage> {
  late Future<Pool> pool = client.pool(widget.id);

  @override
  Widget build(BuildContext context) {
    return FuturePageLoader<Pool>(
      future: pool,
      builder: (context, value) => PoolPage(pool: value),
      title: Text('Pool #${widget.id}'),
      onLoading: Text('Loading pool'),
      onError: Text('Failed to load pool'),
      onEmpty: Text('Invalid pool id'),
    );
  }
}

class TopicLoadingPage extends StatefulWidget {
  final int id;
  final bool orderByOldest;

  const TopicLoadingPage(this.id, {this.orderByOldest = true});

  @override
  _TopicLoadingPageState createState() => _TopicLoadingPageState();
}

class _TopicLoadingPageState extends State<TopicLoadingPage> {
  late Future<Topic> topic = client.topic(widget.id);

  @override
  Widget build(BuildContext context) {
    return FuturePageLoader<Topic>(
      future: topic,
      builder: (context, value) => RepliesPage(
        topic: value,
        orderByOldest: widget.orderByOldest,
      ),
      title: Text('Topic #${widget.id}'),
      onLoading: Text('Loading topic'),
      onError: Text('Failed to load topic'),
      onEmpty: Text('Invalid topic id'),
    );
  }
}

class ReplyLoadingPage extends StatefulWidget {
  final int id;

  const ReplyLoadingPage(this.id);

  @override
  _ReplyLoadingPageState createState() => _ReplyLoadingPageState();
}

class _ReplyLoadingPageState extends State<ReplyLoadingPage> {
  late Future<Reply> reply = client.reply(widget.id);

  @override
  Widget build(BuildContext context) {
    return FuturePageLoader<Reply>(
      future: reply,
      builder: (context, value) => TopicLoadingPage(value.topicId),
      title: Text('Reply #${widget.id}'),
      onLoading: Text('Loading reply'),
      onError: Text('Failed to load reply'),
      onEmpty: Text('Invalid reply id'),
    );
  }
}

class UserLoadingPage extends StatefulWidget {
  final String id;
  final Post? avatar;
  final UserPageSection initalPage;

  const UserLoadingPage(
    this.id, {
    this.avatar,
    this.initalPage = UserPageSection.Favorites,
  });

  @override
  _UserLoadingPageState createState() => _UserLoadingPageState();
}

class _UserLoadingPageState extends State<UserLoadingPage> {
  late Future<User> user = client.user(widget.id.toString());

  @override
  Widget build(BuildContext context) {
    return FuturePageLoader<User>(
      future: user,
      builder: (context, value) => UserPage(
        user: value,
        avatar: widget.avatar,
        initialPage: widget.initalPage,
      ),
      title: Text('User #${widget.id}'),
      onLoading: Text('Loading user'),
      onError: Text('Failed to load user'),
      onEmpty: Text('Invalid user id'),
    );
  }
}
