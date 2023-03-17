import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:redis/redis.dart';
import 'package:tenant_auth_service/env/env.dart';
import 'package:tenant_auth_service/utils/token.dart';

Future<Response> onRequest(RequestContext context) async {
  // Extracting the variables
  final request = context.request;
  final method = request.method.value;

  print('Checking for POST method');

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

  print(data);

  final accessToken = data['access_token'] as String?;
  final refreshToken = data['refresh_token'] as String?;
  final expiryTime = DateTime.tryParse(data['expiry_time'] as String? ?? '');
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

  final payload = jsonEncode({
    'access_token': accessToken,
    'refresh_token': refreshToken,
    'expiry_time': expiryTime.toString(),
    'user_id': userId,
    'company_id': companyId,
    'access_role': accessRole,
  });

  dynamic responseValue;
  final commander = await RedisConnection().connect(
    Env.radisHost,
    int.parse(Env.radisPort),
  );
  await commander.send_object(['AUTH', Env.radisUser, Env.radisPass]);
  await commander.set(accessToken, payload).then(
        (value) => responseValue = value,
      );

  if (responseValue != null) {
    return Response.json(
      body: {
        'service': 'Augmedix Tenant Auth Service',
        'status': 'Success',
        'data': responseValue
      },
    );
  }

  return Response.json(
    statusCode: 404,
    body: {
      'service': 'Augmedix Tenant Auth Service',
      'status': 'Failed',
    },
  );
}
