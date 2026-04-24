import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:astro_mukti/resources/resources.dart';
import 'package:astro_mukti/routes/routes_name.dart';
import 'package:astro_mukti/view/drawer.dart';

class WebNavigationLayout extends StatelessWidget {
  final Widget body;
  final String userName;
  final String profileImage;
  final VoidCallback? onLogout;

  const WebNavigationLayout({
    super.key,
    required this.body,
    required this.userName,
    required this.profileImage,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 260,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Sidebar Header / Logo
                Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Hanumanta",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Resources.colors.themeColor,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    children: [
                      _buildSidebarItem(
                        context,
                        icon: Icons.dashboard_outlined,
                        label: "Dashboard",
                        onTap: () => GoRouter.of(context).pushReplacementNamed(RoutesName.homePage),
                        isActive: true, // Need logic for active state
                      ),
                      _buildSidebarItem(
                        context,
                        icon: Icons.account_balance_outlined,
                        label: "Add Bank",
                        onTap: () => GoRouter.of(context).pushNamed(RoutesName.bankScreen),
                      ),
                      _buildSidebarItem(
                        context,
                        icon: Icons.block_outlined,
                        label: "Blocked Users",
                        onTap: () => GoRouter.of(context).pushNamed(RoutesName.blocUser),
                      ),
                      _buildSidebarItem(
                        context,
                        icon: Icons.star_outline,
                        label: "Customer Reviews",
                        onTap: () => GoRouter.of(context).pushNamed(RoutesName.review),
                      ),
                      _buildSidebarItem(
                        context,
                        icon: Icons.people_outline,
                        label: "Followers",
                        onTap: () => GoRouter.of(context).pushNamed(RoutesName.followProfile),
                      ),
                      _buildSidebarItem(
                        context,
                        icon: Icons.history_toggle_off_outlined,
                        label: "Login Hours",
                        onTap: () => GoRouter.of(context).pushNamed(RoutesName.loginRoute),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                _buildSidebarItem(
                  context,
                  icon: Icons.logout,
                  label: "Logout",
                  onTap: onLogout ?? () {},
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Bar
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.black.withOpacity(0.05),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "Welcome back, $userName",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      // Status indicators can go here
                      const SizedBox(width: 20),
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
                        child: profileImage.isEmpty ? const Icon(Icons.person) : null,
                      ),
                    ],
                  ),
                ),
                // Body
                Expanded(
                  child: Container(
                    color: const Color(0xFFF8F9FA),
                    child: body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Resources.colors.themeColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive ? Resources.colors.themeColor : (color ?? Colors.black54),
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Resources.colors.themeColor : (color ?? Colors.black87),
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
