import 'package:e1547/interface/interface.dart';
import 'package:e1547/ticket/ticket.dart';
import 'package:flutter/material.dart';

class ReportFormReason extends StatelessWidget {
  final bool isLoading;
  final TextEditingController controller;

  const ReportFormReason({required this.isLoading, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: defaultFormPadding,
      child: TextFormField(
        enabled: !isLoading,
        controller: controller,
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
    );
  }
}

class ReasonReportScreen extends StatefulWidget {
  final Widget? title;
  final Widget Function(BuildContext context, bool isLoading) previewBuilder;
  final Future<bool> Function(String reason) onReport;
  final String? onSuccess;
  final String? onFailure;

  const ReasonReportScreen({
    this.title,
    required this.previewBuilder,
    required this.onReport,
    this.onSuccess,
    this.onFailure,
  });

  @override
  _ReasonReportScreenState createState() => _ReasonReportScreenState();
}

class _ReasonReportScreenState extends State<ReasonReportScreen> {
  ScrollController scrollController = ScrollController();
  TextEditingController reasonController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Scaffold(
        appBar: DefaultAppBar(
          elevation: 0,
          title: widget.title,
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
                      if (await widget.onReport(reasonController.text.trim())) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: Duration(seconds: 1),
                          content: Text(widget.onSuccess ?? 'Reported item'),
                          behavior: SnackBarBehavior.floating,
                        ));
                        Navigator.maybePop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: Duration(seconds: 1),
                          content:
                              Text(widget.onFailure ?? 'Failed to report item'),
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
            padding: defaultFormScreenPadding,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: defaultFormTargetHeight,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: defaultFormPadding,
                      child: widget.previewBuilder(context, isLoading),
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
