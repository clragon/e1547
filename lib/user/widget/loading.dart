import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';

class UserLoadingPage extends StatefulWidget {
  const UserLoadingPage(
    this.id, {
    super.key,
    this.initalPage = UserPageSection.favorites,
  });

  final String id;
  final UserPageSection initalPage;

  @override
  State<UserLoadingPage> createState() => _UserLoadingPageState();
}

class _UserLoadingPageState extends State<UserLoadingPage> {
  late Future<User> user = context.read<Client>().users.get(id: widget.id);

  @override
  Widget build(BuildContext context) {
    return FutureLoadingPage<User>(
      future: user,
      builder: (context, value) =>
          UserPage(user: value, initialPage: widget.initalPage),
      title: Text('User #${widget.id}'),
      onError: const Text('Failed to load user'),
      onEmpty: const Text('User not found'),
    );
  }
}
