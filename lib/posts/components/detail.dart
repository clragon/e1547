import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/interface/cross_fade.dart';
import 'package:e1547/main/components/routes.dart';
import 'package:e1547/posts/components/displays/image.dart';
import 'package:e1547/posts/post.dart';
import 'package:e1547/posts/posts_page.dart';
import 'package:e1547/services/client.dart';
import 'package:e1547/util/text_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:like_button/like_button.dart';

import 'displays/artists.dart';
import 'displays/comments.dart';
import 'displays/description.dart';
import 'displays/file.dart';
import 'displays/like.dart';
import 'displays/parent.dart';
import 'displays/pools.dart';
import 'displays/rating.dart';
import 'displays/sources.dart';
import 'displays/tags.dart';

class PostWidget extends StatefulWidget {
  final Post post;
  final PostProvider provider;
  final PageController controller;

  PostWidget({@required this.post, this.provider, this.controller});

  @override
  State<StatefulWidget> createState() {
    return _PostWidgetState();
  }
}

class _PostWidgetState extends State<PostWidget> with RouteAware {
  TextEditingController textController = TextEditingController();
  ValueNotifier<Future<bool> Function()> doEdit = ValueNotifier(null);
  PersistentBottomSheetController bottomSheetController;

  void updateWidget() {
    if (this.mounted && !widget.provider.items.contains(widget.post)) {
      if (ModalRoute.of(context).isCurrent) {
        Navigator.of(context).pushReplacement(MaterialPageRoute<Null>(
            builder: (context) => PostWidget(post: widget.post)));
      } else {
        Navigator.of(context).replace(
            oldRoute: ModalRoute.of(context),
            newRoute: MaterialPageRoute<Null>(
                builder: (context) => PostWidget(post: widget.post)));
      }
    }
  }

  void closeBottomSheet() {
    if (!widget.post.isEditing.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          bottomSheetController?.close?.call();
        } on NoSuchMethodError {
          // this error is thrown when hot reloading in debug mode
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    widget.post.isEditing.addListener(closeBottomSheet);
    widget.provider?.pages?.addListener(updateWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.post.image.value.file['url'] != null) {
      String ext = widget.post.image.value.file['ext'];
      if (ext != 'webm' && ext != 'swf') {
        precacheImage(
          CachedNetworkImageProvider(widget.post.image.value.file['url']),
          context,
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    routeObserver.unsubscribe(this);
    widget.provider?.pages?.removeListener(updateWidget);
    if (widget.post.isEditing.value) {
      resetPost(widget.post);
    }
    widget.post.isEditing.removeListener(closeBottomSheet);
    if (widget.post.controller != null &&
        widget.post.controller.value.initialized) {
      widget.post.controller.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> isLoading = ValueNotifier(false);

    Widget reasonEditor() {
      return Padding(
          padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(
              children: <Widget>[
                ValueListenableBuilder(
                  valueListenable: isLoading,
                  builder: (context, value, child) {
                    if (value) {
                      return Center(
                          child: Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Container(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator()),
                      ));
                    } else {
                      return Container();
                    }
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: textController,
                    autofocus: true,
                    maxLines: 1,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        labelText: 'Edit reason',
                        border: UnderlineInputBorder()),
                  ),
                ),
              ],
            )
          ]));
    }

    Future<void> onSubmit() async {
      if (widget.post.isEditing.value) {
        if (doEdit.value != null) {
          if (await doEdit.value()) {
            bottomSheetController.close();
          }
        } else {
          textController.text = '';
          bottomSheetController = Scaffold.of(context).showBottomSheet(
            (context) {
              return reasonEditor();
            },
          );
          bottomSheetController.closed.then((_) {
            doEdit.value = null;
            isLoading.value = false;
          });
          doEdit.value = () async {
            isLoading.value = true;
            Map response = await client.updatePost(
                widget.post, Post.fromRaw(widget.post.raw),
                editReason: textController.text);
            isLoading.value = false;
            if (response == null || response['code'] == 200) {
              isLoading.value = false;
              widget.post.isEditing.value = false;
              await resetPost(widget.post, online: true);
            } else {
              Scaffold.of(context).showSnackBar(SnackBar(
                duration: Duration(seconds: 1),
                content: Text(
                    'Failed to send post: ${response['code']} : ${response['reason']}'),
                behavior: SnackBarBehavior.floating,
              ));
            }
            return Future.value(true);
          };
        }
      }
    }

    Widget metaDataContainer(BuildContext context) {
      void editParent() {
        ValueNotifier<bool> isLoading = ValueNotifier(false);
        isLoading.value = false;
        textController.text = widget.post.parent.value?.toString() ?? ' ';
        setFocusToEnd(textController);
        bottomSheetController = Scaffold.of(context).showBottomSheet(
          (context) {
            return ValueListenableBuilder(
              valueListenable: isLoading,
              builder: (BuildContext context, value, Widget child) {
                return ParentInput(
                    textController: textController,
                    onSubmit: () async => await doEdit.value(),
                    isLoading: isLoading.value);
              },
            );
          },
        );
        doEdit.value = () async {
          isLoading.value = true;
          if (textController.text.trim().isEmpty) {
            widget.post.parent.value = null;
            isLoading.value = false;
            return Future.value(true);
          }
          if (int.tryParse(textController.text) != null) {
            Post parent = await client.post(int.tryParse(textController.text));
            if (parent != null) {
              widget.post.parent.value = parent.id;
              bottomSheetController?.close();
              return true;
            }
          }
          Scaffold.of(context).showSnackBar(SnackBar(
            duration: Duration(seconds: 1),
            content: Text('Invalid parent post'),
            behavior: SnackBarBehavior.floating,
          ));
          isLoading.value = false;
          return false;
        };
        bottomSheetController.closed.then((_) {
          doEdit.value = null;
          isLoading.value = false;
        });
      }

      Future<void> editTags(String tagSet) async {
        ValueNotifier<bool> isLoading = ValueNotifier(false);
        textController.text = '';
        bottomSheetController = Scaffold.of(context).showBottomSheet(
          (context) {
            return TagInput(
                isLoading: isLoading.value,
                textController: textController,
                onSubmit: () async => await doEdit.value(),
                tagSet: tagSet);
          },
        );
        doEdit.value = () async {
          isLoading.value = true;
          if (textController.text.trim().isEmpty) {
            isLoading.value = false;
            bottomSheetController?.close();
            return Future.value(true);
          }
          List<String> tags = textController.text.trim().split(' ');
          widget.post.tags.value[tagSet].addAll(tags);
          widget.post.tags.value[tagSet].sort();
          widget.post.tags.value = Map.from(widget.post.tags.value);
          () async {
            if (tagSet != 'general') {
              for (String tag in tags) {
                List validator = (await client.tags(tag));
                String category;
                if (validator.length == 0) {
                  category = 'general';
                } else if (group[tagSet] != validator[0]['category']) {
                  category = group.keys
                      .firstWhere((k) => group[k] == validator[0]['category']);
                }
                if (category != null) {
                  widget.post.tags.value[tagSet].remove(tag);
                  widget.post.tags.value[category].add(tag);
                  widget.post.tags.value[category].sort();
                  widget.post.tags.value = Map.from(widget.post.tags.value);
                  Scaffold.of(context).showSnackBar(SnackBar(
                    duration: Duration(seconds: 1),
                    content: Text('Moved $tag to $category tags'),
                    behavior: SnackBarBehavior.floating,
                  ));
                }
                await new Future.delayed(const Duration(milliseconds: 200));
              }
            }
          }();
          bottomSheetController?.close();
          return Future.value(true);
        };
        bottomSheetController.closed.then((_) {
          doEdit.value = null;
          isLoading.value = false;
        });
      }

      Widget editorDependant({@required Widget child, @required bool shown}) {
        return CrossFade(
          showChild: shown == widget.post.isEditing.value,
          child: child,
        );
      }

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          children: [
            ArtistDisplay(widget.post),
            DescriptionDisplay(widget.post),
            editorDependant(child: LikeDisplay(widget.post), shown: false),
            editorDependant(child: CommentDisplay(widget.post), shown: false),
            ParentDisplay(widget.post, editParent),
            editorDependant(child: PoolDisplay(widget.post), shown: false),
            TagDisplay(widget.post, editTags),
            editorDependant(child: FileDisplay(widget.post), shown: false),
            editorDependant(child: RatingDisplay(widget.post), shown: true),
            SourceDisplay(widget.post),
          ],
        ),
      );
    }

    Widget fab(BuildContext context) {
      Widget fabIcon() {
        if (widget.post.isEditing.value) {
          return ValueListenableBuilder(
            valueListenable: doEdit,
            builder: (context, value, child) {
              if (value == null) {
                return Icon(Icons.check,
                    color: Theme.of(context).iconTheme.color);
              } else {
                return Icon(Icons.add,
                    color: Theme.of(context).iconTheme.color);
              }
            },
          );
        } else {
          return Padding(
              padding: EdgeInsets.only(left: 2),
              child: ValueListenableBuilder(
                valueListenable: widget.post.isFavorite,
                builder: (context, value, child) {
                  return Builder(
                    builder: (context) {
                      return LikeButton(
                        isLiked: value,
                        circleColor:
                            CircleColor(start: Colors.pink, end: Colors.red),
                        bubblesColor: BubblesColor(
                            dotPrimaryColor: Colors.pink,
                            dotSecondaryColor: Colors.red),
                        likeBuilder: (bool isLiked) {
                          return Icon(
                            Icons.favorite,
                            color: isLiked
                                ? Colors.pinkAccent
                                : Theme.of(context).iconTheme.color,
                          );
                        },
                        onTap: (isLiked) async {
                          if (isLiked) {
                            tryRemoveFav(context, widget.post);
                            return false;
                          } else {
                            tryAddFav(context, widget.post);
                            return true;
                          }
                        },
                      );
                    },
                  );
                },
              ));
        }
      }

      return FloatingActionButton(
        heroTag: null,
        backgroundColor: Theme.of(context).cardColor,
        child: fabIcon(),
        onPressed: onSubmit,
      );
    }

    return ValueListenableBuilder(
      valueListenable: widget.post.isEditing,
      builder: (context, value, child) {
        return WillPopScope(
          onWillPop: () async {
            if (doEdit.value != null) {
              return Future.value(true);
            }
            if (value) {
              resetPost(widget.post);
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: postAppBar(context, widget.post),
            body: MediaQuery.removeViewInsets(
                context: context,
                removeTop: true,
                child: ListView(
                  children: <Widget>[
                    ImageContainer(
                        widget.post, widget.provider, widget.controller),
                    Builder(builder: metaDataContainer),
                  ],
                  physics: BouncingScrollPhysics(),
                )),
            floatingActionButton: widget.post.isLoggedIn
                ? Builder(
                    builder: (context) {
                      return fab(context);
                    },
                  )
                : null,
          ),
        );
      },
    );
  }
}
