# zkEmail Flutter Package via Mopro

A Flutter plugin for verifying zkEmail proofs on mobile platforms (iOS/Android), built on top of the [Mopro](https://github.com/zkmopro/mopro) library. This package provides a simple interface to interact with the zkEmail Noir circuit.

## Getting Started

Follow these steps to integrate the zkEmail Flutter package into your project.

### Adding a package dependency to an app

1.  **Add Dependency:** You can add `zkemail_flutter_package` to your project using the command line or by manually editing `pubspec.yaml`.

    *   **Command Line (Recommended):**
        ```bash
        flutter pub add zkemail_flutter_package
        ```
        This command automatically adds the latest compatible version to your `pubspec.yaml`.

    *   **Manual Edit (Required for local path or specific Git dependencies):**
        Open your `pubspec.yaml` file and add `zkemail_flutter_package` under `dependencies`.

        ```yaml
        dependencies:
          flutter:
            sdk: flutter

          zkemail_flutter_package: ^0.1.0 # Replace with your desired version or path
          # Example using a local path:
          # zkemail_flutter_package:
          #   path: ../path/to/zkemail_flutter_package
        ```

2.  **Update zkEmail Assets:** Include your zkEmail SRS file (e.g., `srs.local`) and email JSON file (e.g., `input.json`) as assets. Add the asset paths to your `pubspec.yaml` under the `flutter:` section:

    ```yaml
    flutter:
      uses-material-design: true # Ensure this is present
      assets:
        # Add the directory containing your zkEmail assets
        - assets/zkemail/
        # Or specify the files directly:
        # - assets/zkemail/srs.bin
        # - assets/zkemail/input.json
    ```
    *Make sure the paths point correctly to where you've placed your asset files within your Flutter project.*

3.  **Install Package:** Run the following command in your terminal from the root of your Flutter project:

    ```bash
    flutter pub get
    ```

## Usage Example

Here's a basic example demonstrating how to use the package to generate and verify a zkEmail proof.

```dart
import 'dart:typed_data'; // Required for Uint8List
import 'package:flutter/material.dart';
import 'package:zkemail_flutter_package/zkemail_flutter_package.dart';
// Assuming result types are defined in the platform interface or a types file
// (You might need to adjust imports based on your project structure)
import 'package:zkemail_flutter_package/zkemail_flutter_package_platform_interface.dart';

void main() {
  runApp(const MyApp());
}

// --- Example Usage Widget ---
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ZkemailFlutterPackage _zkEmail = ZkemailFlutterPackage();
  String _status = 'Idle';
  Uint8List? _proof;
  bool? _verificationResult;

  // Define your asset paths as specified in pubspec.yaml
  static const String srsAssetPath = 'assets/zkemail/srs.bin';
  static const String inputJsonAssetPath = 'assets/zkemail/input.json';

  @override
  void initState() {
    super.initState();
  }

  Future<void> _runProveAndVerifyZkEmail() async {
    setState(() => _status = 'Initializing...');

    try {
      // --- 1. Copy Assets to File System ---
      // Native code needs file paths, so copy assets from bundle
      setState(() => _status = 'Copying assets...');
      final String srsFilePath = await _zkEmail.copyAssetToFileSystem(srsAssetPath);
      final String inputJsonFilePath = await _zkEmail.copyAssetToFileSystem(inputJsonAssetPath);
      print('SRS copied to: $srsFilePath');
      print('Input JSON copied to: $inputJsonFilePath');

      // --- 2. Parse Inputs ---
      setState(() => _status = 'Parsing input JSON...');
      final Map<String, List<String>> inputs = await _zkEmail.parseZkEmailInputs(inputJsonFilePath);
      print('Inputs parsed successfully.');

      // --- 3. Generate Proof ---
      setState(() => _status = 'Generating zkEmail proof...');
      // Ensure srsFilePath is accessible by the native code
      final ProveZkEmailResult? proveResult = await _zkEmail.proveZkEmail(
        srsFilePath,
        inputs,
      );

      if (proveResult == null) {
         throw Exception('Proof generation returned null.');
      }

      setState(() {
         _status = 'Proof generated. Verifying...';
         _proof = proveResult.proof; // Store proof bytes
      });
      print('Proof generated successfully.');

      // --- 4. Verify Proof ---
      setState(() => _status = 'Verifying proof...');
      final VerifyZkEmailResult? verifyResult = await _zkEmail.verifyZkEmail(
        srsFilePath, // Use the same SRS path
        proveResult.proof, // Use the generated proof bytes
      );

       if (verifyResult == null) {
         throw Exception('Verification returned null.');
      }

      setState(() {
        _verificationResult = verifyResult.isValid;
        _status = verifyResult.isValid ? 'Proof Verified Successfully!' : 'Proof Verification Failed!';
      });

      // Optional: Log results
      print('Proof Bytes Length: ${proveResult.proof.length}');
      print('Verification result: ${verifyResult.isValid}');

    } catch (e) {
      setState(() => _status = 'Error: $e');
      print('Error caught during zkEmail prove/verify: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('zkEmail Flutter Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Status: $_status'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _runProveAndVerifyZkEmail,
                child: const Text('Run Prove & Verify'),
              ),
              const SizedBox(height: 20),
              if (_proof != null)
                Text('Proof generated (length: ${_proof!.length})'),
              if (_verificationResult != null)
                Text('Verification Result: $_verificationResult'),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder result types (Adjust based on actual implementation)
// These might be defined in zkemail_flutter_package_platform_interface.dart
/*
class ProveZkEmailResult {
  final Uint8List proof;
  ProveZkEmailResult({required this.proof});
}

class VerifyZkEmailResult {
  final bool isValid;
  VerifyZkEmailResult({required this.isValid});
}
*/
```

> [!WARNING]  
> The current bindings are built specifically for the standard zkEmail Noir circuit. If you need to update the circuit logic, constraints, or switch to a different proving scheme, you will need to rebuild the underlying native libraries using the Mopro CLI.

## How to Build the Package

This package relies on bindings generated by the Mopro CLI.
To learn how to build Mopro bindings, refer to the [Mopro Getting Started Guide](https://zkmopro.org/docs/getting-started).
If you'd like to generate custom bindings for your own circuits or proving schemes, check out the guide on how to use the Mopro CLI: [Rust Setup for Android/iOS Bindings](https://zkmopro.org/docs/setup/rust-setup#setup-any-rust-project).

## Community

-   X account: <a href="https://twitter.com/zkmopro"><img src="https://img.shields.io/twitter/follow/zkmopro?style=flat-square&logo=x&label=zkmopro"></a>
-   Telegram group: <a href="https://t.me/zkmopro"><img src="https://img.shields.io/badge/telegram-@zkmopro-blue.svg?style=flat-square&logo=telegram"></a>

## Acknowledgements

This work utilizes the Mopro library, initially sponsored by a joint grant from [PSE](https://pse.dev/) and [0xPARC](https://0xparc.org/) and currently incubated by PSE.
