import 'package:context_plus/context_plus.dart';
import 'package:fquery/fquery.dart';

// ignore: non_constant_identifier_names
final QueryClientRef = Ref<QueryClient>();

QueryClient createQueryClient() => QueryClient(
      defaultQueryOptions: DefaultQueryOptions(
        staleDuration: const Duration(minutes: 5),
        retryCount: 1,
      ),
    );
