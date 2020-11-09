import 'package:e1547/interface/cross_fade.dart';
import 'package:e1547/posts/post.dart';
import 'package:e1547/services/client.dart';
import 'package:e1547/settings/custom_host.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';

class ImageToggle extends StatefulWidget {
  final Post post;
  final bool Function(Post post) isVisible;

  const ImageToggle(this.post, this.isVisible);

  @override
  _ImageToggleState createState() => _ImageToggleState();
}

class _ImageToggleState extends State<ImageToggle> {
  @override
  void initState() {
    super.initState();
    widget.post.showUnsafe.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    widget.post.showUnsafe.removeListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return CrossFade(
      showChild: !widget.post.isDeleted &&
          (widget.post.image.value.file['url'] == null ||
              !widget.isVisible(widget.post) ||
              widget.post.showUnsafe.value),
      duration: Duration(milliseconds: 200),
      child: Card(
        color:
            widget.post.showUnsafe.value ? Colors.black12 : Colors.transparent,
        elevation: 0,
        child: InkWell(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: <Widget>[
                Icon(
                  widget.post.showUnsafe.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                  size: 16,
                ),
                Padding(
                  padding: EdgeInsets.only(right: 5, left: 5),
                  child: widget.post.showUnsafe.value
                      ? Text('hide')
                      : Text('show'),
                )
              ],
            ),
          ),
          onTap: () async {
            if (await db.customHost.value == null) {
              await showDialog(context: context, child: HostDialog());
            }
            if (await db.customHost.value != null) {
              widget.post.showUnsafe.value = !widget.post.showUnsafe.value;
              Post urls = await client.post(widget.post.id, unsafe: true);
              if (widget.post.image.value.file['url'] == null) {
                widget.post.image.value = urls.image.value;
              } else if (!widget.post.isBlacklisted) {
                widget.post.image.value = ImageFile.fromRaw(widget.post.raw);
              }
            }
          },
        ),
      ),
    );
  }
}
