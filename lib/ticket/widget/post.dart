import 'dart:math';

import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/markup/markup.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/ticket/ticket.dart';
import 'package:flutter/material.dart';

class PostReportImage extends StatelessWidget {
  const PostReportImage({
    super.key,
    required this.post,
    required this.height,
    this.isLoading = false,
  });

  final Post post;
  final bool isLoading;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: defaultFormTargetHeight,
        maxHeight: max(height * 0.5, defaultFormTargetHeight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: ReportLoadingOverlay(
              isLoading: isLoading,
              child: PostImageOverlay(
                post: post,
                builder: (context) => Hero(
                  tag: post.link,
                  child: PostImageWidget(
                    post: post,
                    size: PostImageSize.sample,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PostReportScreen extends StatefulWidget {
  const PostReportScreen({super.key, required this.post});

  final Post post;

  @override
  State<PostReportScreen> createState() => _PostReportScreenState();
}

class _PostReportScreenState extends State<PostReportScreen> {
  ScrollController scrollController = ScrollController();
  TextEditingController reasonController = TextEditingController();
  PostReportType? type;

  bool isLoading = false;

  @override
  void dispose() {
    scrollController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  Future<void> _sendReport(BuildContext context) async {
    if (Form.of(context).validate()) {
      setState(() => isLoading = true);
      scrollController.animateTo(
        0,
        duration: defaultAnimationDuration,
        curve: Curves.easeInOut,
      );
      ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
      try {
        await context.read<Client>().tickets.create(
          type: TicketType.post,
          item: widget.post.id,
          reason: reasonController.text.trim(),
          postReportType: type,
        );
        if (context.mounted) {
          Navigator.of(context).maybePop();
        }
        messenger.showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 1),
            content: Text('Reported post #${widget.post.id}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } on ClientException {
        messenger.showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 1),
            content: Text('Failed to report post #${widget.post.id}'),
          ),
        );
      }
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Form(
        child: Scaffold(
          appBar: DefaultAppBar(
            elevation: 0,
            title: Text('Post #${widget.post.id}'),
            leading: const CloseButton(),
          ),
          floatingActionButton: Builder(
            builder: (context) => FloatingActionButton(
              onPressed: isLoading ? null : () => _sendReport(context),
              child: const Icon(Icons.check),
            ),
          ),
          body: LimitedWidthLayout(
            child: LayoutBuilder(
              builder: (context, constraints) => ListView(
                controller: scrollController,
                padding: LimitedWidthLayout.of(
                  context,
                ).padding.add(defaultFormScreenPadding),
                children: [
                  PostReportImage(
                    post: widget.post,
                    height: constraints.maxHeight,
                    isLoading: isLoading,
                  ),
                  ReportFormHeader(
                    title: const Text('Report'),
                    icon: IconButton(
                      onPressed: () => showTagSearchPrompt(
                        context: context,
                        tag: 'e621:report_post',
                      ),
                      icon: const Icon(Icons.info_outline),
                    ),
                  ),
                  ReportFormDropdown<PostReportType?>(
                    type: type,
                    types: {for (final e in PostReportType.values) e: e.title},
                    onChanged: (value) => setState(() => type = value),
                    isLoading: isLoading,
                  ),
                  CrossFade.builder(
                    showChild: type != null,
                    builder: (context) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: DText(type!.body),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ReportFormReason(
                    controller: reasonController,
                    isLoading: isLoading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
