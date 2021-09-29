import 'package:e1547/client/client.dart';
import 'package:e1547/interface/data.dart';
import 'package:e1547/topic/topic.dart';

class TopicController extends DataController<Topic> with RefreshableController {
  @override
  Future<List<Topic>> provide(int page) => client.topics(page);
}
