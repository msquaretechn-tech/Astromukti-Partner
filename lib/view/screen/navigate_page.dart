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
        child: _screens[_selectedIndex],
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
