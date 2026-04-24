import 'dart:developer';

import 'package:astro_mukti/view/dashboard/payOut_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:astro_mukti/routes/routes_name.dart';
import 'package:astro_mukti/view/blog/add_blog.dart';
import 'package:astro_mukti/view/go_live/go_live_screen.dart';

import '../../view/dashboard/dashboard.dart';
import '../main.dart';
import '../services/navigation_service.dart';
import '../view/bank/bank_page.dart';
import '../view/callRate/call_rate.dart';
import '../view/dashboard/call_screen.dart';
import '../view/dashboard/chat_page.dart';
import '../view/dashboard/chat_user_list.dart';
import '../view/dashboard/login_hours.dart';
import '../view/dashboard/my_loyality_points.dart';
import '../view/dashboard/my_performance.dart';
import '../view/dashboard/my_review.dart';
import '../view/horoscope/daily_horoscope.dart';
import '../view/horoscope/daily_horoscope_details.dart';
import '../view/horoscope/horoscope_details.dart';
import '../view/kundli/kundli.dart';
import '../view/kundli/kundli_details.dart';
import '../view/more_ver/blocked_user.dart';
import '../view/more_ver/follow.dart';
import '../view/more_ver/wallet_screen.dart';
import '../view/more_ver/withdrawa_request.dart';
import '../view/numerology/dashakoot_details.dart';
import '../view/numerology/matching.dart';
import '../view/numerology/numerology_details.dart';
import '../view/private_121_audio_call.dart';
import '../view/private_121_video_call.dart';
import '../view/screen/login_screen.dart';
import '../view/screen/navigate_page.dart';
import '../view/screen/navigator_screen.dart';
import '../view/screen/otp_screen.dart';
import '../view/screen/registration_screen.dart';
import '../view/screen/splash_screen.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    observers: <NavigatorObserver>[NavigationService.instance.routeObserver],
    routes: [
      GoRoute(
        name: RoutesName.splash,
        path: "/",
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        name: RoutesName.loginScreen,
        path: RoutesName.loginScreen,
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        name: RoutesName.otpScreen,
        path: RoutesName.otpScreen,
        builder: (BuildContext context, GoRouterState state) {
          final args = state.extra as Map;
          return OtpScreen(
            mobileNumber: args['mobileNumber'].toString(),
            otp: args['otp'].toString(),
            countryCode: args['countryCode']?.toString(),
          );
        },
      ),
      GoRoute(
        name: RoutesName.registrationScreen,
        path: RoutesName.registrationScreen,
        builder: (BuildContext context, GoRouterState state) {
          bool args = (state.extra as bool) ?? false;
          return RegistrationScreen(isUpdate: args);
        },
      ),
      GoRoute(
        name: RoutesName.homePage,
        path: RoutesName.homePage,
        builder: (BuildContext context, GoRouterState state) {
          return const Dashboard();
        },
      ),
      GoRoute(
        name: RoutesName.callDetails,
        path: RoutesName.callDetails,
        builder: (BuildContext context, GoRouterState state) {
          return const GoLiveScreen();
        },
      ),
      GoRoute(
        name: RoutesName.chatUsersScreen,
        path: RoutesName.chatUsersScreen,
        builder: (BuildContext context, GoRouterState state) {
          return const ChatUserList();
        },
      ),
      // GoRoute(
      //     name: RoutesName.callDetails,
      //     path: RoutesName.callDetails,
      //     builder: (BuildContext context, GoRouterState state) {
      //       return const GoLiveScreen();
      //     }),
      GoRoute(
        name: RoutesName.chatUserList,
        path: RoutesName.chatUserList,
        builder: (BuildContext context, GoRouterState state) {
          return const ChatUserList();
        },
      ),
      GoRoute(
        name: RoutesName.myLoyality,
        path: RoutesName.myLoyality,
        builder: (BuildContext context, GoRouterState state) {
          final title = state.extra as String;
          return MyLoyality();
        },
      ),
      GoRoute(
        name: RoutesName.loginRoute,
        path: RoutesName.loginRoute,
        builder: (BuildContext context, GoRouterState state) {
          return const LoginHours();
        },
      ),
      GoRoute(
        name: RoutesName.review,
        path: RoutesName.review,
        builder: (BuildContext context, GoRouterState state) {
          return const MyReview();
        },
      ),
      GoRoute(
        name: RoutesName.navigationScreen,
        path: RoutesName.navigationScreen,
        builder: (BuildContext context, GoRouterState state) {
          var args = state.extra as int?;
          // log('args : $args');
          return NavigationScreen(page: args ?? 0);
        },
      ),
      GoRoute(
        name: RoutesName.chatPage,
        path: RoutesName.chatPage,
        builder: (BuildContext context, GoRouterState state) {
          var data = state.extra as Map<String, dynamic>;
          return ChatPage(userDetails: data, chatId: '');
        },
      ),
      GoRoute(
        name: RoutesName.followProfile,
        path: RoutesName.followProfile,
        builder: (BuildContext context, GoRouterState state) {
          return const FollowPage();
        },
      ),
      GoRoute(
        name: RoutesName.blocUser,
        path: RoutesName.blocUser,
        builder: (BuildContext context, GoRouterState state) {
          return const BlockedUser();
        },
      ),
      GoRoute(
        name: RoutesName.walletScreen,
        path: RoutesName.walletScreen,
        builder: (BuildContext context, GoRouterState state) {
          return const WalletScreen();
        },
      ),

      GoRoute(
        name: RoutesName.addBlog,
        path: RoutesName.addBlog,
        builder: (BuildContext context, GoRouterState state) {
          return const AddBlog();
        },
      ),
      GoRoute(
        name: RoutesName.withdrawalRoute,
        path: RoutesName.withdrawalRoute,
        builder: (BuildContext context, GoRouterState state) {
          return const WithdrawRequest();
        },
      ),
      GoRoute(
        name: RoutesName.bankScreen,
        path: RoutesName.bankScreen,
        builder: (BuildContext context, GoRouterState state) {
          return const BankScreen();
        },
      ),
      GoRoute(
        name: RoutesName.numerology,
        path: RoutesName.numerology,
        builder: (BuildContext context, GoRouterState state) {
          var args = state.extra as Map<String, dynamic>;
          return NumerologyDetails(data: args);
        },
      ),
      GoRoute(
        name: RoutesName.kundliDetails,
        path: RoutesName.kundliDetails,
        builder: (BuildContext context, GoRouterState state) {
          log("state.extra: ${state.extra}");
          var args = state.extra as Map<String, dynamic>? ?? {};
          return KundliDetails(
            inputData: args["inputData"],
            birthDetails: args["birthDetails"],
          );
        },
      ),
      GoRoute(
        name: RoutesName.horoscope,
        path: RoutesName.horoscope,
        builder: (BuildContext context, GoRouterState state) {
          var args = state.extra as Map<String, dynamic>;
          return HoroscopeDetails(data: args);
        },
      ),
      GoRoute(
        name: RoutesName.dashakoot,
        path: RoutesName.dashakoot,
        builder: (BuildContext context, GoRouterState state) {
          var args = state.extra as Map<String, dynamic>;
          return DashakootDetails(data: args);
        },
      ),
      GoRoute(
        name: RoutesName.zodiacPage,
        path: RoutesName.zodiacPage,
        builder: (BuildContext context, GoRouterState state) {
          return const ZodiacSign(
            dob: '',
            dot: '',
            dop: '',
            name: '',
            gender: '',
            latitude: 0.0,
            longitude: 0.0,
          );
        },
      ),
      GoRoute(
        name: RoutesName.dailyHoroscopeRoute,
        path: RoutesName.dailyHoroscopeRoute,
        builder: (BuildContext context, GoRouterState state) {
          return const DailyHoroscope();
        },
      ),
      GoRoute(
        name: RoutesName.dailyHoroscopeDetailsRoute,
        path: RoutesName.dailyHoroscopeDetailsRoute,
        builder: (BuildContext context, GoRouterState state) {
          var args = state.extra as Map<String, dynamic>;
          return DailyHoroscopeDetails(
            inputData: args["inputData"],
            outPutData: args["outPutData"],
          );
        },
      ),
      GoRoute(
        name: RoutesName.matching,
        path: RoutesName.matching,
        builder: (BuildContext context, GoRouterState state) {
          return const Matching();
        },
      ),
      GoRoute(
        name: RoutesName.privateAudioCallRoute,
        path: RoutesName.privateAudioCallRoute,
        builder: (BuildContext context, GoRouterState state) {
          var data = state.extra as Map<String, dynamic>;
          return Private121AudioCall(mData: data);
        },
      ),
      GoRoute(
        name: RoutesName.callScreen,
        path: RoutesName.callScreen,
        builder: (BuildContext context, GoRouterState state) {
          final title = state.extra as String;
          return CallScreen(title: title);
        },
      ),

      GoRoute(
        name: RoutesName.myPerformance,
        path: RoutesName.myPerformance,
        builder: (BuildContext context, GoRouterState state) {
          return const MyPerformance();
        },
      ),
      GoRoute(
        name: RoutesName.privateVideoCallRoute,
        path: RoutesName.privateVideoCallRoute,
        builder: (BuildContext context, GoRouterState state) {
          var data = state.extra as Map<String, dynamic>;
          return Private121VideoCall(mData: data);
        },
      ),
      GoRoute(
        name: RoutesName.callRatePage,
        path: RoutesName.callRatePage,
        builder: (BuildContext context, GoRouterState state) {
          return const CallAndChatRate();
        },
      ),
      GoRoute(
        name: RoutesName.payOutRoute,
        path: RoutesName.payOutRoute,
        builder: (BuildContext context, GoRouterState state) {
          return const PayoutScreen();
        },
      ),
    ],
    navigatorKey: navigationKey,
    errorBuilder: (context, state) {
      return Text(state.error.toString());
    },
  );
}
