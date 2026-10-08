import 'package:flutter_test/flutter_test.dart';
import 'package:mackhan/core/constants/deploy_config.dart';

void main() {
  test('ML_CLOUD_ENABLED=false disables cloud ML', () {
    // Compile-time flag is set in production build script; default in tests is enabled
    // unless ML_SERVICE_URL would be none — dotenv not loaded in unit test.
    expect(DeployConfig.cloudMlEnabled, isFalse);
  });
}
