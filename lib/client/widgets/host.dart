import 'package:e1547/client/client.dart';
import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

Future<void> setCustomHost(BuildContext context) async {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (context) => const HostPage(),
    ),
  );
}

class HostPage extends StatefulWidget {
  const HostPage({super.key});

  @override
  State<HostPage> createState() => _HostPageState();
}

class _HostPageState extends State<HostPage> {
  late ClientService service = context.read<ClientService>();
  late TextEditingController controller =
      TextEditingController(text: service.customHost);
  bool loading = false;
  String? error;

  Future<void> submit(BuildContext context) async {
    String? error;

    try {
      setState(() {
        loading = true;
      });
      String host = linkToDisplay(controller.text);
      await service.setCustomHost(host);
    } on CustomHostDefaultException {
      error = 'Custom host cannot be default host';
    } on CustomHostIncompatibleException {
      error = 'Host API incompatible';
    } on CustomHostUnreachableException {
      error = 'Host cannot be reached';
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }

    if (mounted) {
      this.error = error;
      if (error != null) {
        Form.of(context).validate();
      } else {
        Navigator.of(context).maybePop();
      }
    }
  }

  Widget form() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 32, right: 32, bottom: 12),
          child: Row(
            children: const [
              Text(
                'Custom Host',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: TextFormField(
            enabled: !loading,
            controller: controller,
            autocorrect: false,
            decoration: const InputDecoration(
              labelText: 'Url',
              border: OutlineInputBorder(),
            ),
            inputFormatters: [FilteringTextInputFormatter.deny(' ')],
            autofillHints: const [AutofillHints.url],
            textInputAction: TextInputAction.next,
            onChanged: (value) => error = null,
            validator: (value) => error,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Form(
        child: Scaffold(
          appBar: const DefaultAppBar(
            leading: CloseButton(),
            elevation: 0,
          ),
          body: LimitedWidthLayout.builder(
            builder: (context) => ListView(
              padding: LimitedWidthLayout.of(context)
                  .padding
                  .add(const EdgeInsets.all(16)),
              children: [
                SizedBox(
                  height: 300,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.storage,
                          size: 64,
                        ),
                        CrossFade(
                          showChild: loading,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              'connecting...',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: form(),
                ),
              ],
            ),
          ),
          floatingActionButton: Builder(
            builder: (context) => FloatingActionButton(
              child: const Icon(Icons.check),
              onPressed: () => submit(context),
            ),
          ),
        ),
      ),
    );
  }
}
