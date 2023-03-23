import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';

class ClientProvider extends SubProvider<ClientService, Client> {
  ClientProvider({super.child, super.builder})
      : super(
          create: (context, service) => Client(
            host: service.host,
            credentials: service.credentials,
            userAgent: service.userAgent,
            cache: service.cache,
            cookies: service.cookies,
          ),
          keys: (context) {
            ClientService service = context.watch<ClientService>();
            return [
              service.host,
              service.credentials,
              service.userAgent,
              service.cache,
              service.cookies,
            ];
          },
          dispose: (context, client) => client.close(force: true),
        );
}
