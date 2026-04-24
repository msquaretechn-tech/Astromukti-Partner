// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
// import 'package:astrologer_admin_panel/data/local/pref_service.dart';
// import 'package:astrologer_admin_panel/resources/resources.dart';
// import 'package:astrologer_admin_panel/routes/routes_name.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../private_121_audio_call.dart';
// import '../private_121_video_call.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     manageSession();
//   }
//
//   /// maneging User Session
//   manageSession() async {
//     DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//     AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
//
//     print('Device Model: ${androidInfo.model}');
//     print('Android Version: ${androidInfo.version.release}');
//     print('Brand: ${androidInfo.brand}');
//     print('Device ID (Android ID): ${androidInfo.id}');
//
//     PrefService prefService = PrefService();
//     final prefs = await SharedPreferences.getInstance();
//     var regId = await prefService.getRegId();
//     var token = await prefService.getToken();
//     log("Vendor regId:  $regId");
//     log("Vendor Token: splash  $token");
//
//     final callData = prefs.getString('call_data');
//
//     log("callData Splash $callData");
//
//     if (regId != "" && token != "" && regId != null && token != null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) async {
//         if (callData != null) {
//           log("callData Splash $callData");
//           var data = jsonDecode(callData);
//           log("callData Splash data : $data");
//
//           await prefs.remove('call_data');
//
//           // First push the main navigation screen
//           GoRouter.of(context)
//               .pushReplacementNamed(RoutesName.navigationScreen);
//
//           // Delay slightly to ensure the navigation screen is built before pushing the call screen
//           Future.delayed(const Duration(milliseconds: 500), () {
//             if (data["type"].toString() == "0") {
//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                     builder: (context) => Private121AudioCall(mData: data)),
//               );
//             } else if (data["type"].toString() == "1") {
//               // Fluttertoast.showToast(msg: "Hi there");
//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                     builder: (context) => Private121VideoCall(mData: data)),
//               );
//             }
//           });
//         } else {
//           // Normal navigation when no call data
//           GoRouter.of(context)
//               .pushReplacementNamed(RoutesName.navigationScreen);
//           // Navigator.of(context).push(
//           //   MaterialPageRoute(
//           //       builder: (context) => AgoraLocalPreview()),
//           // );
//         }
//       });
//     } else {
//       Timer(const Duration(seconds: 3), () {
//         GoRouter.of(context).pushReplacementNamed(RoutesName.loginScreen);
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Resources.colors.themeColor,
//       body: Center(
//         child: Image.asset(
//           Resources.images.appLogo,
//           height: 200,
//           width: 200,
//         ),
//       ),
//     );
//   }
// }
import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/local/pref_service.dart';
import '../../repository/repository.dart';
import '../../resources/resources.dart';
import '../../routes/routes_name.dart';
import '../private_121_audio_call.dart';
import '../private_121_video_call.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Get device information (optional - remove if not needed)
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      log(
        'Device Info: ${deviceInfo.model}, Android ${deviceInfo.version.release}',
      );

      // Check authentication status
      final isAuthenticated = await _checkAuthentication();

      // Process any pending call data
      await _processPendingCallData(isAuthenticated);

      // Navigate to appropriate screen
      if (!isAuthenticated) {
        _navigateToLogin();
      }
    } catch (e) {
      log('Initialization error: $e');
      _navigateToLogin();
    }
  }

  Future<bool> _checkAuthentication() async {
    final prefService = PrefService();
    final regId = await prefService.getRegId();
    final token = await prefService.getToken();
    return regId != null &&
        regId.isNotEmpty &&
        token != null &&
        token.isNotEmpty;
  }

  Future<void> _processPendingCallData(bool isAuthenticated) async {
    if (!isAuthenticated) return;

    final prefs = await SharedPreferences.getInstance();
    final callData = prefs.getString('call_data');
    print("callData callData $callData");
    log("callData log $callData");
    debugPrint("callData debug $callData");

    if (callData == null) {
      _navigateToHome();
      return;
    }

    try {
      final data = jsonDecode(callData);
      final isValidCall = _validateCallData(data);

      // Always remove call data regardless of validity
      await prefs.remove('call_data');

      if (isValidCall) {
        _navigateToCallScreen(data);
      } else {
        _navigateToHome();
      }
    } catch (e) {
      log('Error processing call data: $e');
      _navigateToHome();
    }
  }

  bool _validateCallData(Map<String, dynamic> data) {
    // Validate call type
    if (data['type'] == null) return false;

    // Validate timestamp (if you included one)
    if (data['timestamp'] != null) {
      final callTime = DateTime.fromMillisecondsSinceEpoch(data['timestamp']);
      final now = DateTime.now();
      return now.difference(callTime).inSeconds < 30;
    }

    return true;
  }

  void _navigateToHome() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GoRouter.of(context).pushReplacementNamed(RoutesName.navigationScreen);
    });
  }

  void _navigateToLogin() {
    Timer(const Duration(seconds: 3), () {
      GoRouter.of(context).pushReplacementNamed(RoutesName.loginScreen);
    });
  }

  void _navigateToCallScreen(Map<String, dynamic> data) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // First navigate to home
      GoRouter.of(context).pushReplacementNamed(RoutesName.navigationScreen);
      Future.delayed(const Duration(milliseconds: 500), () async {
        if (!mounted) return;
        final callType = data['type'].toString();
        log("callType Splash data : $callType");
        print("callType  data : $data");

        print("callType  chatId : ${data["extra"]["chatId"]}");
        final userProfile = await Repository().getUserProfile(
          data["extra"]["userId"],
        );
        if (!mounted) return;
        print("callType  userProfile : $userProfile");
        final callScreen = callType == '0'
            ? Private121AudioCall(mData: data)
            : Private121VideoCall(mData: data);
        print("callType  chatIdd : ${data["extra"]["chatId"]}");
        print("callType  userProfileee : $userProfile");
        
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => callScreen));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(Resources.images.appLogo, height: 300, width: 300),
      ),
    );
  }
}
