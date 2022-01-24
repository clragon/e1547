import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

class SheetActionController extends ActionController {
  PersistentBottomSheetController? sheetController;
  bool get isShown => sheetController != null;
  void close() => sheetController?.close.call();

  @override
  void onSucess() {
    sheetController!.close();
  }

  @override
  void reset() {
    sheetController = null;
    super.reset();
  }

  @override
  void setAction(ControllerAction submit) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      super.setAction(submit);
    });
  }

  void show(BuildContext context, Widget child) {
    sheetController = Scaffold.of(context).showBottomSheet(
      (context) => BottomSheetLoadingIndicator(child: child, controller: this),
    );
    sheetController!.closed.then((_) => reset());
  }
}

class BottomSheetLoadingIndicator extends StatelessWidget {
  final Widget child;
  final SheetActionController controller;

  const BottomSheetLoadingIndicator(
      {required this.controller, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: child,
      builder: (context, child) {
        return Padding(
          padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CrossFade(
                    showChild: controller.isLoading,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: SizedCircularProgressIndicator(size: 16),
                      ),
                    ),
                  ),
                  CrossFade(
                    showChild: controller.isError && !controller.isForgiven,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(
                          Icons.clear,
                          color: Theme.of(context).errorColor,
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: child!),
                ],
              )
            ],
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
        onPressed: controller.isLoading
            ? null
            : controller.action ??
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

SlidingSheetDialog defaultSlidingSheetDialog(
    BuildContext context, SheetBuilder builder) {
  return SlidingSheetDialog(
    scrollSpec: ScrollSpec(
      physics: const ClampingScrollPhysics(),
    ),
    duration: Duration(milliseconds: 400),
    avoidStatusBar: true,
    isBackdropInteractable: true,
    cornerRadius: 16,
    cornerRadiusOnFullscreen: 0,
    minHeight: MediaQuery.of(context).size.height * 0.6,
    builder: builder,
    snapSpec: SnapSpec(
      snap: true,
      positioning: SnapPositioning.relativeToAvailableSpace,
      snappings: [
        0.6,
        SnapSpec.expanded,
      ],
    ),
  );
}
