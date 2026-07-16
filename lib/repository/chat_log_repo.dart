import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../resources/app_url.dart';

class ChatLoggerRepo {
  static final ChatLoggerRepo _instance = ChatLoggerRepo._internal();
  factory ChatLoggerRepo() => _instance;
  ChatLoggerRepo._internal();

  // Cached device values so we don't fetch them on every log
  String _deviceModel = "Unknown";
  String _os = "Unknown";
  String _osVersion = "Unknown";
  String _appVersion = "Unknown";
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        _deviceModel = '${androidInfo.brand} ${androidInfo.model}';
        _os = 'Android';
        _osVersion = androidInfo.version.release;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        _deviceModel = iosInfo.name;
        _os = 'iOS';
        _osVersion = iosInfo.systemVersion;
      }

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      _appVersion = packageInfo.version;

      _isInitialized = true;
    } catch (e) {
      log("ChatLoggerRepo Init Error: $e");
    }
  }

  Future<void> logEvent({
    required String userId,
    required String vendorId,
    required String sessionId,
    required String eventType,
    required String message,
    required String appState,
    required bool isConnected,
    int retryCount = 0,
  }) async {
    try {
      if (!_isInitialized) await init();

      // Get real-time network status
      final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
      String networkType = "unknown";
      if (connectivityResult.contains(ConnectivityResult.mobile)) {
        networkType = "mobile";
      } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
        networkType = "wifi";
      } else if (connectivityResult.contains(ConnectivityResult.none)) {
        networkType = "none";
      }

      final body = {
        "eventId": const Uuid().v4(),
        "userId": userId,
        "vendorId": vendorId,
        "sessionId": sessionId,
        "eventType": eventType,
        "message": message,
        "timestamp": DateTime.now().toIso8601String(),
        "networkType": networkType,
        "appState": appState,
        "deviceModel": _deviceModel,
        "os": _os,
        "osVersion": _osVersion,
        "appVersion": _appVersion,
        "sdkVersion": "Agora Chat",
        "retryCount": retryCount,
        "isConnected": isConnected
      };

      final response = await http.post(
        Uri.parse('${AppUrl.baseUrl}/api/chat/chat-logs'),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );
      if (kDebugMode) {
        print("Chat Log Status: ${response.statusCode}");
      }
      if (kDebugMode) {
        print("Chat Log Response: ${response.body}");
      }
    } catch (e) {
      log("ChatLoggerRepo Log Error: $e");
    }
  }
}
