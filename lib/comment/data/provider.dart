import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:meta/meta.dart';

import 'comment.dart';

class CommentProvider extends DataProvider<Comment> {
  final int postID;
  List<Comment> get comments => super.items;

  CommentProvider({@required this.postID})
      : super.extended(extendedProvider: ((search, pages) async {
          String cursor;
          if (pages.length == 0) {
            cursor = 'a0';
          } else {
            cursor =
                'a${pages.last.reduce((value, element) => (value.id > element.id) ? value : element).id.toString()}';
          }
          List<Comment> comments = await client.comments(postID, cursor);
          comments.sort((one, two) => DateTime.parse(one.creation)
              .compareTo(DateTime.parse(two.creation)));
          return comments;
        }));
}
