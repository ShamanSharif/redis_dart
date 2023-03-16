import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response.json(
    body: {
      'service': 'Augmedix Tenant Auth Service',
      'version': '0.0.1',
    },
  );
}
