import 'dart:typed_data';

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

  @override
  Future<ProveZkEmailResult> proveZkEmail(String srsPath, Map<String, List<String>> inputs) async {
    try {
      final Map<dynamic, dynamic>? result = await methodChannel.invokeMethod(
        'proveZkEmail',
        {
          'srsPath': srsPath,
          'inputs': inputs,
        },
      );
      if (result == null) {
        return ProveZkEmailResult(error: 'Native method returned null');
      }
      return ProveZkEmailResult.fromMap(result);
    } on PlatformException catch (e) {
      return ProveZkEmailResult(error: "Failed to prove zkEmail: '${e.message}'.");
    }
  }

  @override
  Future<VerifyZkEmailResult> verifyZkEmail(String srsPath, Uint8List proof) async {
    try {
      final Map<dynamic, dynamic>? result = await methodChannel.invokeMethod(
        'verifyZkEmail',
        {
          'srsPath': srsPath,
          'proof': proof,
        },
      );
      if (result == null) {
        return VerifyZkEmailResult(isValid: false, error: 'Native method returned null');
      }
      return VerifyZkEmailResult.fromMap(result);
    } on PlatformException catch (e) {
      return VerifyZkEmailResult(isValid: false, error: "Failed to verify zkEmail: '${e.message}'.");
    }
  }
}
