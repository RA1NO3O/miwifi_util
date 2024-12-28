import 'package:miwifi_util/miwifi_util.dart';
import 'package:test/test.dart';

void main() {
  test('password-encrypt', () async {
    final miWifi = MiWifiUtil(key: '', password: '', deviceId: '');

    await miWifi.getEncryptRule();

    miWifi.nonce = '0_00:00:00:00:00:00_1731685569_8604';

    expect(
      miWifi.hashPassword,
      '38ef9174a09627b5104e288bbdf41da8c07c016f834bd72d696f2caddbe8f1ce',
    );
  });
}
