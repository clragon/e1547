import 'package:e1547/client/client.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/ticket/ticket.dart';
import 'package:flutter/material.dart';

class CommentReportScreen extends StatelessWidget {
  final Comment comment;

  const CommentReportScreen({required this.comment});

  @override
  Widget build(BuildContext context) {
    return ReasonReportScreen(
      title: Text('Comment #${comment.id}'),
      onReport: (reason) => validateCall(
        () => client.reportComment(
          comment.id,
          reason,
        ),
        allowRedirect: true,
      ),
      onSuccess: 'Reported comment #${comment.id}',
      onFailure: 'Failed to report user #${comment.id}',
      previewBuilder: (context, isLoading) => Card(
        clipBehavior: Clip.antiAlias,
        child: ReportLoadingOverlay(
          isLoading: isLoading,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: CommentTile(
              comment: comment,
              hasActions: false,
            ),
          ),
        ),
      ),
    );
  }
}
