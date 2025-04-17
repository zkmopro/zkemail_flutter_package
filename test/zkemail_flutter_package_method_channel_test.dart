import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zkemail_flutter_package/zkemail_flutter_package_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelZkemailFlutterPackage platform = MethodChannelZkemailFlutterPackage();
  const MethodChannel channel = MethodChannel('zkemail_flutter_package');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
