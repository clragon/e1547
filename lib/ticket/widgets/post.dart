import 'dart:math';

import 'package:e1547/client/client.dart';
import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/ticket/ticket.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

class PostReportImage extends StatelessWidget {
  const PostReportImage({
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
              child: ImageOverlay(
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
  const PostReportScreen({required this.post});

  final Post post;

  @override
  State<PostReportScreen> createState() => _PostReportScreenState();
}

class _PostReportScreenState extends State<PostReportScreen> {
  ScrollController scrollController = ScrollController();
  TextEditingController reasonController = TextEditingController();
  ReportType? type;

  bool isLoading = false;

  @override
  void dispose() {
    scrollController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  Future<void> _sendReport(BuildContext context) async {
    if (Form.of(context)!.validate()) {
      setState(() => isLoading = true);
      scrollController.animateTo(
        0,
        duration: defaultAnimationDuration,
        curve: Curves.easeInOut,
      );
      final messenger = ScaffoldMessenger.of(context);
      try {
        await context.read<Client>().reportPost(
              widget.post.id,
              type!.id,
              reasonController.text.trim(),
            );
        if (mounted) {
          Navigator.maybePop(context);
        }
        messenger.showSnackBar(SnackBar(
          duration: const Duration(seconds: 1),
          content: Text('Reported post #${widget.post.id}'),
          behavior: SnackBarBehavior.floating,
        ));
      } on DioError {
        messenger.showSnackBar(SnackBar(
          duration: const Duration(seconds: 1),
          content: Text('Failed to report post #${widget.post.id}'),
        ));
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
                padding: LimitedWidthLayout.of(context)
                    .padding
                    .add(defaultFormScreenPadding),
                children: [
                  PostReportImage(
                    post: widget.post,
                    height: constraints.maxHeight,
                    isLoading: isLoading,
                  ),
                  ReportFormHeader(
                    title: const Text('Report'),
                    icon: IconButton(
                      onPressed: () => tagSearchSheet(
                        context: context,
                        tag: 'e621:report_post',
                      ),
                      icon: const Icon(Icons.info_outline),
                    ),
                  ),
                  ReportFormDropdown<ReportType?>(
                    type: type,
                    types: {for (final e in ReportType.values) e: e.title},
                    onChanged: (value) => setState(() => type = value),
                    isLoading: isLoading,
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

class PostFlagScreen extends StatefulWidget {
  const PostFlagScreen({required this.post});

  final Post post;

  @override
  State<PostFlagScreen> createState() => _PostFlagScreenState();
}

class _PostFlagScreenState extends State<PostFlagScreen> {
  ScrollController scrollController = ScrollController();
  TextEditingController parentController = TextEditingController();
  FlagType? type;

  bool isLoading = false;

  @override
  void dispose() {
    scrollController.dispose();
    parentController.dispose();
    super.dispose();
  }

  Future<void> _sendFlag(BuildContext context) async {
    if (Form.of(context)!.validate()) {
      setState(() {
        isLoading = true;
      });
      scrollController.animateTo(
        0,
        duration: defaultAnimationDuration,
        curve: Curves.easeInOut,
      );
      final messenger = ScaffoldMessenger.of(context);
      try {
        await context.read<Client>().flagPost(
              widget.post.id,
              type!.title,
              parent: int.tryParse(parentController.text),
            );
        if (mounted) {
          Navigator.maybePop(context);
        }
        messenger.showSnackBar(SnackBar(
          duration: const Duration(seconds: 1),
          content: Text('Flagged post #${widget.post.id}'),
          behavior: SnackBarBehavior.floating,
        ));
      } on DioError {
        messenger.showSnackBar(SnackBar(
          duration: const Duration(seconds: 1),
          content: Text('Failed to flag post #${widget.post.id}'),
        ));
      }
      setState(() {
        isLoading = false;
      });
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
              onPressed: isLoading ? null : () => _sendFlag(context),
              child: const Icon(Icons.check),
            ),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) => ListView(
              controller: scrollController,
              padding: defaultFormScreenPadding,
              children: [
                PostReportImage(
                  post: widget.post,
                  height: constraints.maxHeight,
                  isLoading: isLoading,
                ),
                ReportFormHeader(
                  title: const Text('Flag'),
                  icon: IconButton(
                    onPressed: () => tagSearchSheet(
                        context: context, tag: 'e621:flag_for_deletion'),
                    icon: const Icon(Icons.info_outline),
                  ),
                ),
                ReportFormDropdown<FlagType?>(
                  type: type,
                  types: {for (final e in FlagType.values) e: e.title},
                  onChanged: (value) => setState(() => type = value),
                  isLoading: isLoading,
                ),
                CrossFade.builder(
                  showChild: type == FlagType.inferior,
                  builder: (context) => Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    child: TextFormField(
                      enabled: !isLoading,
                      controller: parentController,
                      decoration: const InputDecoration(
                        labelText: 'Parent ID',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^ ?\d*')),
                      ],
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return 'Parent ID cannot be empty';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Parent ID must be a number';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                CrossFade.builder(
                  showChild: type != null,
                  builder: (context) => Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: DText(type!.description),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
