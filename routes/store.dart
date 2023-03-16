import 'package:dart_frog/dart_frog.dart';
import 'package:redis/redis.dart';
import 'package:tenant_auth_service/utils/token.dart';

Future<Response> onRequest(RequestContext context) async {
  // Extracting the variables
  final request = context.request;
  final method = request.method.value;

  // Checking for correct method
  if (method != 'POST') {
    return Response.json(
      statusCode: 405,
      body: {'error': 'Method Not Allowed'},
    );
  }

  // Extracting the token from headers
  final headers = request.headers;
  final token = headers['authorization'].toString().split(' ').last;
  if (token != authToken) {
    return Response.json(
      statusCode: 401,
      body: {'error': 'Invalid Authorization Token'},
    );
  }

  final data = await request.json() as Map<String, dynamic>?;
  if (data == null) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid Request'},
    );
  }

  final accessToken = data['access_token'] as String?;
  final refreshToken = data['refresh_token'] as String?;
  final expiryTime = data['expiry_time'] as DateTime?;
  final userId = data['user_id'] as int?;
  final companyId = data['company_id'] as int?;
  final accessRole = data['access_role'] as String?;

  if (accessToken == null ||
      refreshToken == null ||
      expiryTime == null ||
      userId == null ||
      companyId == null ||
      accessRole == null) {
    return Response.json(
      statusCode: 400,
      body: {
        'error': 'Incorrect request body',
        'params': [
          {'name': 'access_token', 'status': 'Required', 'type': 'String'},
          {'name': 'refresh_token', 'status': 'Required', 'type': 'String'},
          {'name': 'expiry_time', 'status': 'Required', 'type': 'DateTime'},
          {'name': 'user_id', 'status': 'Required', 'type': 'int'},
          {'name': 'company_id', 'status': 'Required', 'type': 'int'},
          {'name': 'access_role', 'status': 'Required', 'type': 'String'}
        ]
      },
    );
  }

  final conn = RedisConnection();
  // conn.connect('localhost', 6379).then((Command command){
  //     command.send_object(["SET","key","0"]).then((var response)
  //         print(response);
  //     )
  // }

  final emailSubject = data['subject'] as String?;
  final emailBody = data['body'] as String?;
  if (emailSubject == null || emailBody == null) {
    return Response.json(
      statusCode: 400,
      body: {
        'error': 'Insufficient parameters',
        'required_params': ['email', 'subject', 'body'],
      },
    );
  }

  return Response.json(
    body: {
      'service': 'Augmedix Tenant Auth Service',
      'version': '0.0.1',
    },
  );
}
