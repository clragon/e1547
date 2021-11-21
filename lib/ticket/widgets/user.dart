import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/ticket/ticket.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';

class UserReportScreen extends StatefulWidget {
  final User user;
  final Post? avatar;

  const UserReportScreen({required this.user, this.avatar});

  @override
  _UserReportScreenState createState() => _UserReportScreenState();
}

class _UserReportScreenState extends State<UserReportScreen> {
  ScrollController scrollController = ScrollController();
  TextEditingController reasonController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Scaffold(
        appBar: DefaultAppBar(
          elevation: 0,
          title: Text('Report #${widget.user.id}'),
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
                        await client.reportUser(
                          widget.user.id,
                          reasonController.text.trim(),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: Duration(seconds: 1),
                          content: Text('Reported user #${widget.user.id}'),
                          behavior: SnackBarBehavior.floating,
                        ));
                        Navigator.maybePop(context);
                      } on DioError {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: Duration(seconds: 1),
                          content:
                              Text('Failed to report user #${widget.user.id}'),
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
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: defaultFormTargetHeight,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: Stack(
                        children: [
                          SizedBox(
                            height: 100,
                            width: 100,
                            child: Avatar(widget.avatar),
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
                        widget.user.name,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                  ],
                ),
              ),
              ReportFormHeader(
                title: Text('Report'),
              ),
              ReportFormReason(
                controller: reasonController,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
