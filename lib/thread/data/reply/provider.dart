import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/thread.dart';
import 'package:meta/meta.dart';

class ReplyProvider extends DataProvider<Reply> {
  final Thread thread;
  List<Reply> get replies => super.items;

  ReplyProvider({@required this.thread})
      : super.extended(extendedProvider: (search, pages) async {
          String cursor;
          pages.isEmpty
              ? cursor = 'a0'
              : cursor =
                  'a${pages.last.reduce((value, element) => (value.id > element.id) ? value : element).id.toString()}';
          List<Reply> replies = await client.replies(thread, cursor);
          replies.sort((one, two) => DateTime.parse(one.creation)
              .compareTo(DateTime.parse(two.creation)));
          return replies;
        });
}
