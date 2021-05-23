import 'package:e1547/interface.dart';
import 'package:flutter/material.dart';

class EditReasonEditor extends StatefulWidget {
  final Future<bool> Function(String value) onSubmit;
  final Function(Future<bool> Function() submit) onEditorBuild;

  const EditReasonEditor({@required this.onSubmit, this.onEditorBuild});

  @override
  _EditReasonEditorState createState() => _EditReasonEditorState();
}

class _EditReasonEditorState extends State<EditReasonEditor> {
  TextEditingController controller = TextEditingController();
  ValueNotifier<bool> loading = ValueNotifier(false);

  Future<bool> submit(value) async {
    loading.value = true;
    bool success = await widget.onSubmit(value);
    loading.value = false;
    return success;
  }

  @override
  void initState() {
    super.initState();
    widget.onEditorBuild?.call(() => submit(controller.text));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: <Widget>[
              ValueListenableBuilder(
                valueListenable: loading,
                builder: (context, value, child) => CrossFade(
                  showChild: value,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: Container(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator()),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  maxLines: 1,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Edit reason',
                    border: UnderlineInputBorder(),
                  ),
                  onSubmitted: submit,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
