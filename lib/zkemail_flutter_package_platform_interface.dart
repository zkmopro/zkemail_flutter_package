import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'zkemail_flutter_package_method_channel.dart';

abstract class ZkemailFlutterPackagePlatform extends PlatformInterface {
  /// Constructs a ZkemailFlutterPackagePlatform.
  ZkemailFlutterPackagePlatform() : super(token: _token);

  static final Object _token = Object();

  static ZkemailFlutterPackagePlatform _instance = MethodChannelZkemailFlutterPackage();

  /// The default instance of [ZkemailFlutterPackagePlatform] to use.
  ///
  /// Defaults to [MethodChannelZkemailFlutterPackage].
  static ZkemailFlutterPackagePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ZkemailFlutterPackagePlatform] when
  /// they register themselves.
  static set instance(ZkemailFlutterPackagePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
