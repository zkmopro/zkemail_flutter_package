package com.zkmopro.zkemail_flutter_package

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

import uniffi.mopro.proveZkemail
import uniffi.mopro.verifyZkemail

/** ZkemailFlutterPackagePlugin */
class ZkemailFlutterPackagePlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var flutterPluginBinding: FlutterPlugin.FlutterPluginBinding
  private val scope = CoroutineScope(Dispatchers.IO)

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    this.flutterPluginBinding = flutterPluginBinding
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "zkemail_flutter_package")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    scope.launch {
      try {
        when (call.method) {
          "getPlatformVersion" -> {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
          }
          "getApplicationDocumentsDirectory" -> {
            val context = flutterPluginBinding.applicationContext
            val directory = context.getExternalFilesDir(null)
            result.success(directory?.absolutePath)
          }
          "proveZkEmail" -> {
            val srsPath = call.argument<String>("srsPath")
            @Suppress("UNCHECKED_CAST")
            val inputs = call.argument<Map<String, List<String>>>("inputs")

            if (srsPath == null || inputs == null) {
              launch(Dispatchers.Main) {
                result.error("INVALID_ARGUMENTS", "srsPath or inputs is null", null)
              }
              return@launch
            }

            val proofBytes = proveZkemail(srsPath!!, inputs!!)
            launch(Dispatchers.Main) {
              result.success(mapOf("proof" to proofBytes, "error" to null))
            }
          }
          "verifyZkEmail" -> {
            val srsPath = call.argument<String>("srsPath")
            val proof = call.argument<ByteArray>("proof")

            if (srsPath == null || proof == null) {
              launch(Dispatchers.Main) {
                result.error("INVALID_ARGUMENTS", "srsPath or proof is null", null)
              }
              return@launch
            }

            val isValid = verifyZkemail(srsPath!!, proof!!)
            launch(Dispatchers.Main) {
              result.success(mapOf("isValid" to isValid, "error" to null))
            }
          }
          else -> {
            launch(Dispatchers.Main) {
              result.notImplemented()
            }
          }
        }
      } catch (e: Exception) {
        launch(Dispatchers.Main) {
          when (call.method) {
            "proveZkEmail" -> result.success(mapOf("proof" to null, "error" to e.message))
            "verifyZkEmail" -> result.success(mapOf("isValid" to false, "error" to e.message))
            else -> result.error("NATIVE_ERROR", e.message, e.stackTraceToString())
          }
        }
      }
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
