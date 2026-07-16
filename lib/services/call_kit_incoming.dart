// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:flutter_callkit_incoming/entities/android_params.dart';
// import 'package:flutter_callkit_incoming/entities/call_event.dart';
// import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
// import 'package:flutter_callkit_incoming/entities/ios_params.dart';
// import 'package:flutter_callkit_incoming/entities/notification_params.dart';
// import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:uuid/uuid.dart';
// import '../main.dart';
// import '../view/private_121_audio_call.dart';
// import '../view/private_121_video_call.dart';
// import 'notification_service.dart' hide ringtonePlayer;
//
// class CallKitService {
//   static bool _isInitialized = false;
//   static StreamSubscription<CallEvent?>? _callKitSub;
//
//   /// Initialize once at app start
//   static Future<void> initialize() async {
//     if (_isInitialized) return;
//     try {
//       await FlutterCallkitIncoming.requestFullIntentPermission();
//
//       // Attach single global listener
//       _callKitSub = FlutterCallkitIncoming.onEvent.listen(_handleEvent);
//
//       _isInitialized = true;
//       log("✅ CallKit initialized & listener attached");
//     } catch (e) {
//       log("❌ Error initializing CallKit: $e");
//     }
//   }
//
//   /// Show incoming call UI
//   static Future<void> showIncoming({
//     required Map<String, dynamic> mData,
//     required int callType,
//   }) async {
//     if (!_isInitialized) {
//       await initialize();
//     }
//
//     log("📞 Showing incoming call…");
//
//     CallKitParams callKitParams = CallKitParams(
//       id: const Uuid().v4(),
//       nameCaller: mData["userName"] ?? "Unknown",
//       appName: 'Callkit',
//       avatar: 'https://picsum.photos/100',
//       handle: '0123456789',
//       type: callType,
//       textAccept: 'Accept',
//       textDecline: 'Decline',
//       missedCallNotification: const NotificationParams(
//         showNotification: false,
//         isShowCallback: false,
//       ),
//       duration: 120000,
//       extra: mData,
//       headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
//       android: const AndroidParams(
//         isCustomNotification: true,
//         isShowLogo: false,
//         ringtonePath: 'system_ringtone_default',
//         backgroundColor: '#0955fa',
//         actionColor: '#4CAF50',
//         textColor: '#ffffff',
//         incomingCallNotificationChannelName: "Incoming Call",
//         missedCallNotificationChannelName: "Missed Call",
//         isShowCallID: false,
//         isShowFullLockedScreen: true,
//       ),
//       ios: const IOSParams(
//         iconName: 'CallKitLogo',
//         handleType: 'generic',
//         supportsVideo: true,
//         maximumCallGroups: 2,
//         maximumCallsPerCallGroup: 1,
//         audioSessionMode: 'default',
//         audioSessionActive: true,
//         audioSessionPreferredSampleRate: 44100.0,
//         audioSessionPreferredIOBufferDuration: 0.005,
//         supportsDTMF: true,
//         supportsHolding: true,
//         supportsGrouping: false,
//         supportsUngrouping: false,
//         ringtonePath: 'system_ringtone_default',
//       ),
//     );
//
//     await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
//   }
//
//   /// Show outgoing call
//   static Future<void> showOutGoing() async {
//     CallKitParams params = const CallKitParams(
//       id: '46544498',
//       nameCaller: 'Hien Nguyen',
//       handle: '0123456789',
//       type: 1,
//       extra: <String, dynamic>{'userId': '1a2b3c4d'},
//       android: AndroidParams(
//         isCustomNotification: true,
//         isShowLogo: false,
//         ringtonePath: 'system_ringtone_default',
//         backgroundColor: '#0955fa',
//         backgroundUrl: 'https://i.pravatar.cc/500',
//         actionColor: '#4CAF50',
//         textColor: '#ffffff',
//         isShowFullLockedScreen: true,
//         incomingCallNotificationChannelName: "Incoming Call",
//         missedCallNotificationChannelName: "Missed Call",
//         isShowCallID: false,
//       ),
//       ios: IOSParams(handleType: 'generic'),
//     );
//     log("📞 Outgoing call params: $params");
//     await FlutterCallkitIncoming.startCall(params);
//   }
//
//   /// Show missed call (or end all calls)
//   static Future<void> showMissedCall({
//     required Map<String, dynamic> mData,
//   }) async {
//     CallKitParams params = CallKitParams(
//       id: const Uuid().v4(),
//       nameCaller: '${mData['name']}',
//       handle: 'Missed call',
//       type: 1,
//       extra: mData,
//     );
//     await FlutterCallkitIncoming.endAllCalls();
//   }
//
//   /// End all calls
//   static Future<void> endAllCalls() async {
//     try {
//       await FlutterCallkitIncoming.endAllCalls();
//     } catch (e) {
//       log("❌ endAllCalls error $e");
//     }
//   }
//
//   /// Global event handler
//   static Future<void> _handleEvent(CallEvent? event) async {
//     if (event == null) return;
//     log("📲 CallKit Event: ${event.event}, body: ${event.body}");
//
//     switch (event.event) {
//       case Event.actionCallIncoming:
//         log("➡️ Incoming Call");
//         break;
//
//       case Event.actionCallStart:
//         log("▶️ Call start");
//         break;
//
//       case Event.actionCallAccept:
//         log("✅ Call accepted: ${event.body}");
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('call_data', jsonEncode(event.body));
//
//         if (event.body["type"].toString() == "0") {
//           // Audio call
//           if (navigationKey.currentState != null) {
//             navigationKey.currentState?.push(
//               MaterialPageRoute(
//                 builder: (context) => Private121AudioCall(mData: event.body),
//               ),
//             );
//           }
//         } else if (event.body["type"].toString() == "1") {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             navigationKey.currentState?.push(
//               MaterialPageRoute(
//                 builder: (context) => Private121VideoCall(mData: event.body),
//               ),
//             );
//           });
//         }
//         /*else if (event.body["type"].toString() == "1") {
//           // Chat
//           Repository().getUserProfile(event.body["extra"]["userId"]).then((
//               value,
//               ) {
//             navigationKey.currentState?.push(
//               MaterialPageRoute(
//                 builder: (context) => ChatPage(
//                   userDetails: value.toJson(),
//                   chatId: event.body["extra"]["chatId"],
//                 ),
//               ),
//             );
//           });
//         }*/
//         break;
//
//       case Event.actionCallDecline:
//         log("❌ Call declined: ${event.body}");
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.remove('call_data');
//         // NotificationService.sendNotification(
//         //   "${event.body["extra"]["userFcmToken"]}",
//         //   "Call Declined",
//         //   "Call Declined ",
//         //   (event.body["extra"] as Map).cast<String, dynamic>(),
//         // );
//         final extra = (event.body["extra"] as Map).cast<String, dynamic>();
//         final payload = Map<String, dynamic>.from(extra)
//           ..['disconnectedBy'] = 'astrologer'
//           ..['status'] = 'declined';
//         NotificationService.sendNotification(
//           "${extra['userFcmToken']}",
//           "Call Declined",
//           "Call Declined ",
//           payload,
//         );
//         NotificationService.dismissNotifications();
//         break;
//
//       case Event.actionCallEnded:
//         log("🔴 Call ended: ${event.body}");
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.remove('call_data');
//         NotificationService.sendNotification(
//           "${event.body["extra"]["userFcmToken"]}",
//           "Call Ended",
//           "Call Ended ",
//           (event.body["extra"] as Map).cast<String, dynamic>(),
//         );
//         NotificationService.dismissNotifications();
//         break;
//
//       case Event.actionCallTimeout:
//         log("⌛ Missed call: ${event.body}");
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.remove('call_data');
//         NotificationService.sendNotification(
//           "${event.body["extra"]["userFcmToken"]}",
//           "Call Missed",
//           "Call Missed ",
//           (event.body["extra"] as Map).cast<String, dynamic>(),
//         );
//         NotificationService.dismissNotifications();
//         break;
//
//       case Event.actionCallConnected:
//         log("🔗 Call connected: ${event.body}");
//         // ✅ no crash anymore
//         break;
//
//       case Event.actionDidUpdateDevicePushTokenVoip:
//         log("🔑 VoIP push token updated");
//         break;
//
//       default:
//         log("ℹ️ Unhandled CallKit event: ${event.event}");
//     }
//   }
//
//   /// Dispose listener
//   static Future<void> dispose() async {
//     await _callKitSub?.cancel();
//     _callKitSub = null;
//     _isInitialized = false;
//   }
// }


import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../main.dart';
import '../repository/repository.dart';
import '../view/dashboard/chat_page.dart';
import '../view/private_121_audio_call.dart';
import '../view/private_121_video_call.dart';
import 'notification_service.dart' hide ringtonePlayer;
import '../data/local/pref_service.dart';

class CallKitService {
  static bool _isInitialized = false;
  static StreamSubscription<CallEvent?>? _callKitSub;

  /// Initialize once at app start
  static Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await FlutterCallkitIncoming.requestFullIntentPermission();

      // Attach single global listener
      _callKitSub = FlutterCallkitIncoming.onEvent.listen(_handleEvent);

      _isInitialized = true;
      log("✅ CallKit initialized & listener attached");
    } catch (e) {
      log("❌ Error initializing CallKit: $e");
    }
  }

  /// Show incoming call UI
  static Future<void> showIncoming({
    required Map<String, dynamic> mData,
    required int callType,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    log("📞 Showing incoming call…");

    // ChatLoggerRepo().logEvent(
    //   userId: PrefService().getRegId() ?? "unknown",
    //   vendorId: mData["vendorId"] ?? mData["userId"] ?? "unknown",
    //   sessionId: mData["chatId"] ?? mData["callId"] ?? "unknown",
    //   eventType: "CALLKIT_SHOWING",
    //   message: "Showing Incoming Call UI via CallKit (Type: $callType)",
    //   appState: "background",
    //   isConnected: false,
    // );

    CallKitParams callKitParams = CallKitParams(
      id: const Uuid().v4(),
      nameCaller: mData["userName"] ?? "Unknown",
      appName: 'Callkit',
      avatar: 'https://picsum.photos/100',
      handle: '0123456789',
      type: callType,
      textAccept: 'Accept',
      textDecline: 'Decline',
      missedCallNotification: const NotificationParams(
        showNotification: false,
        isShowCallback: false,
      ),
      duration: 120000,
      extra: mData,
      headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955fa',
        actionColor: '#4CAF50',
        textColor: '#ffffff',
        incomingCallNotificationChannelName: "Incoming Call",
        missedCallNotificationChannelName: "Missed Call",
        isShowCallID: false,
        isShowFullLockedScreen: true,
      ),
      ios: const IOSParams(
        iconName: 'CallKitLogo',
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
  }

  /// Show outgoing call
  static Future<void> showOutGoing() async {
    CallKitParams params = const CallKitParams(
      id: '46544498',
      nameCaller: 'Hien Nguyen',
      handle: '0123456789',
      type: 1,
      extra: <String, dynamic>{'userId': '1a2b3c4d'},
      android: AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955fa',
        backgroundUrl: 'https://i.pravatar.cc/500',
        actionColor: '#4CAF50',
        textColor: '#ffffff',
        isShowFullLockedScreen: true,
        incomingCallNotificationChannelName: "Incoming Call",
        missedCallNotificationChannelName: "Missed Call",
        isShowCallID: false,
      ),
      ios: IOSParams(handleType: 'generic'),
    );
    log("📞 Outgoing call params: $params");
    await FlutterCallkitIncoming.startCall(params);
  }

  /// Show missed call (or end all calls)
  static Future<void> showMissedCall({
    required Map<String, dynamic> mData,
  }) async {
    CallKitParams params = CallKitParams(
      id: const Uuid().v4(),
      nameCaller: '${mData['name']}',
      handle: 'Missed call',
      type: 1,
      extra: mData,
    );
    await FlutterCallkitIncoming.endAllCalls();
  }

  /// End all calls
  static Future<void> endAllCalls() async {
    try {
      await FlutterCallkitIncoming.endAllCalls();
    } catch (e) {
      log("❌ endAllCalls error $e");
    }
  }

  /// Global event handler
  static Future<void> _handleEvent(CallEvent? event) async {
    if (event == null) return;
    log("📲 CallKit Event: ${event.event}, body: ${event.body}");

    switch (event.event) {
      case Event.actionCallIncoming:
        log("➡️ Incoming Call");
        break;

      case Event.actionCallStart:
        log("▶️ Call start");
        break;

      case Event.actionCallAccept:
        log("✅ Call accepted: ${event.body}");
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('call_data', jsonEncode(event.body));

        // ChatLoggerRepo().logEvent(
        //   userId: PrefService().getRegId() ?? "unknown",
        //   vendorId: event.body["extra"]?["vendorId"] ?? event.body["extra"]?["userId"] ?? "unknown",
        //   sessionId: event.body["extra"]?["chatId"] ?? event.body["extra"]?["callId"] ?? "unknown",
        //   eventType: "CALLKIT_ACCEPTED",
        //   message: "User accepted the call via CallKit UI",
        //   appState: "foreground",
        //   isConnected: false,
        // );

        if (event.body["type"].toString() == "0") {
          // Audio call
          if (navigationKey.currentState != null) {
            navigationKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => Private121AudioCall(mData: event.body),
              ),
            );
          }
        }
        // else if (event.body["type"].toString() == "1") {
        //   WidgetsBinding.instance.addPostFrameCallback((_) {
        //     navigationKey.currentState?.push(
        //       MaterialPageRoute(
        //         builder: (context) => Private121VideoCall(mData: event.body),
        //       ),
        //     );
        //   });
        // }
        /*else if (event.body["type"].toString() == "1") {
          // Chat
          Repository().getUserProfile(event.body["extra"]["userId"]).then((
              value,
              ) {
            navigationKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  userDetails: value.toJson(),
                  chatId: event.body["extra"]["chatId"],
                ),
              ),
            );
          });
        }*/
        break;

      case Event.actionCallDecline:
        log("❌ Call declined: ${event.body}");
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('call_data');

        // ChatLoggerRepo().logEvent(
        //   userId: PrefService().getRegId() ?? "unknown",
        //   vendorId: event.body["extra"]?["vendorId"] ?? event.body["extra"]?["userId"] ?? "unknown",
        //   sessionId: event.body["extra"]?["chatId"] ?? event.body["extra"]?["callId"] ?? "unknown",
        //   eventType: "CALLKIT_DECLINED",
        //   message: "User declined the call via CallKit UI",
        //   appState: "foreground",
        //   isConnected: false,
        // );

        // NotificationService.sendNotification(
        //   "${event.body["extra"]["userFcmToken"]}",
        //   "Call Declined",
        //   "Call Declined By Astrologer",
        //   (event.body["extra"] as Map).cast<String, dynamic>(),
        // );
        final extra = (event.body["extra"] as Map).cast<String, dynamic>();
        final payload = Map<String, dynamic>.from(extra)
          ..['disconnectedBy'] = 'astrologer'
          ..['status'] = 'declined';
        NotificationService.sendNotification(
          "${extra['userFcmToken']}",
          "Call Declined",
          "Call Declined",
          payload,
        );
        NotificationService.dismissNotifications();
        break;

      case Event.actionCallEnded:
        log(" Call ended: ${event.body}");
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('call_data');
        NotificationService.sendNotification(
          "${event.body["extra"]["userFcmToken"]}",
          "Call Ended",
          "Call Ended",
          (event.body["extra"] as Map).cast<String, dynamic>(),
        );
        NotificationService.dismissNotifications();
        break;

      case Event.actionCallTimeout:
        log("⌛ Missed call: ${event.body}");
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('call_data');

        // ChatLoggerRepo().logEvent(
        //   userId: PrefService().getRegId() ?? "unknown",
        //   vendorId: event.body["extra"]?["vendorId"] ?? event.body["extra"]?["userId"] ?? "unknown",
        //   sessionId: event.body["extra"]?["chatId"] ?? event.body["extra"]?["callId"] ?? "unknown",
        //   eventType: "CALLKIT_TIMEOUT",
        //   message: "Call timed out (Missed Call)",
        //   appState: "background",
        //   isConnected: false,
        // );

        NotificationService.sendNotification(
          "${event.body["extra"]["userFcmToken"]}",
          "Call Missed",
          "Call Missed",
          (event.body["extra"] as Map).cast<String, dynamic>(),
        );
        NotificationService.dismissNotifications();
        break;

      case Event.actionCallConnected:
        log("🔗 Call connected: ${event.body}");
        // ✅ no crash anymore
        break;

      case Event.actionDidUpdateDevicePushTokenVoip:
        log("🔑 VoIP push token updated");
        break;

      default:
        log("ℹ️ Unhandled CallKit event: ${event.event}");
    }
  }

  /// Dispose listener
  static Future<void> dispose() async {
    await _callKitSub?.cancel();
    _callKitSub = null;
    _isInitialized = false;
  }
}
