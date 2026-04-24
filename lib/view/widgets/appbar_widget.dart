import 'package:flutter/material.dart';
import 'package:astro_mukti/resources/resources.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String profileImage;

  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationTap;

  const GradientAppBar({
    super.key,
    required this.userName,
    required this.profileImage,

    this.onMenuTap,
    this.onNotificationTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Resources.colors.themeColor,
              Resources.colors.themeColor,
              Resources.colors.themeColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
      ),
      title: Row(
        children: [
          // Profile + Menu
          InkWell(
            onTap: onMenuTap,
            child: const Icon(Icons.menu, size: 25, color: Colors.black),
          ),

          const SizedBox(width: 10),

          // Greeting
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const Spacer(),
          // notification
          // GestureDetector(
          //   onTap: onNotificationTap,
          //   child: Container(
          //     height: 36,
          //     width: 36,
          //     decoration: BoxDecoration(
          //       color: Colors.white,
          //       shape: BoxShape.circle,
          //       boxShadow: [
          //         BoxShadow(
          //           color: Colors.black.withOpacity(0.1),
          //           blurRadius: 6,
          //         ),
          //       ],
          //     ),
          //     child: const Icon(Icons.notification_add_outlined),
          //   ),
          // ),
        ],
      ),
    );
  }
}
