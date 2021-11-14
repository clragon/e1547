import 'dart:math';

import 'package:e1547/client/client.dart';
import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/ticket/ticket.dart';
import 'package:e1547/wiki/wiki.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PostReportImage extends StatelessWidget {
  final Post post;
  final bool isLoading;
  final double height;

  final double minImageHeight = 300;

  const PostReportImage({
    required this.post,
    required this.height,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: minImageHeight,
        maxHeight: max(height * 0.5, minImageHeight),
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                ImageOverlay(
                  post: post,
                  builder: (context) => Hero(
                    tag: post.hero,
                    child: PostImageWidget(
                      post: post,
                      size: ImageSize.sample,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: CrossFade(
                    showChild: isLoading,
                    child: Container(
                      color: Colors.black54,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
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

class PostReportScreen extends StatefulWidget {
  final Post post;

  const PostReportScreen({required this.post});

  @override
  _PostReportScreenState createState() => _PostReportScreenState();
}

class _PostReportScreenState extends State<PostReportScreen> {
  ScrollController scrollController = ScrollController();
  TextEditingController reasonController = TextEditingController();
  ReportType? type;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text('Report #${widget.post.id}'),
          leading: CloseButton(),
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            child: Icon(Icons.check),
            onPressed: isLoading
                ? null
                : () async {
                    if (Form.of(context)!.validate()) {
                      setState(() {
                        isLoading = true;
                      });
                      scrollController.animateTo(
                        0,
                        duration: defaultAnimationDuration,
                        curve: Curves.easeInOut,
                      );
                      try {
                        await client.reportPost(
                          widget.post.id,
                          reportIds[type!]!,
                          reasonController.text.trim(),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: Duration(seconds: 1),
                          content: Text('Reported post #${widget.post.id}'),
                          behavior: SnackBarBehavior.floating,
                        ));
                        Navigator.maybePop(context);
                      } on DioError {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: Duration(seconds: 1),
                          content:
                              Text('Failed to report post #${widget.post.id}'),
                        ));
                      }
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) => ListView(
            controller: scrollController,
            padding: EdgeInsets.all(16),
            physics: BouncingScrollPhysics(),
            children: [
              PostReportImage(
                post: widget.post,
                height: constraints.maxHeight,
                isLoading: isLoading,
              ),
              Padding(
                padding: EdgeInsets.only(left: 32, right: 32, bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Report',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        wikiSheet(context: context, tag: 'e621:report_post');
                      },
                      icon: Icon(Icons.info_outline),
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: DropdownButtonFormField<ReportType>(
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  isDense: true,
                  value: type,
                  onChanged: isLoading
                      ? null
                      : (value) {
                          setState(() {
                            type = value;
                          });
                        },
                  validator: (value) {
                    if (value == null) {
                      return 'Type cannot be empty';
                    }
                    return null;
                  },
                  items: ReportType.values
                      .map<DropdownMenuItem<ReportType>>((ReportType value) {
                    return DropdownMenuItem<ReportType>(
                      value: value,
                      child: Text(reportTypes[value]!),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: TextFormField(
                  enabled: !isLoading,
                  controller: reasonController,
                  decoration: InputDecoration(
                    labelText: 'Reason',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null,
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return 'Reason cannot be empty';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PostFlagScreen extends StatefulWidget {
  final Post post;

  const PostFlagScreen({required this.post});

  @override
  _PostFlagScreenState createState() => _PostFlagScreenState();
}

class _PostFlagScreenState extends State<PostFlagScreen> {
  ScrollController scrollController = ScrollController();
  TextEditingController parentController = TextEditingController();
  FlagType? type;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text('Flag #${widget.post.id}'),
          leading: CloseButton(),
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            child: Icon(Icons.check),
            onPressed: isLoading
                ? null
                : () async {
                    if (Form.of(context)!.validate()) {
                      setState(() {
                        isLoading = true;
                      });
                      scrollController.animateTo(
                        0,
                        duration: defaultAnimationDuration,
                        curve: Curves.easeInOut,
                      );
                      try {
                        await client.flagPost(
                          widget.post.id,
                          flagName[type]!,
                          parent: int.tryParse(parentController.text),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: Duration(seconds: 1),
                          content: Text('Flagged post #${widget.post.id}'),
                          behavior: SnackBarBehavior.floating,
                        ));
                        Navigator.maybePop(context);
                      } on DioError {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: Duration(seconds: 1),
                          content:
                              Text('Failed to flag post #${widget.post.id}'),
                        ));
                      }
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) => ListView(
            controller: scrollController,
            padding: EdgeInsets.all(16),
            physics: BouncingScrollPhysics(),
            children: [
              PostReportImage(
                post: widget.post,
                height: constraints.maxHeight,
                isLoading: isLoading,
              ),
              Padding(
                padding: EdgeInsets.only(left: 32, right: 32, bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Flag',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        wikiSheet(
                            context: context, tag: 'e621:flag_for_deletion');
                      },
                      icon: Icon(Icons.info_outline),
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: DropdownButtonFormField<FlagType>(
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  isDense: true,
                  value: type,
                  onChanged: isLoading
                      ? null
                      : (value) {
                          setState(() {
                            type = value;
                          });
                        },
                  validator: (value) {
                    if (value == null) {
                      return 'Type cannot be empty';
                    }
                    return null;
                  },
                  items: FlagType.values
                      .map<DropdownMenuItem<FlagType>>(
                        (FlagType value) => DropdownMenuItem<FlagType>(
                          value: value,
                          child: Text(flagTypes[value]!),
                        ),
                      )
                      .toList(),
                ),
              ),
              SafeCrossFade(
                showChild: type == FlagType.Inferior,
                builder: (context) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: TextFormField(
                    enabled: !isLoading,
                    controller: parentController,
                    decoration: InputDecoration(
                      labelText: 'Parent ID',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 1,
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
              SafeCrossFade(
                showChild: type != null,
                builder: (context) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: DText(flagDescriptions[type]!),
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
    );
  }
}
