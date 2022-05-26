import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';

class UserLoadingPage extends StatefulWidget {
  final String id;
  final UserPageSection initalPage;

  const UserLoadingPage(
    this.id, {
    this.initalPage = UserPageSection.favorites,
  });

  @override
  State<UserLoadingPage> createState() => _UserLoadingPageState();
}

class _UserLoadingPageState extends State<UserLoadingPage> {
  late Future<User> user = client.user(widget.id);

  @override
  Widget build(BuildContext context) {
    return FuturePageLoader<User>(
      future: user,
      builder: (context, value) => UserPage(
        user: value,
        initialPage: widget.initalPage,
      ),
      title: Text('User #${widget.id}'),
      onError: const Text('Failed to load user'),
      onEmpty: const Text('User not found'),
    );
  }
}
