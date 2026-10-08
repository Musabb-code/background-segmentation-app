import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Production deploy: skip cloud ML when ML service is not hosted (DEPLOY_ACTION_PLAN).
class DeployConfig {
  DeployConfig._();

  static bool get cloudMlEnabled {
    const flag = String.fromEnvironment('ML_CLOUD_ENABLED', defaultValue: '');
    if (flag.toLowerCase() == 'false') return false;

    final url = dotenv.env['ML_SERVICE_URL']?.trim() ?? '';
    if (url.isEmpty ||
        url == 'none' ||
        url == 'off' ||
        url == 'disabled') {
      return false;
    }
    return true;
  }
}
