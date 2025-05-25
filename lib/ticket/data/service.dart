import 'package:dio/dio.dart';
import 'package:e1547/ticket/ticket.dart';

class TicketService {
  TicketService({required this.dio});

  final Dio dio;

  Future<void> create({
    required TicketType type,
    required int item,
    required String reason,
    PostReportType? postReportType,
  }) {
    return dio.post(
      '/tickets',
      queryParameters: {
        'ticket[qtype]': type.id,
        'ticket[disp_id]': item,
        'ticket[reason]': reason,
        if (postReportType != null) 'ticket[report_reason]': postReportType,
      },
      options: Options(validateStatus: (status) => status == 302),
    );
  }
}
