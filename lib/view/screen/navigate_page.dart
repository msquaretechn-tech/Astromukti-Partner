import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:astro_mukti/view/blog/blog_screen.dart';
import 'package:astro_mukti/view/screen/profile_screen.dart';

import '../../data/local/pref_service.dart';
import '../../main.dart';
import '../../resources/resources.dart';
import '../dashboard/dashboard.dart';
import '../dashboard/my_loyality_points.dart';
import '../widgets/permission_handler.dart';
import '../private_121_audio_call.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key, this.page});
  final int? page;
  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    Dashboard(),
    MyLoyality(),
   // MyBlog(),
    ProfileScreen(),
  ];

  @override
  initState() {
    PermissionHandler.checkPermissions();
    super.initState();
    NativeService.startService();
    HoursService.startLoginHours();
    if (widget.page != null) {
      _selectedIndex = widget.page!;
    }
  }

  // Call this method on app start
  void startLoginTracking() async {
    const MethodChannel loginServiceChannel = MethodChannel(
      "login_service_channel",
    );
    final vendorId = PrefService().getRegId() ?? "";

    try {
      final result = await loginServiceChannel.invokeMethod(
        "startLoginService",
        {"vendorId": vendorId},
      );
      log("Login service started: $result");
    } catch (e) {
      log("Failed to start login service: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF101820),
      body: WillPopScope(
        onWillPop: () async {
          // Exit App
          final exit = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text(
                  'Do you want to close app?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                    child: const Text('Yes'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: const Text('No'),
                  ),
                ],
              );
            },
          );
          return exit ?? false;
        },
        child: Stack(
          children: [
            _screens[_selectedIndex],
            Positioned(
              top: 120,
              left: 16,
              right: 16,
              child: ValueListenableBuilder<Map<String, dynamic>?>(
                valueListenable: Private121AudioCall.activeCallNotifier,
                builder: (context, activeCall, child) {
                  if (activeCall == null) return const SizedBox.shrink();
                  final callerName = activeCall["nameCaller"] ?? "User";
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Private121AudioCall(mData: activeCall),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Resources.colors.greyColor,
                            Resources.colors.whiteColor.withOpacity(0.85),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Resources.colors.whiteColor.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white24,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.call,
                              color: Colors.green,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "Ongoing Audio Call....",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  callerName,
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Return",
                              style: TextStyle(
                                color: Resources.colors.whiteColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        elevation: 5,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Resources.colors.background,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Resources.colors.blackColor,
        unselectedItemColor: Resources.colors.blackColor,
        selectedLabelStyle: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
        iconSize: 20,
        unselectedLabelStyle: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: _selectedIndex == 0
                  ? Resources.colors.blackColor
                  : Resources.colors.blackColor,
            ),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Image.asset(
              Resources.images.homeLoyalImage,
              color: _selectedIndex == 1
                  ? Resources.colors.blackColor
                  : Resources.colors.blackColor,
              height: 20,
              width: 20,
            ),
            label: "Earning",
          ),

          // BottomNavigationBarItem(
          //   icon: Image.asset(
          //     Resources.images.blogImage,
          //     color: _selectedIndex == 2
          //         ? Resources.colors.blackColor
          //         : Resources.colors.blackColor,
          //     height: 20,
          //     width: 20,
          //   ),
          //   label: "Blogs",
          // ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: _selectedIndex == 2
                  ? Resources.colors.blackColor
                  : Resources.colors.blackColor,
            ),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
