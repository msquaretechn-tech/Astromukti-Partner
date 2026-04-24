import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:astro_mukti/bloc/stats/stats_bloc.dart';
import 'package:astro_mukti/bloc/stats/stats_event.dart';
import 'package:astro_mukti/bloc/stats/stats_state.dart';
import 'package:astro_mukti/resources/app_url.dart';
import 'package:astro_mukti/view/widgets/appbar_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/dashboard/dashboard_bloc.dart';
import '../../bloc/home/home_bloc.dart';
import '../../bloc/notification/notification_bloc.dart';
import '../../model/get_vendor.dart';
import '../../model/stats_model.dart';
import '../../repository/repository.dart';
import '../../resources/resources.dart';
import '../../routes/routes_name.dart';
import '../../services/notification_service.dart';
import '../../utils/utils.dart';
import '../drawer.dart';
import '../widgets/audio_sound.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool _userOnline = false;
  bool _userChat = false;
  bool _userCall = false;
  bool _userVideoCall = false;

  final RingtonePlayer _ringtonePlayer = RingtonePlayer();

  @override
  void initState() {
    super.initState();
    context.read<StatsBloc>().add(StateGetEvent());
    updateProfileWithFCMToken().then((value) {
      _fetchVendorDetails().then((v) {
        if (mounted) {
          context.read<AuthBloc>().add(AuthGetVendorProfileEvent());
        }
      });
    });
  }

  NotificationUpdateState? notifierData;

  Future<void> updateProfileWithFCMToken() async {
    FirebaseMessaging.instance.getToken().then((token) async {
      if (kDebugMode) {
        print("FCM Token update : $token");
      }
      final vendorProfile = await _repository.getVendorProfile();
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String appName = packageInfo.appName;
      String packageName = packageInfo.packageName;
      String version = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;

      print('App Name: $appName');
      print('Version: $version');
      print('Build Number: $buildNumber');
      print(
        ' "where is problem":${vendorProfile?.isVideoCallAvailable ?? false}',
      );

      Repository()
          .updateProfile({"fcmToken": token, "appVersion": version}, [])
          .then((value) {
            context.read<DashboardBloc>().add(GetDashboardDataEvent());
            _fetchVendorDetails(); // Refresh local state after updating token
            log("update fcmToken successfully $value");
          });
    });
  }

  VendorProfileModel? profile;
  late final Repository _repository = Repository();

  Future<void> _fetchVendorDetails() async {
    try {
      profile = await _repository.getVendorProfile();

      if (profile != null) {
        setState(() {
          _userOnline = profile?.isOnline ?? false;
          _userChat = profile?.isChatAvailable ?? false;
          _userCall = profile?.isAudioCallAvailable ?? false;
          _userVideoCall = profile?.isVideoCallAvailable ?? false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching vendor details: $e");
      }
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> nameList = [
    {"image": Resources.images.chatImage, "title": 'ChatList'},
    {"image": Resources.images.callImage, "title": 'Call'},
    // {"image": Resources.images.videoImage, "title": 'Video'},
    {"image": Resources.images.chatImage, "title": 'Chat History'},
    // {"image": Resources.images.kundliImage, "title": 'Kundli'},
    // {"image": Resources.images.matchMakingImage, "title": 'Match Making'},
    // {"image": Resources.images.dailyHoroscopeImage, "title": 'Horoscope'},
    // {"image": Resources.images.numerologyImage, "title": 'Numerology'},
    {"image": Resources.images.homeLoyalEarning, "title": 'Earning'},
    {"image": Resources.images.myReviewImage, "title": 'Reviews'},
    {"image": Resources.images.payOut, "title": 'Payout'},
    {"image": Resources.images.callRateImage, "title": 'Rate'},
  ];

  // for navigation one screen to anther screen
  Future<void> _navigateToPage(String type) async {
    switch (type) {
      case "ChatList":
        GoRouter.of(context).pushNamed(RoutesName.chatUserList, extra: "Chat");
        break;
      case "Call":
        GoRouter.of(context).pushNamed(RoutesName.callScreen, extra: "Call");
        break;
      // case "Video":
      //   GoRouter.of(context).pushNamed(RoutesName.callScreen, extra: "Video");
      case "Chat History":
        GoRouter.of(context).pushNamed(RoutesName.callScreen, extra: "Chat");
        break;
      // case "Kundli":
      //   GoRouter.of(context).pushNamed(RoutesName.zodiacPage, extra: "Kundli");
      //   break;
      // case "Match Making":
      //   GoRouter.of(
      //     context,
      //   ).pushNamed(RoutesName.matching, extra: "Match Making");
      //   break;
      // case "Horoscope":
      //   GoRouter.of(
      //     context,
      //   ).pushNamed(RoutesName.dailyHoroscopeRoute, extra: "Horoscope");
      //   break;
      //
      // case "Numerology":
      //   GoRouter.of(
      //     context,
      //   ).pushNamed(RoutesName.numerology, extra: {"type": "Numerology"});
      //   break;
      case "Earning":
        GoRouter.of(context).pushNamed(RoutesName.myLoyality, extra: "Earning");
        break;
      case "Reviews":
        GoRouter.of(context).pushNamed(RoutesName.review, extra: "Reviews");
        break;
        case "Payout":
        GoRouter.of(context).pushNamed(RoutesName.payOutRoute, extra: "Payout");
        break;
      default:
        GoRouter.of(context).pushNamed(RoutesName.callRatePage, extra: "Rate");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const DrawerPage(),

      appBar: GradientAppBar(
        userName: profile != null
            ? "${profile!.name} ${profile!.lastName}"
            : "Loading...",
        profileImage: profile?.avatar != null && profile!.avatar!.isNotEmpty
            ? "${AppUrl.baseUrl}/images/${profile!.avatar}"
            : Resources.images.noImage,
        onMenuTap: () {
          _scaffoldKey.currentState?.openDrawer();
        },
        // onNotificationTap: () {},
      ),

      // floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () async {
      //     await Repository()
      //         .updateProfile({
      //           "isLive": true,
      //           "isOnline": true,
      //           "isNowAvailable": true,
      //           "isChatAvailable": true,
      //           "isAudioCallAvailable": true,
      //           "isVideoCallAvailable": true,
      //           "chatGroupId": null,
      //         }, [])
      //         .then((value) async {
      //           EasyLoading.show(
      //             status: 'loading...',
      //             dismissOnTap: false,
      //             maskType: EasyLoadingMaskType.clear,
      //           );
      //           var followers = Repository().getUserFollowList();
      //           VendorProfileModel? vendorData = await Repository()
      //               .getVendorProfile();
      //
      //           followers.then((value) async {
      //             List<Future> notificationTasks = [];
      //
      //             for (var element in value) {
      //               var fcmToken = element.followerDetails!.fcmToken;
      //               var isNotificationOn =
      //                   element.followerDetails!.isNotificationOn;
      //
      //               // Check if fcmToken is not null and notifications are enabled
      //               if (fcmToken != null && isNotificationOn == true) {
      //                 print("Sending notification to: $fcmToken");
      //
      //                 var task = NotificationService.sendNotification(
      //                   fcmToken,
      //                   "${vendorData!.name} ${vendorData!.lastName} Live Stream Started",
      //                   "Live Stream Started",
      //                   {
      //                     "vendorName":
      //                         "${vendorData.name} ${vendorData.lastName}",
      //                     'vendorId': vendorData.id,
      //                   },
      //                 );
      //                 notificationTasks.add(task);
      //               }
      //             }
      //
      //             // Wait for all notifications to be sent
      //             await Future.wait(notificationTasks)
      //                 .then((_) async {
      //                   print("All notifications sent successfully");
      //
      //                   EasyLoading.dismiss();
      //                   // Redirect after all notifications are sent
      //                   await GoRouter.of(context)
      //                       .pushNamed(RoutesName.callDetails, extra: "Go Live")
      //                       .then((value) {
      //                         updateProfileWithFCMToken();
      //                         EasyLoading.dismiss();
      //                       });
      //
      //                   EasyLoading.dismiss();
      //                 })
      //                 .catchError((error) {
      //                   print("Error sending notifications: $error");
      //                   EasyLoading.dismiss();
      //                 });
      //           });
      //         });
      //   },
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   label: Container(
      //     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      //     decoration: BoxDecoration(
      //       color: Colors.white,
      //       borderRadius: BorderRadius.circular(30),
      //       boxShadow: [
      //         BoxShadow(
      //           color: Resources.colors.themeColor.withValues(alpha: 0.5),
      //           spreadRadius: 1,
      //           blurRadius: 1,
      //           offset: Offset(0, 1),
      //         ),
      //       ],
      //     ),
      //     child: Row(
      //       mainAxisSize: MainAxisSize.min,
      //       children: [
      //         /// Camera Icon
      //         Icon(
      //           Icons.videocam,
      //           size: 25,
      //           color: Resources.colors.themeColor,
      //         ),
      //
      //         const SizedBox(width: 8),
      //
      //         /// Text
      //         Text(
      //           "Go Live",
      //           style: TextStyle(
      //             color: Colors.red,
      //             fontSize: 14,
      //             fontWeight: FontWeight.bold,
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchVendorDetails();
          context.read<DashboardBloc>().add(GetDashboardDataEvent());
          context.read<StatsBloc>().add(StateGetEvent());
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      width: .1,
                      color: Resources.colors.themeColor,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Resources.colors.themeColor.withValues(
                          alpha: 0.8,
                        ),
                        spreadRadius: 2,
                        blurRadius: 1,
                        offset: Offset(0, 1),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Go Online",
                            style: Resources.styles.kTextStyle14B(
                              Resources.colors.blackColor,
                            ),
                          ),
                          SizedBox(width: 5),
                          Transform.scale(
                            scale: 0.6,
                            child: CupertinoSwitch(
                              value: _userOnline,
                              onChanged: (value) {
                                setState(() {
                                  _userOnline = value;

                                  if (value) {
                                    _userChat = true;
                                    _userCall = true;
                                    _userVideoCall = true;
                                  } else {
                                    _userChat = false;
                                    _userCall = false;
                                    _userVideoCall = false;
                                  }
                                });

                                Repository()
                                    .updateProfile({
                                      "isOnline": value,
                                      "isChatAvailable": _userChat,
                                      "isAudioCallAvailable": _userCall,
                                      "isVideoCallAvailable": _userVideoCall,
                                      "isNowAvailable": value,
                                    }, [])
                                    .then((response) {
                                      context.read<AuthBloc>().add(
                                        AuthGetVendorProfileEvent(),
                                      );
                                      Utils.snackBar(
                                        "Updated to Online: $value",
                                        context,
                                      );
                                    });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Container(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Available for",
                          style: Resources.styles.kTextStyle14B(Colors.black87),
                        ),
                      ),
                      SizedBox(height: 5),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          children: [
                            Transform.scale(
                              scale: 0.6,
                              child: CupertinoSwitch(
                                value: _userCall,
                                onChanged: _userOnline
                                    ? (value) {
                                        if (!value &&
                                            !_userChat &&
                                            !_userVideoCall) {
                                          Utils.snackBar(
                                            "At least one mode (Chat, Call or Video) must be ON",
                                            context,
                                          );
                                          return;
                                        }

                                        setState(() => _userCall = value);

                                        Repository()
                                            .updateProfile({
                                              "isAudioCallAvailable": _userCall,
                                              "isChatAvailable": _userChat,
                                              "isVideoCallAvailable":
                                                  _userVideoCall,
                                              "isNowAvailable": true,
                                            }, [])
                                            .then((response) {
                                              context.read<AuthBloc>().add(
                                                AuthGetVendorProfileEvent(),
                                              );
                                              Utils.snackBar(
                                                "Call mode updated: $_userCall",
                                                context,
                                              );
                                            });
                                      }
                                    : null,
                              ),
                            ),
                            Text(
                              "Call",
                              style: Resources.styles.kTextStyle14B(
                                Resources.colors.blackColor,
                              ),
                            ),
                            Spacer(),
                            Transform.scale(
                              scale: 0.6,
                              child: CupertinoSwitch(
                                value: _userChat,
                                onChanged: _userOnline
                                    ? (value) {
                                        if (!value &&
                                            !_userCall &&
                                            !_userVideoCall) {
                                          Utils.snackBar(
                                            "At least one mode (Chat, Call or Video) must be ON",
                                            context,
                                          );
                                          return;
                                        }

                                        setState(() => _userChat = value);

                                        Repository()
                                            .updateProfile({
                                              "isChatAvailable": _userChat,
                                              "isAudioCallAvailable": _userCall,
                                              "isVideoCallAvailable":
                                                  _userVideoCall,
                                              "isNowAvailable": true,
                                            }, [])
                                            .then((response) {
                                              context.read<AuthBloc>().add(
                                                AuthGetVendorProfileEvent(),
                                              );
                                              Utils.snackBar(
                                                "Chat mode updated: $_userChat",
                                                context,
                                              );
                                            });
                                      }
                                    : null,
                              ),
                            ),
                            Text(
                              "Chat",
                              style: Resources.styles.kTextStyle14B(
                                Resources.colors.blackColor,
                              ),
                            ),

                            // Transform.scale(
                            //   scale: 0.6,
                            //   child: CupertinoSwitch(
                            //     value: _userVideoCall,
                            //     onChanged: _userOnline
                            //         ? (value) {
                            //             if (!value && !_userChat && !_userCall) {
                            //               Utils.snackBar(
                            //                 "At least one mode (Chat, Call or Video) must be ON",
                            //                 context,
                            //               );
                            //               return;
                            //             }
                            //
                            //             setState(() => _userVideoCall = value);
                            //
                            //
                            //
                            //             Repository()
                            //                 .updateProfile({
                            //                   "isVideoCallAvailable":
                            //                       _userVideoCall,
                            //                   "isAudioCallAvailable": _userCall,
                            //                   "isChatAvailable": _userChat,
                            //                   "isNowAvailable": true,
                            //                 }, [])
                            //                 .then((response) {
                            //                   context.read<AuthBloc>().add(
                            //                     AuthGetVendorProfileEvent(),
                            //                   );
                            //                   Utils.snackBar(
                            //                     "Video Call mode updated: $_userVideoCall",
                            //                     context,
                            //                   );
                            //                 });
                            //           }
                            //         : null,
                            //   ),
                            // ),
                            // Text(
                            //   "Video",
                            //   style: Resources.styles.kTextStyle14B(
                            //     Resources.colors.blackColor,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  child: GridView.builder(
                    itemCount: nameList.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 7,
                          childAspectRatio: 1 / 1.2,
                        ),
                    itemBuilder: (BuildContext context, int index) {
                      if (index == 0) {
                        return BlocConsumer<
                          NotificationBloc,
                          NotificationState
                        >(
                          listener: (context, state) {
                            if (kDebugMode) {
                              print("NotificationState : ${state.runtimeType}");
                            }
                          },
                          builder: (context, state) {
                            if (state.runtimeType == NotificationUpdateState) {
                              NotificationUpdateState data =
                                  state as NotificationUpdateState;
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Badge(
                                  backgroundColor: data.userCounters.isEmpty
                                      ? Colors.transparent
                                      : Resources.colors.blackColor,
                                  label: Text(
                                    "${data.userCounters.length}",
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 15.0),
                                    child: Column(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            _navigateToPage(
                                              nameList[index]["title"]
                                                  .toString(),
                                            );
                                          },
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                nameList[index]["image"],
                                                height: 80,
                                                width: 80,
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                nameList[index]['title'],
                                                textAlign: TextAlign.center,
                                                style: Resources.styles
                                                    .kTextStyle10B(
                                                      Resources
                                                          .colors
                                                          .blackColor,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                            return Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    _navigateToPage(
                                      nameList[index]["title"].toString(),
                                    );
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        nameList[index]["image"],
                                        height: 80,
                                        width: 80,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        nameList[index]['title'],
                                        textAlign: TextAlign.center,
                                        style: Resources.styles.kTextStyle14B(
                                          Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }
                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              _navigateToPage(
                                nameList[index]["title"].toString(),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: Image.asset(
                                    nameList[index]["image"],
                                    height: 80,
                                    width: 80,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  nameList[index]['title'],
                                  textAlign: TextAlign.center,
                                  style: Resources.styles.kTextStyle14(
                                    Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(14),
                  child: BlocConsumer<StatsBloc, StatsState>(
                    listener: (context, state) {},
                    builder: (context, state) {
                      StatsModel stats = StatsModel.empty();
                      bool isLoading = false;

                      if (state is StatsLoadingState) {
                        isLoading = true;
                      } else if (state is StatsGetState) {
                        stats = state.stats;
                      }

                      final totalAmount = stats.walletAmount;
                      return Stack(
                        children: [
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.2,
                            children: [
                              statCard(
                                title: "Call Request",
                                value: stats.callRequests.toString(),
                                //percentage: "+12%",
                                imagePath: Resources.images.callImage,
                              ),
                              statCard(
                                title: "Chat Request",
                                value: stats.chatRequests.toString(),
                                // percentage: "+8%",
                                imagePath: Resources.images.chatImage,
                              ),
                              // statCard(
                              //   title: "Video Call Request",
                              //   value: stats.videoCallRequests.toString(),
                              //   // percentage: "+5%",
                              //   imagePath: Resources.images.callImage,
                              // ),
                              statCard(
                                title: "Total Earning",
                                value: "₹${totalAmount.toStringAsFixed(2)}",
                                // percentage: "-2%",
                                imagePath: Resources.images.homeLoyalEarning,
                              ),
                            ],
                          ),

                          if (isLoading)
                            Positioned.fill(
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Resources.colors.buttonColor,
                                  strokeWidth: .5,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget statCard({
    required String value,
    // required String percentage,
    required String title,
    required String imagePath,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Resources.colors.themeColor.withOpacity(0.7),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// Top Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Image.asset(imagePath, height: 50, fit: BoxFit.contain)],
          ),

          /// Value
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 6),

          /// Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
