import 'package:flutter/material.dart';
import 'package:astro_mukti/resources/resources.dart';


class AppbarProfile extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final VoidCallback? onMenuTap;
  final VoidCallback? onSearchTap;
  final List<Widget>? actions;
  const AppbarProfile({
    super.key,
    required this.userName,
    this.onMenuTap,
    this.onSearchTap,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      iconTheme: IconThemeData(color: Colors.black),
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
            ),boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ]),
      ),
      title: Text(
        userName,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
      actions: actions,
    );
  }
}
