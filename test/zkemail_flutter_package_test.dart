import 'package:flutter_test/flutter_test.dart';
import 'package:zkemail_flutter_package/zkemail_flutter_package.dart';
import 'package:zkemail_flutter_package/zkemail_flutter_package_platform_interface.dart';
import 'package:zkemail_flutter_package/zkemail_flutter_package_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockZkemailFlutterPackagePlatform
    with MockPlatformInterfaceMixin
    implements ZkemailFlutterPackagePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ZkemailFlutterPackagePlatform initialPlatform = ZkemailFlutterPackagePlatform.instance;

  test('$MethodChannelZkemailFlutterPackage is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelZkemailFlutterPackage>());
  });

  test('getPlatformVersion', () async {
    ZkemailFlutterPackage zkemailFlutterPackagePlugin = ZkemailFlutterPackage();
    MockZkemailFlutterPackagePlatform fakePlatform = MockZkemailFlutterPackagePlatform();
    ZkemailFlutterPackagePlatform.instance = fakePlatform;

    expect(await zkemailFlutterPackagePlugin.getPlatformVersion(), '42');
  });
}
