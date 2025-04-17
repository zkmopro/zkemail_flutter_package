import 'package:path_provider/path_provider.dart';
import 'zkemail_flutter_package_platform_interface.dart';

class ZkemailFlutterPackage {
  Future<String?> getPlatformVersion() {
    return ZkemailFlutterPackagePlatform.instance.getPlatformVersion();
  }

  Future<String> copyAssetToFileSystem(String assetPath) async {
    // Load the asset as bytes
    final byteData = await rootBundle.load(assetPath);
    // Get the app's document directory (or other accessible directory)
    final directory = await getApplicationDocumentsDirectory();
    //Strip off the initial dirs from the filename
    assetPath = assetPath.split('/').last;

    final file = File('${directory.path}/$assetPath');

    // Write the bytes to a file in the file system
    await file.writeAsBytes(byteData.buffer.asUint8List());

    return file.path; // Return the file path
  }

  Future<ProveZkEmailResult?> proveZkEmail(
    String srsPath,
    String inputs
    ) async {
      // TODO
  }

  Future<VerifyZkEmailResult?> verifyZkEmail(
    String srsPath,
    String proof
  ) async {
    // TODO
  }
}
