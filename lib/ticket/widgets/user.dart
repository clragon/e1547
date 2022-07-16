import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/ticket/ticket.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserReportScreen extends StatelessWidget {
  final User user;

  const UserReportScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return ReasonReportScreen(
      title: Text('User #${user.id}'),
      onReport: (reason) => validateCall(
        () => context.read<Client>().reportUser(
              user.id,
              reason,
            ),
        allowRedirect: true,
      ),
      onSuccess: 'Reported user #${user.id}',
      onFailure: 'Failed to report user #${user.id}',
      previewBuilder: (context, isLoading) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Stack(
              children: [
                SizedBox(
                  height: 100,
                  width: 100,
                  child: PostAvatar(id: user.avatarId),
                ),
                Positioned.fill(
                  child: CrossFade(
                    showChild: isLoading,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black54,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              user.name,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
        ],
      ),
    );
  }
}
