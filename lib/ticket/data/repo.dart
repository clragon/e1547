import 'package:e1547/shared/shared.dart';
import 'package:e1547/ticket/ticket.dart';

class TicketRepo {
  TicketRepo({required this.persona, required this.client});

  final TicketClient client;
  final Persona persona;

  Future<void> create({
    required TicketType type,
    required int item,
    required String reason,
    PostReportType? postReportType,
  }) => client.create(
    type: type,
    item: item,
    reason: reason,
    postReportType: postReportType,
  );
}
