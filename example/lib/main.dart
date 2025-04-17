import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:zkemail_flutter_package/zkemail_flutter_package_platform_interface.dart';
import 'package:zkemail_flutter_package/zkemail_flutter_package.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _zkemailFlutterPackagePlugin = ZkemailFlutterPackage();

  // State variables for zkEmail operations
  String? _zkEmailInputPath;
  String? _srsPath;
  ProveZkEmailResult? _proofResult;
  VerifyZkEmailResult? _verificationResult;
  String _status = 'Idle';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    // Copy assets needed for zkEmail operations
    _copyAssets();
  }

  Future<void> _copyAssets() async {
    setState(() {
      _status = 'Copying assets...';
      _errorMessage = null;
    });
    try {
      // Define asset paths relative to the 'assets' folder in pubspec.yaml
      const inputAssetPath = 'assets/zkemail_input.json';
      const srsAssetPath = 'assets/srs.local';

      // Copy assets to the file system and store their paths
      final inputPath = await _zkemailFlutterPackagePlugin.copyAssetToFileSystem(inputAssetPath);
      final srsPath = await _zkemailFlutterPackagePlugin.copyAssetToFileSystem(srsAssetPath);

      setState(() {
        _zkEmailInputPath = inputPath;
        _srsPath = srsPath;
        _status = 'Assets copied successfully. Ready.';
      });
    } catch (e) {
      setState(() {
        _status = 'Error copying assets';
        _errorMessage = e.toString();
      });
      print("Error copying assets: $e");
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _zkemailFlutterPackagePlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  // Function to call proveZkEmail
  Future<void> _callProveZkEmail() async {
    if (_zkEmailInputPath == null || _srsPath == null) {
       setState(() {
        _status = 'Assets not ready';
        _errorMessage = 'Please wait for assets to be copied or check for errors.';
      });
      return;
    }

    setState(() {
      _status = 'Parsing inputs...';
      _proofResult = null; // Clear previous results
      _verificationResult = null;
      _errorMessage = null;
    });

    try {
      // Parse the input JSON
      final inputs = await _zkemailFlutterPackagePlugin.parseZkEmailInputs(_zkEmailInputPath!);

      setState(() {
        _status = 'Generating proof...';
      });

      // Generate the proof
      final result = await _zkemailFlutterPackagePlugin.proveZkEmail(_srsPath!, inputs);

      setState(() {
        _proofResult = result;
        _status = result != null ? 'Proof generated successfully!' : 'Proof generation failed (result is null)';
      });
    } catch (e) {
      setState(() {
        _status = 'Error generating proof';
        _errorMessage = e.toString();
      });
      print("Error generating proof: $e");
    }
  }

  // Function to call verifyZkEmail
  Future<void> _callVerifyZkEmail() async {
    if (_proofResult?.proof == null || _srsPath == null) {
      setState(() {
        _status = 'Proof not available or SRS path missing';
        _errorMessage = 'Generate a proof first or ensure SRS path is valid.';
      });
      return;
    }

    setState(() {
      _status = 'Verifying proof...';
      _verificationResult = null; // Clear previous verification result
      _errorMessage = null;
    });

    try {
      // Verify the proof
      final result = await _zkemailFlutterPackagePlugin.verifyZkEmail(_srsPath!, _proofResult!.proof!);

      setState(() {
        _verificationResult = result;
        _status = result != null ? 'Verification finished.' : 'Verification failed (result is null)';
      });
    } catch (e) {
      setState(() {
        _status = 'Error verifying proof';
        _errorMessage = e.toString();
      });
      print("Error verifying proof: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('zkEmail Flutter Example'),
        ),
        body: Padding( // Added padding for better layout
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView( // Added for scrollability if content overflows
              child: Column( // Changed to Column for multiple widgets
                mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
                crossAxisAlignment: CrossAxisAlignment.center, // Center content horizontally
                children: <Widget>[
                  Text('Platform Version: $_platformVersion\n'),
                  const SizedBox(height: 10), // Spacing
                  Text('Status: $_status'), // Display current status
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Error: $_errorMessage',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 20), // Spacing
                  ElevatedButton(
                    onPressed: (_status == 'Generating proof...' || _status == 'Verifying proof...' || _status == 'Copying assets...') ? null : _callProveZkEmail, // Disable button while busy
                    child: const Text('Generate zkEmail Proof'),
                  ),
                  const SizedBox(height: 10), // Spacing
                   if (_proofResult != null) ...[ // Display proof details if available
                    const Text('Proof Generated:'),
                    // Displaying proof length as an example detail
                    Text('Proof Bytes Length: ${_proofResult?.proof?.length ?? 'N/A'}'),
                    // Optionally display public inputs if needed (requires formatting)
                    // Text('Public Inputs: ${_proofResult?.publicInputs ?? 'N/A'}'),
                    const SizedBox(height: 10),
                     ElevatedButton(
                      onPressed: (_status == 'Verifying proof...' || _proofResult?.proof == null) ? null : _callVerifyZkEmail, // Disable if verifying or no proof
                      child: const Text('Verify zkEmail Proof'),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (_verificationResult != null) ...[ // Display verification result
                    Text(
                      'Verification Result: ${_verificationResult?.isValid == true ? "Verified Successfully!" : "Verification Failed!"}',
                      style: TextStyle(
                        color: _verificationResult?.isValid == true ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                     // Optionally display verification details if needed
                    // Text('Verification Details: ${_verificationResult?.verificationDetails ?? 'N/A'}'),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
