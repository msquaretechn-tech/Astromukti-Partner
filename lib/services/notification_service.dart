
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/chat_timer/chat_timer_bloc.dart';
import '../bloc/notification/notification_bloc.dart';
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

// Default notification channel
const AndroidNotificationDetails androidNotificationDetails =
AndroidNotificationDetails(
  'bma1',
  'book.my.astro#push-notification-channel-name',
  channelDescription: 'bookMyAstro',
  importance: Importance.max,
  priority: Priority.max,
  playSound: true,
);

// Chat-specific notification channel with custom ringtone sound
// 'ringtone' refers to res/raw/ringtone.mp3 in Android
final AndroidNotificationDetails chatNotificationDetails =
AndroidNotificationDetails(
  'bma_chat',
  'Chat Ringtone',
  channelDescription: 'Incoming chat notification with ringtone',
  importance: Importance.max,
  priority: Priority.max,
  playSound: true,
  sound: const RawResourceAndroidNotificationSound('ringtone'),
  enableVibration: true,
  ongoing: false,
  autoCancel: true,
);

class NotificationService {
  // SHOW SIMPLE LOCAL NOTIFICATION
  static Future<void> _showSimpleNotification(RemoteMessage event) async {
    var random = Random();
    int randomPart = random.nextInt(999999);

    String? title = event.notification?.title ?? event.data['title'];

    // Use constant IDs for active session related notifications
    int notificationId;
    if (title == "Chat") {
      notificationId = 1001;
    } else if (title == "Audio Call" ) {
      notificationId = 1002;
    } else {
      notificationId = (DateTime.now().millisecondsSinceEpoch + randomPart) % 2147483647;
    }

    // Use chat channel (with ringtone sound) for Chat, default for rest
    final notifDetails = title == "Chat"
        ? NotificationDetails(android: chatNotificationDetails)
        : const NotificationDetails(android: androidNotificationDetails);

    flutterLocalNotificationsPlugin.show(
      notificationId,
      event.notification?.title ?? event.data['title'],
      event.notification?.body ?? event.data['body'],
      notifDetails,
      payload: jsonEncode({
        "title": event.notification?.title ?? event.data['title'],
        "body": event.notification?.body ?? event.data['body'],
        "data": event.data,
      }),
    );
  }

  // DISMISS ALL NOTIFICATIONS
  static Future<void> dismissNotifications() async {
    try {
      await flutterLocalNotificationsPlugin.cancel(1001);
      await flutterLocalNotificationsPlugin.cancel(1002);
      await flutterLocalNotificationsPlugin.cancelAll();
      print("All notifications dismissed ✅");
    } catch (e) {
      print("Error dismissing notifications: $e");
    }
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
        ChatRingTone().stopRingtone();
        CallKitService.endAllCalls();
        dismissNotifications();
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

        // ChatLoggerRepo().logEvent(
        //   userId: PrefService().getRegId() ?? "unknown",
        //   vendorId: event.data["vendorId"] ?? event.data["userId"] ?? "unknown",
        //   sessionId: event.data["chatId"] ?? "unknown",
        //   eventType: "SESSION_END_NOTIFICATION_INITIAL",
        //   message: "Chat Ended notification found in initial message (App was terminated)",
        //   appState: "terminated",
        //   isConnected: false,
        // );
      }
    });

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: false, // Disable system-level notification in foreground
      badge: true,
      sound: true,
    );

    // ON TAP FROM BACKGROUND TO FOREGROUND
    // FirebaseMessaging.onMessageOpenedApp.listen((event) async {
    //
    //   print("🔥 onMessageOpenedApp Fired");
    //   print("🔥 Data = ${event.data}");
    //   String? title = event.notification?.title ?? event.data['title'];
    //
    //   print("🔥 Title = $title");
    //   // ChatLoggerRepo().logEvent(
    //   //   userId: PrefService().getRegId() ?? "unknown",
    //   //   vendorId: event.data["vendorId"] ?? event.data["userId"] ?? "unknown",
    //   //   sessionId: event.data["chatId"] ?? "unknown",
    //   //   eventType: "NOTIFICATION_TAP",
    //   //   message: "User tapped notification from background (Title: $title)",
    //   //   appState: "background",
    //   //   isConnected: false,
    //   // );
    //
    //   if (title == "Chat") {
    //     await PrefService.setBool('chat_ringing', false);
    //     ChatRingTone().stopRingtone();
    //     dismissNotifications();
    //     if (navigationKey.currentContext != null) {
    //       navigationKey.currentContext!.read<NotificationBloc>().add(
    //         NotificationIncreaseEvent(mData: event.data),
    //       );
    //     }
    //   }
    // });
    FirebaseMessaging.onMessageOpenedApp.listen((event) async {
      if (kDebugMode) {
        print("🔥 onMessageOpenedApp Fired");
      }
      if (kDebugMode) {
        print("Data = ${event.data}");
      }

      String? title =
          event.notification?.title ?? event.data['title'];

      if (kDebugMode) {
        print("Title = $title");
      }

      if (title == "Chat") {
        try {
          await PrefService.setBool('chat_ringing', false);
          ChatRingTone().stopRingtone();
          await dismissNotifications();

          if (kDebugMode) {
            print("Before GetUserProfile");
          }

          final userProfile =
          await Repository().getUserProfile(event.data["userId"]);

          if (kDebugMode) {
            print(" After GetUserProfile");
          }

          var userDetails = userProfile.toJson();
          userDetails.addAll(event.data);

          if (kDebugMode) {
            print(
              " Navigator State = ${navigationKey.currentState}");
          }
          if (kDebugMode) {
            print(
              " Navigator Context = ${navigationKey.currentContext}");
          }

          Future.delayed(const Duration(milliseconds: 800), () {
            if (kDebugMode) {
              print(" Before Push");
            }

            navigationKey.currentState?.push(
              MaterialPageRoute(
                builder: (_) => ChatPage(
                  userDetails: userDetails,
                  chatId: event.data["chatId"],
                ),
              ),
            );

            if (kDebugMode) {
              print(" After Push");
            }
          });
        } catch (e, s) {
          if (kDebugMode) {
            print("ERROR => $e");
          }
          if (kDebugMode) {
            print(" STACK => $s");
          }
        }
      }
    });
    // FOREGROUND MESSAGES
    FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
      print("onMessage --> ${event.notification?.title}");
      print("data --> ${event.data}");

      String? title = event.notification?.title ?? event.data['title'];

      if (title == "Chat" || title == "Audio Call" ) {
        // ChatLoggerRepo().logEvent(
        //   userId: PrefService().getRegId() ?? "unknown",
        //   vendorId: event.data["vendorId"] ?? event.data["userId"] ?? "unknown",
        //   sessionId: event.data["chatId"] ?? "unknown",
        //   eventType: "NOTIFICATION_RECEIVED",
        //   message: "Notification received in foreground (Title: $title)",
        //   appState: "foreground",
        //   isConnected: false,
        // );
      }

      if (title == "Chat") {
        await _showSimpleNotification(event);
        ChatRingTone().playRingtone();
        await PrefService.setBool('chat_ringing', true);
        if (navigationKey.currentContext != null) {
          navigationKey.currentContext!.read<NotificationBloc>().add(
            NotificationIncreaseEvent(mData: event.data),
          );
        }
        return;
      }

      if (title == "Audio Call") {
        CallKitService.showIncoming(mData: event.data, callType: 0);
        return;
      }

      // if (title == "Video Call") {
      //   CallKitService.showIncoming(mData: event.data, callType: 1);
      //   return;
      // }

      if (title == "Call Declined") {
        CallKitService.endAllCalls();
        dismissNotifications();
        return;
      }

      if (title == "Chat Ended") {
        ChatRingTone().stopRingtone();
        CallKitService.endAllCalls();
        dismissNotifications();
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

        // ChatLoggerRepo().logEvent(
        //   userId: PrefService().getRegId() ?? "unknown",
        //   vendorId: event.data["vendorId"] ?? event.data["userId"] ?? "unknown",
        //   sessionId: event.data["chatId"] ?? "unknown",
        //   eventType: "SESSION_END_NOTIFICATION_RECEIVED",
        //   message: "Chat Ended notification received in foreground",
        //   appState: "foreground",
        //   isConnected: false,
        // );
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
      await PrefService.setBool('chat_ringing', false);
      ChatRingTone().stopRingtone();
      dismissNotifications();
      var data = payload["data"];
      print("wwwwwwwwww data : $data");

      // ChatLoggerRepo().logEvent(
      //   userId: PrefService().getRegId() ?? "unknown",
      //   vendorId: data["vendorId"] ?? data["userId"] ?? "unknown",
      //   sessionId: data["chatId"] ?? "unknown",
      //   eventType: "LOCAL_NOTIFICATION_TAP",
      //   message: "User tapped local notification in foreground",
      //   appState: "foreground",
      //   isConnected: false,
      // );

      Repository().getUserProfile(data["userId"]).then((value) {
        var userDetails = value.toJson();
        userDetails.addAll(data);
        navigationKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) =>
                ChatPage(userDetails: userDetails, chatId: data["chatId"]),
          ),
        );
      });
      return;
    }

    // chat ended
    if (payload['title'] == "Chat Ended") {
      CallKitService.endAllCalls();
      ChatRingTone().stopRingtone();
      dismissNotifications();
      await PrefService.setBool('chat_ringing', false);

      final String endedUserId = payload["data"]?["userId"] ?? "";
      if (navigationKey.currentState?.context != null && endedUserId.isNotEmpty) {
        navigationKey.currentState!.context.read<ChatTimerBloc>().add(
          ChatEndEvent(userId: endedUserId),
        );
        // Also reset the notification badge immediately
        navigationKey.currentState!.context.read<NotificationBloc>().add(
          NotificationResetEvent(endedUserId),
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
      await PrefService.setBool('chat_ringing', false);
      ChatRingTone().stopRingtone();
      dismissNotifications();
      var data = payload["data"];

      // ChatLoggerRepo().logEvent(
      //   userId: PrefService().getRegId() ?? "unknown",
      //   vendorId: data["vendorId"] ?? data["userId"] ?? "unknown",
      //   sessionId: data["chatId"] ?? "unknown",
      //   eventType: "LOCAL_NOTIFICATION_TAP",
      //   message: "User tapped local notification from background/terminated",
      //   appState: "background",
      //   isConnected: false,
      // );

      Repository().getUserProfile(data["userId"]).then((value) {
        var userDetails = value.toJson();
        userDetails.addAll(data);
        navigationKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) =>
                ChatPage(userDetails: userDetails, chatId: data["chatId"]),
          ),
        );
      });
      return;
    }
    if (payload['title'] == "Chat Ended") {
      ChatRingTone().stopRingtone();
      CallKitService.endAllCalls();
      dismissNotifications();
      if (navigationKey.currentState?.context != null) {
        navigationKey.currentState!.context.read<ChatTimerBloc>().add(
          ChatEndEvent(userId: payload["data"]["userId"]),
        );
      }

      // ChatLoggerRepo().logEvent(
      //   userId: PrefService().getRegId() ?? "unknown",
      //   vendorId: payload["data"]["vendorId"] ?? payload["data"]["userId"] ?? "unknown",
      //   sessionId: payload["data"]["chatId"] ?? "unknown",
      //   eventType: "SESSION_END_NOTIFICATION_TAP",
      //   message: "User tapped Chat Ended local notification (Background)",
      //   appState: "background",
      //   isConnected: false,
      // );
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
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  await PrefService.init();
  await CallKitService.initialize();
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );

  print("Background event : ${event.data}");
  print("Background title : ${event.notification?.title}");

  String? title = event.notification?.title ?? event.data['title'];

  if (title == "Chat" || title == "Audio Call" ) {
    // ChatLoggerRepo().logEvent(
    //   userId: PrefService().getRegId() ?? "unknown",
    //   vendorId: event.data["vendorId"] ?? event.data["userId"] ?? "unknown",
    //   sessionId: event.data["chatId"] ?? "unknown",
    //   eventType: "NOTIFICATION_RECEIVED_BACKGROUND",
    //   message: "Notification arrived while app is in background (Title: $title)",
    //   appState: "background",
    //   isConnected: false,
    // );
  }

  if (title == "Chat") {
    // Show notification with ringtone sound (res/raw/ringtone.mp3)
    await NotificationService._showSimpleNotification(event);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('chat_ringing', true);
    await prefs.setString('pending_ring_userId', event.data['userId'] ?? '');

    // Start looping ringtone via RingtoneService (android_intent_plus)
    // This works from background isolate and auto-stops on force-kill
    await ChatRingTone().playRingtoneForce();

    // Keep isolate alive for up to 60s, polling for stop signal
    for (int i = 0; i < 60; i++) {
      await Future.delayed(const Duration(seconds: 1));
      await prefs.reload();
      if (prefs.getBool('chat_ringing') == false) {
        break;
      }
    }

    // Timeout or stopped — ensure ringtone is off
    await ChatRingTone().stopRingtone();
    await prefs.setBool('chat_ringing', false);
    return;
  }

  if (title == "Audio Call") {
    await CallKitService.showIncoming(mData: event.data, callType: 0);
    return;
  }



  if (title == "Call Declined") {
    CallKitService.endAllCalls();
    NotificationService.dismissNotifications();
    return;
  }

  if (title == "Chat Ended") {
    ChatRingTone().stopRingtone();
    CallKitService.endAllCalls();
    NotificationService.dismissNotifications();

    // Stop the ringtone loop (Chat background isolate checks this flag)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('chat_ringing', false);

    await Repository().updateProfile({
      "isChatAvailable": true,
      "chatGroupId": "",
      "isNowAvailable": true,
    }, []);

    // Save ended userId so the badge is cleared when app resumes
    final String userId = event.data['userId'] ?? '';
    if (userId.isNotEmpty) {
      await prefs.reload();
      final endedUsers = prefs.getStringList('ended_chat_users') ?? [];
      if (!endedUsers.contains(userId)) {
        endedUsers.add(userId);
      }
      await prefs.setStringList('ended_chat_users', endedUsers);
      print("Chat Ended (background): saved userId=$userId to ended_chat_users");
    }

    return;
  }

  // Default → simple notification
  await NotificationService._showSimpleNotification(event);
}
