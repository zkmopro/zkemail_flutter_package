import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'zkemail_flutter_package_platform_interface.dart';

/// An implementation of [ZkemailFlutterPackagePlatform] that uses method channels.
class MethodChannelZkemailFlutterPackage extends ZkemailFlutterPackagePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('zkemail_flutter_package');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
