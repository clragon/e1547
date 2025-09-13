import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:e1547/domain/domain.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';

class UserLoadingPage extends StatelessWidget {
  const UserLoadingPage(
    this.id, {
    super.key,
    this.initalPage = UserPageSection.favorites,
  });

  final String id;
  final UserPageSection initalPage;

  @override
  Widget build(BuildContext context) {
    final domain = context.watch<Domain>();
    return QueryBuilder(
      query: domain.users.useGet(id: id),
      builder: (context, state) => LoadingPage(
        isLoading: state.isLoading,
        isError: state.isError,
        onError: const Text('Failed to load user'),
        onEmpty: const Text('User not found'),
        builder: (context) =>
            UserPage(user: state.data!, initialPage: initalPage),
      ),
    );
  }
}
