// env/env.dart

import 'package:envify/envify.dart';
part 'env.g.dart';

@Envify()
abstract class Env {
  static const authToken = _Env.authToken;
  static const radisHost = _Env.radisHost;
  static const radisPort = _Env.radisPort;
}
