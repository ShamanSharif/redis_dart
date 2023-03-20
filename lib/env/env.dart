// env/env.dart

import 'package:envify/envify.dart';
part 'env.g.dart';

@Envify()
abstract class Env {
  static const authToken = _Env.authToken;
  static const radisHost = _Env.radisHost;
  static const radisPort = _Env.radisPort;
  static const radisUser = _Env.radisUser;
  static const radisPass = _Env.radisPass;
  static const secret = _Env.secret;
  static const algorithm = _Env.algorithm;
  static const accessTokenExpMin = _Env.accessTokenExpMin;
  static const refreshTokenExpDays = _Env.refreshTokenExpDays;
}
