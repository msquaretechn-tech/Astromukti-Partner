import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:astro_mukti/bloc/stats/stats_bloc.dart';
import 'package:astro_mukti/repository/repository.dart';
import 'package:astro_mukti/routes/routes.dart';
import 'package:astro_mukti/services/call_kit_incoming.dart';
import 'package:astro_mukti/services/notification_service.dart';
import 'package:astro_mukti/utils/image_picker_state.dart';
import 'package:astro_mukti/utils/utils.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'bloc/auth/auth_bloc.dart';
import 'bloc/banner_bloc.dart';
import 'bloc/blocked/user_bloc.dart';
import 'bloc/booking_bloc/booking_bloc.dart';
import 'bloc/call_timer/call_timer_bloc.dart';
import 'bloc/chat/chat_bloc.dart';
import 'bloc/chat_timer/chat_timer_bloc.dart';
import 'bloc/count_down_timer.dart';
import 'bloc/dashboard/dashboard_bloc.dart';
import 'bloc/follow/follow_block.dart';
import 'bloc/home/home_bloc.dart';
import 'bloc/myEarning/earning_bloc.dart';
import 'bloc/notification/notification_bloc.dart';
import 'bloc/payOut/payOut_bloc.dart';
import 'bloc/rating_bloc/rating_bloc.dart';
import 'bloc/remaining_rimer_bloc/bloc.dart';
import 'bloc/report/report_block.dart';
import 'bloc/waitlist_bloc.dart';

import 'data/local/pref_service.dart';
import 'firebase_options.dart';
import 'model/get_vendor.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
Future<void> sendNotificationLive() async {
  var followers = Repository().getUserFollowList();

  print("followers : $followers");
  VendorProfileModel? vendorData = await Repository().getVendorProfile();

  followers
      .then((value) async {
        List<Future> notificationTasks = [];

        for (var element in value) {
          var fcmToken = element.followerDetails!.fcmToken;
          var isNotificationOn = element.followerDetails!.isNotificationOn;

          // Check if fcmToken is not null and notifications are enabled
          if (fcmToken != null && isNotificationOn == true) {
            print("Sending notification to: $fcmToken");

            var task = NotificationService.sendNotification(
              fcmToken,
              "${vendorData!.name} ${vendorData.lastName} is online",
              "Now you can call/chat! ",
              {
                "vendorName": "${vendorData.name} ${vendorData.lastName}",
                "vendorId": vendorData.id,
              },
            );
            notificationTasks.add(task);
          }
        }

        // Wait for all notifications to be sent
        await Future.wait(notificationTasks)
            .then((_) async {
              print("All notifications sent successfully");
            })
            .catchError((error) {
              print("Error sending notifications: $error");
            });
      })
      .catchError((e) {
        print("eeeee $e");
      });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase first
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Enable Firebase Crashlytics in debug mode

    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      !kDebugMode,
    );

    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
    // Consider showing an error UI or retry mechanism
  }
  await PrefService.init();
  //setupNativeLoginListener();
  // Initialize CallKit early
  await CallKitService.initialize();
  // CallKitService.listen();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  WakelockPlus.enable();
  //Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );
  // IN APP UPDATE
  Utils().checkForUpdates();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NotificationBloc()),
        BlocProvider(create: (_) => AuthBloc(ImagePickerUtils())),
        BlocProvider(create: (_) => DashboardBloc()),
        BlocProvider(create: (_) => HomeBloc()),
        BlocProvider(create: (_) => ChatBloc()),
        BlocProvider(create: (_) => CallTimerBloc()),
        BlocProvider(create: (_) => NotificationBloc()),
        BlocProvider(create: (_) => BannerBloc()),
        BlocProvider(create: (_) => WaitlistBloc()),
        BlocProvider(create: (_) => RatingBloc()),
        BlocProvider(create: (_) => FollowBloc()),
        BlocProvider(create: (_) => BlockedBloc()),
        BlocProvider(create: (_) => BookingBloc()),
        BlocProvider(create: (_) => ReportBloc()),
        BlocProvider(create: (_) => ChatTimerBloc()),
        BlocProvider(create: (_) => CountDownTimerBloc()),
        BlocProvider(create: (_) => EarningBloc()),
        BlocProvider(create: (_) => ChatsTimerBloc()),
        BlocProvider(create: (_) => StatsBloc()),
        BlocProvider(create: (_) => PayoutBloc()),
      ],
      child: MyApp(),
    ),
  );
}

final GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();

FirebaseAnalytics analytics = FirebaseAnalytics.instance;
FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(
  analytics: analytics,
);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

StreamSubscription? chatTimerSub;

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  DateTime? _startTime;
  DateTime? _endTime;
  Duration _totalTime = Duration.zero;
  @override
  void initState() {
    super.initState();
    PrefService prefService = PrefService();
    var regId = prefService.getRegId();
    var token = prefService.getToken();
    NotificationService.init(context);

    if (regId != "" && token != "" && regId != null && token != null) {
      sendNotificationLive();
    }

    _startTime = DateTime.now();
    WidgetsBinding.instance.addObserver(this);

    _initProfile();
    // chatTimerSub = context.read<ChatTimerBloc>().stream.listen((state) {
    //   if (state is ChatEndState) {
    //     // Do something here
    //     print("ChatEndState: ${state.time}");
    //
    //     Repository().updateProfile({"isChatAvailable": false}, []);
    //     context.read<ChatTimerBloc>().add(ChatResetEvent());
    //     context.read<NotificationBloc>().add(
    //       NotificationResetEvent(state.userId),
    //     );
    //   }
    // });
    chatTimerSub = context.read<ChatTimerBloc>().stream.listen((state) async {
      if (state is ChatEndState) {
        print("ChatEndState: ${state.time}");

        try {
          final vendorProfile = await Repository().getVendorProfile();

          if (vendorProfile != null) {
            await Repository().updateProfile({
              "isChatAvailable": vendorProfile.isChatAvailable,
            }, []);
            log("Profile updated after chat end ✅");
          }
        } catch (e) {
          log("Error fetching vendor profile after chat end: $e");
        }

        context.read<ChatTimerBloc>().add(ChatResetEvent());
        context.read<NotificationBloc>().add(
          NotificationResetEvent(state.userId),
        );
      }
    });
  }

  /// Async method to fetch vendor profile and update
  Future<void> _initProfile() async {
    try {
      final vendorProfile = await Repository().getVendorProfile();

      if (vendorProfile != null) {
        await Repository().updateProfile({
          "isOnline": vendorProfile.isOnline,
          "isChatAvailable": vendorProfile.isChatAvailable,
          "isAudioCallAvailable": vendorProfile.isAudioCallAvailable,
          "isVideoCallAvailable": vendorProfile.isVideoCallAvailable,
        }, []);
        log("Profile updated from vendor profile values ✅");
      } else {
        log("Vendor profile is null, skipping update");
      }
    } catch (e) {
      log("Error in _initProfile: $e");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    chatTimerSub?.cancel();
    super.dispose();
  }

  void syncChatMapToBloc(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('chatMap');
    if (raw == null || raw == '{}') {
      log("syncChatMapToBloc: chatMap is empty or null");
      return;
    }

    final Map<String, dynamic> map = Map<String, dynamic>.from(jsonDecode(raw));
    log("why is empty: syncing map $map");

    // Dispatch each user's count to NotificationBloc
    map.forEach((userId, count) {
      for (int i = 0; i < count; i++) {
        context.read<NotificationBloc>().add(
          NotificationIncreaseEvent(mData: {'userId': userId}),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Astro Mukti - Astrologer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'UbuntuSans',
      ),
      routeInformationParser: AppRoutes.router.routeInformationParser,
      routerDelegate: AppRoutes.router.routerDelegate,
      routeInformationProvider: AppRoutes.router.routeInformationProvider,
      debugShowCheckedModeBanner: false,
      builder: EasyLoading.init(),
    );
  }
}

// class for starting service
class NativeService {
  static const platform = MethodChannel('com.astro.hanumanta/service');

  static Future<void> startService() async {
    try {
      final prefService = PrefService();
      var id = prefService.getRegId();
      var token = PrefService().getToken();

      await platform.invokeMethod('startService', {
        "url":
            "https://bookmyastro.bookmyastro.co.in/api/vendor/update-availability/$id",
        "token": token,
      });
    } catch (e) {
      print("Error starting service: $e");
    }
  }
}

class HoursService {
  static const platform = MethodChannel('login_service_channel');

  static Future<void> startLoginHours() async {
    try {
      final vendorId = PrefService().getRegId();
      final token = PrefService().getToken();
      await platform.invokeMethod('startLoginService', {
        "vendorId": vendorId,
        "token": token,
      });
      print("✅ LoginHoursService started");
    } catch (e) {
      print("❌ Failed to start LoginHoursService: $e");
    }
  }
}
