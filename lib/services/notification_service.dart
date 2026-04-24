

import 'dart:convert';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../bloc/chat_timer/chat_timer_bloc.dart';
import '../bloc/notification/notification_bloc.dart';
import '../bloc/waitlist_bloc.dart';
import '../data/local/pref_service.dart';
import '../firebase_options.dart';
import '../main.dart';
import '../repository/repository.dart';
import '../resources/app_url.dart';
import '../view/dashboard/chat_page.dart';
import '../view/widgets/chat_ringtone.dart';
import 'call_kit_incoming.dart';

void subscribeToAppType(String appType) async {
  await FirebaseMessaging.instance.subscribeToTopic(appType);
}

const AndroidNotificationDetails androidNotificationDetails =
AndroidNotificationDetails(
  'bma1',
  'book.my.astro#push-notification-channel-name',
  channelDescription: 'bookMyAstro',
  importance: Importance.max,
  priority: Priority.max,
  playSound: true,
);

class NotificationService {
  // SHOW SIMPLE LOCAL NOTIFICATION
  static Future<void> _showSimpleNotification(RemoteMessage event) async {
    var random = Random();
    int randomPart = random.nextInt(999999);
    int notificationId =
        (DateTime.now().millisecondsSinceEpoch + randomPart) % 2147483647;

    flutterLocalNotificationsPlugin.show(
      notificationId,
      event.notification?.title,
      event.notification?.body,
      const NotificationDetails(android: androidNotificationDetails),
      payload: jsonEncode({
        "title": event.notification?.title,
        "body": event.notification?.body,
        "data": event.data,
      }),
    );
  }

  // INIT
  static Future<void> init(BuildContext context) async {
    await CallKitService.initialize();

    // FCM token
    FirebaseMessaging.instance.getToken().then((value) {
      print("FCM Token : $value");
      subscribeToAppType("partner");
    });

    flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
      _onDidReceiveBackgroundNotificationResponse,
    );

    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    // APP TERMINATED
    FirebaseMessaging.instance.getInitialMessage().then((event) async {
      if (event == null) return;

      if (event.notification?.title == "Chat Ended") {
        CallKitService.endAllCalls();
        if (navigationKey.currentContext != null) {
          navigationKey.currentContext!.read<ChatTimerBloc>().add(
            ChatEndEvent(userId: event.data["userId"] ?? ""),
          );
        }
        Repository().updateProfile({
          "isChatAvailable": true,
          "chatGroupId": "",
          "isNowAvailable": true,
        }, []);
      }
    });

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // ON TAP FROM BACKGROUND TO FOREGROUND
    FirebaseMessaging.onMessageOpenedApp.listen((event) async {
      if (event.notification?.title == "Chat") {
        ChatRingTone().stopRingtone(); // Stop ringtone
        if (navigationKey.currentContext != null) {
          navigationKey.currentContext!.read<NotificationBloc>().add(
            NotificationIncreaseEvent(mData: event.data),
          );
        }
      }
    });

    // FOREGROUND MESSAGES
    FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
      print("onMessage --> ${event.notification?.title}");
      print("data --> ${event.data}");

      // ************************************
      //        FIXED — CHAT NO CALLKIT
      // ************************************
      if (event.notification?.title == "Chat") {
        // await _showSimpleNotification(event);
        await _showSimpleNotification(event);
        ChatRingTone().playRingtone();
        if (navigationKey.currentContext != null) {
          navigationKey.currentContext!.read<NotificationBloc>().add(
            NotificationIncreaseEvent(mData: event.data),
          );
        }
        return;
      }

      // GOOD: Audio / Video → CallKit only
      if (event.notification?.title == "Audio Call") {
        CallKitService.showIncoming(mData: event.data, callType: 0);
        return;
      }

      if (event.notification?.title == "Video Call") {
        CallKitService.showIncoming(mData: event.data, callType: 1);
        return;
      }

      if (event.notification?.title == "Call Declined") {
        CallKitService.endAllCalls();
        return;
      }

      if (event.notification?.title == "Chat Ended") {
        CallKitService.endAllCalls();
        if (navigationKey.currentContext != null) {
          navigationKey.currentContext!.read<ChatTimerBloc>().add(
            ChatEndEvent(userId: event.data["userId"] ?? ""),
          );
          navigationKey.currentContext!.read<NotificationBloc>().add(
            NotificationResetEvent(event.data["userId"] ?? ""),
          );
        }
        Repository().updateProfile({
          "isChatAvailable": true,
          "chatGroupId": "",
          "isNowAvailable": true,
        }, []);
        return;
      }

      // DEFAULT → normal notification
      await _showSimpleNotification(event);
    });

    // BACKGROUND HANDLER
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  static Future<bool> checkSession() async {
    final p = PrefService();
    final regId = await p.getRegId();
    if (regId == null || regId.isEmpty) return false;

    final fcmToken = await FirebaseMessaging.instance.getToken();
    await Repository().updateProfile({"fcmToken": fcmToken}, []);
    return true;
  }

  // FOREGROUND TAP
  static Future<void> _onDidReceiveNotificationResponse(
      NotificationResponse response,
      ) async {
    var payload = jsonDecode(response.payload!);

    //  CHAT NOTIFICATION TAP open

    if (payload["title"] == "Chat") {
      ChatRingTone().stopRingtone(); // Stop ringtone
      var data = payload["data"];
      print("wwwwwwwwww data : $data");
      Repository().getUserProfile(data["userId"]).then((value) {
        navigationKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) =>
                ChatPage(userDetails: value.toJson(), chatId: data["chatId"]),
          ),
        );
        print("playload data userId : $value");
      });
      return;
    }

    // chat ended
    if (payload['title'] == "Chat Ended") {
      CallKitService.endAllCalls();
      if (navigationKey.currentState?.context != null) {
        navigationKey.currentState!.context.read<ChatTimerBloc>().add(
          ChatEndEvent(userId: payload["data"]["userId"]),
        );
      }
    }
  }

  // BACKGROUND TAP
  static Future<void> _onDidReceiveBackgroundNotificationResponse(
      NotificationResponse response,
      ) async {
    var payload = jsonDecode(response.payload!);
    //  CHAT OPEN NOTIFICATION TAP
    if (payload['title'] == "Chat") {
      ChatRingTone().stopRingtone(); // Stop ringtone if playing
      var data = payload["data"];

      Repository().getUserProfile(data["userId"]).then((value) {
        navigationKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) =>
                ChatPage(userDetails: value.toJson(), chatId: data["chatId"]),
          ),
        );
      });
      return;
    }
    if (payload['title'] == "Chat Ended") {
      CallKitService.endAllCalls();
      if (navigationKey.currentState?.context != null) {
        navigationKey.currentState!.context.read<ChatTimerBloc>().add(
          ChatEndEvent(userId: payload["data"]["userId"]),
        );
        navigationKey.currentState!.context.read<ChatTimerBloc>().add(
          ChatEndEvent(userId: payload["data"]["userId"]),
        );
      }
    }
  }

  // SERVER PUSH SENDER
  static Future<void> sendNotification(
      String fcmToken,
      String title,
      String body,
      Map<String, dynamic> mData,
      ) async {
    try {
      http.Response response = await http.post(
        Uri.parse('${AppUrl.baseUrl}/api/send-notification'),
        body: jsonEncode({
          "fcmToken": fcmToken,
          "title": title,
          "body": body,
          "data": mData,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      print("sendNotification response : ${response.body}");
    } catch (e) {
      print("sendNotification error : $e");
    }
  }
}

// *********************************************************************
//                       BACKGROUND HANDLER FIX
// *********************************************************************

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage event) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await PrefService.init();
  await CallKitService.initialize();

  print("Background event : ${event.data}");
  print("Background title : ${event.notification?.title}");

  // ****** FIX: CHAT SHOULD NOT SHOW CALLKIT *******
  // CHAT SHOULD NOT USE CALLKIT
  if (event.notification?.title == "Chat") {
    await NotificationService._showSimpleNotification(event);
    return;
  }

  if (event.notification?.title == "Audio Call") {
    await CallKitService.showIncoming(mData: event.data, callType: 0);
    return;
  }

  if (event.notification?.title == "Video Call") {
    await CallKitService.showIncoming(mData: event.data, callType: 1);
    return;
  }

  if (event.notification?.title == "Call Declined") {
    CallKitService.endAllCalls();
    return;
  }

  if (event.notification?.title == "Chat Ended") {
    CallKitService.endAllCalls();
    await Repository().updateProfile({
      "isChatAvailable": true,
      "chatGroupId": "",
      "isNowAvailable": true,
    }, []);
    return;
  }

  // Default → simple notification
  await NotificationService._showSimpleNotification(event);
}
