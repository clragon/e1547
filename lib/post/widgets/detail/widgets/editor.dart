import 'package:e1547/interface.dart';
import 'package:flutter/material.dart';

typedef Action = Future<bool> Function();

class ActionController extends ChangeNotifier {
  Action action;

  @mustCallSuper
  void setAction(Action submit) {
    action = submit;
    notifyListeners();
  }
}

class SheetActionController extends ActionController {
  PersistentBottomSheetController sheetController;
  bool loading = false;

  bool get isShown => sheetController != null;

  void close() => sheetController?.close?.call();

  Future<bool> wrapper(Action submit) async {
    loading = true;
    notifyListeners();
    bool result = await submit();
    if (result) {
      sheetController.close();
    }
    loading = false;
    notifyListeners();
    return result;
  }

  void show<T>(BuildContext context, Widget child) {
    sheetController = Scaffold.of(context).showBottomSheet(
      (context) => BottomSheetLoadingIndicator(child: child, controller: this),
    );
    sheetController.closed.then((_) {
      sheetController = null;
      action = null;
      loading = false;
      notifyListeners();
    });
  }

  @override
  void setAction(Action submit) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loading = false;
      super.setAction(() => wrapper(submit));
    });
  }
}

class BottomSheetLoadingIndicator extends StatefulWidget {
  final Widget child;
  final SheetActionController controller;

  const BottomSheetLoadingIndicator(
      {@required this.controller, @required this.child});

  @override
  _BottomSheetLoadingIndicatorState createState() =>
      _BottomSheetLoadingIndicatorState();
}

class _BottomSheetLoadingIndicatorState
    extends State<BottomSheetLoadingIndicator> {
  bool loading = false;

  void updateLoading() {
    if (mounted && loading != widget.controller.loading) {
      setState(() {
        loading = widget.controller.loading;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loading = widget.controller.loading;
    widget.controller.addListener(updateLoading);
  }

  @override
  void dispose() {
    widget.controller.removeListener(updateLoading);
    super.dispose();
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
