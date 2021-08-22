import 'dart:async';

import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

typedef Action<ReturnType> = FutureOr<ReturnType> Function();

class ActionController extends ChangeNotifier {
  Action? action;

  @mustCallSuper
  void setAction<ReturnType>(Action<ReturnType> submit) {
    action = submit;
    notifyListeners();
  }
}

class SheetActionController extends ActionController {
  PersistentBottomSheetController? sheetController;
  bool loading = false;

  bool get isShown => sheetController != null;

  void close() => sheetController?.close.call();

  FutureOr<T> wrapper<T>(Action<T> submit) async {
    loading = true;
    notifyListeners();

    bool willClose;
    T result = await submit();
    if (T is bool) {
      willClose = result as bool;
    } else {
      willClose = true;
    }

    if (willClose) {
      sheetController!.close();
    }
    loading = false;
    notifyListeners();
    return result;
  }

  void show(BuildContext context, Widget child) {
    sheetController = Scaffold.of(context).showBottomSheet(
      (context) => BottomSheetLoadingIndicator(child: child, controller: this),
    );
    sheetController!.closed.then((_) {
      sheetController = null;
      action = null;
      loading = false;
      notifyListeners();
    });
  }

  @override
  void setAction<T>(Action<T> submit) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      loading = false;
      super.setAction<T>(() => wrapper<T>(submit));
    });
  }
}

class BottomSheetLoadingIndicator extends StatefulWidget {
  final Widget child;
  final SheetActionController controller;

  const BottomSheetLoadingIndicator(
      {required this.controller, required this.child});

  @override
  _BottomSheetLoadingIndicatorState createState() =>
      _BottomSheetLoadingIndicatorState();
}

class _BottomSheetLoadingIndicatorState
    extends State<BottomSheetLoadingIndicator> with LinkingMixin {
  late bool loading = widget.controller.loading;

  @override
  Map<ChangeNotifier, VoidCallback> get links => {
        widget.controller: updateLoading,
      };

  void updateLoading() {
    if (mounted && loading != widget.controller.loading) {
      setState(() {
        loading = widget.controller.loading;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CrossFade(
                showChild: loading,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: SizedCircularProgressIndicator(size: 16),
                  ),
                ),
              ),
              Expanded(child: widget.child),
            ],
          )
        ],
      ),
    );
  }
}

class SheetTextWrapper extends StatefulWidget {
  final SubmitString submit;
  final TextEditingController? textController;
  final ActionController actionController;
  final Widget Function(
    BuildContext context,
    TextEditingController controller,
    SubmitString submit,
  ) builder;

  const SheetTextWrapper(
      {required this.submit,
      required this.actionController,
      required this.builder,
      this.textController});

  @override
  _SheetTextWrapperState createState() => _SheetTextWrapperState();
}

class _SheetTextWrapperState extends State<SheetTextWrapper> {
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();
    textController = widget.textController ?? TextEditingController();
    setFocusToEnd(textController);
    widget.actionController.setAction(() => widget.submit(textController.text));
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      textController,
      (_) => widget.actionController.action!(),
    );
  }
}

class SheetTextField extends StatelessWidget {
  final String? labelText;
  final SubmitString submit;
  final TextEditingController? textController;
  final ActionController actionController;

  const SheetTextField({
    required this.actionController,
    required this.submit,
    this.labelText,
    this.textController,
  });

  @override
  Widget build(BuildContext context) {
    return SheetTextWrapper(
      submit: submit,
      textController: textController,
      actionController: actionController,
      builder: (context, controller, submit) {
        return TextField(
          controller: controller,
          autofocus: true,
          maxLines: 1,
          keyboardType: TextInputType.text,
          onSubmitted: submit,
          decoration: InputDecoration(
            labelText: labelText,
            border: UnderlineInputBorder(),
          ),
        );
      },
    );
  }
}

class SheetFloatingActionButton extends StatefulWidget {
  final IconData actionIcon;
  final IconData? confirmIcon;
  final SheetActionController? controller;
  final Widget Function(BuildContext context, ActionController actionController)
      builder;

  const SheetFloatingActionButton(
      {required this.builder,
      required this.actionIcon,
      this.controller,
      this.confirmIcon});

  @override
  _SheetFloatingActionButtonState createState() =>
      _SheetFloatingActionButtonState();
}

class _SheetFloatingActionButtonState extends State<SheetFloatingActionButton> {
  late SheetActionController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? SheetActionController();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) => FloatingActionButton(
        child: controller.isShown
            ? Icon(widget.confirmIcon ?? Icons.check)
            : Icon(widget.actionIcon),
        onPressed: controller.action ??
            () async {
              controller.show(
                context,
                widget.builder(context, controller),
              );
            },
      ),
    );
  }
}
