import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/ticket/ticket.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';

class UserReportScreen extends StatelessWidget {
  final User user;
  final Post? avatar;

  const UserReportScreen({required this.user, this.avatar});

  @override
  Widget build(BuildContext context) {
    return ReasonReportScreen(
      title: Text('User #${user.id}'),
      onReport: (reason) => validateRawCall(
        () => client.reportUser(
          user.id,
          reason,
        ),
      ),
      onSuccess: 'Reported user #${user.id}',
      onFailure: 'Failed to report user #${user.id}',
      previewBuilder: (context, isLoading) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 30),
            child: Stack(
              children: [
                SizedBox(
                  height: 100,
                  width: 100,
                  child: Avatar(avatar),
                ),
                Positioned.fill(
                  child: CrossFade(
                    showChild: isLoading,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black54,
                      ),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
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
