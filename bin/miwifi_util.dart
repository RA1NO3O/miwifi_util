import 'package:args/args.dart';
import 'package:miwifi_util/miwifi_util.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('address', abbr: 'a', help: 'Router address')
    ..addOption('key',
        abbr: 'k',
        help:
            'AES key, could be found in the source code of the router\'s web page')
    ..addOption('iv',
        abbr: 'i',
        help:
            'AES iv, could be found in the source code of the router\'s web page')
    ..addOption('device-id', abbr: 'd', help: 'Router device ID')
    ..addOption('password', abbr: 'p', help: 'Router password')
    ..addFlag('output-wan-ip', abbr: 'o', help: 'Output WAN IP address')
    ..addFlag('help', abbr: 'h', help: 'Output this help message.');

  /// 处理参数
  final parsedArgs = parser.parse(arguments);

  final miWifi = MiWifiUtil(
    address: parsedArgs['address'] ?? '192.168.31.1',
    key: parsedArgs['key'],
    iv: parsedArgs['iv'],
    deviceId: parsedArgs['device-id'],
    password: parsedArgs['password'],
  );

  await miWifi.getEncryptRule();
  await miWifi.login();

  if (parsedArgs.arguments.contains('--output-wan-ip')) {
    final pppoeStatus = await miWifi.getPPPoEStatus();

    final ipInfo = pppoeStatus['ip'];

    if (ipInfo is Map &&
        ipInfo.keys.every((key) => key is String) &&
        ipInfo.values.every((value) => value is String)) {
      ipInfo.cast<String, String>();

      // output ip address to stdout
      print(ipInfo['address']);
    }
  }
}
