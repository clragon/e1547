import 'package:e1547/client/client.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/ticket/ticket.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommentReportScreen extends StatelessWidget {
  final CommentController comment;

  const CommentReportScreen({required this.comment});

  @override
  Widget build(BuildContext context) {
    return ReasonReportScreen(
      title: Text('Comment #${comment.id}'),
      onReport: (reason) => validateCall(
        () => context.read<Client>().reportComment(
              comment.value.id,
              reason,
            ),
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
