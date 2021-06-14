import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/follow.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/tag.dart';
import 'package:e1547/wiki.dart';
import 'package:flutter/material.dart';

class FollowTile extends StatefulWidget {
  final Follow follow;

  FollowTile({@required this.follow}) : super(key: ObjectKey(follow));

  @override
  _FollowTileState createState() => _FollowTileState();
}

class _FollowTileState extends State<FollowTile> {
  FollowStatus status;

  void update() {
    widget.follow.status.then(
      (value) => setState(() {
        status = value;
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    update();
  }

  Widget image() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Hero(
            tag: 'image_${status.latest}',
            child: CachedNetworkImage(
              imageUrl: status.thumbnail,
              errorWidget: (context, url, error) => Icon(Icons.error),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget info() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (widget.follow.notification)
              Padding(
                padding: EdgeInsets.only(right: 4),
                child: ShadowIcon(
                  Icons.notifications_active,
                  size: 16,
                ),
              ),
            if (status.unseen != null && status.unseen > 0)
              Expanded(
                child: Text(
                  () {
                    String text = status.unseen.toString();
                    if (status.unseen == widget.follow.checkAmount) {
                      text += '+';
                    }
                    text += ' new post';
                    if (status.unseen > 1) {
                      text += 's';
                    }
                    return text;
                  }(),
                  style: TextStyle(shadows: getTextShadows()),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Spacer(),
            if (widget.follow.tags.split(' ').length > 2)
              Text(
                '${widget.follow.tags.split(' ').length} tags',
                style: TextStyle(shadows: getTextShadows()),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        Text(
          widget.follow.title,
          style: Theme.of(context)
              .textTheme
              .headline6
              .copyWith(shadows: getTextShadows()),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          softWrap: true,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SafeCrossFade(
              showChild: status?.thumbnail != null,
              builder: (context) => Stack(
                children: [
                  image(),
                  Positioned(
                    right: 0,
                    left: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Theme.of(context).cardColor.withOpacity(0.8),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )),
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: info(),
                      ),
                    ),
                  ),
                ],
              ),
              secondChild: Padding(
                padding: EdgeInsets.all(4),
                child: Center(
                  child: Text(
                    widget.follow.title,
                    style: Theme.of(context).textTheme.headline6,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          SearchPage(tags: widget.follow.tags),
                    ),
                  ),
                  onLongPress: () => wikiSheet(
                    context: context,
                    tag: tagToName(widget.follow.tags),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
