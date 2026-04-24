// import 'package:bma/view/screen/profile_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../../main.dart';
// import '../../resources/resources.dart';
// import '../dashboard/dashboard.dart';
// import '../dashboard/my_loyality_points.dart';
// import '../widgets/permission_handler.dart';
//
// class NavigationScreen extends StatefulWidget {
//   const NavigationScreen({super.key, this.page, this.selectedIndex});
//
//   final int? page;
//   final int? selectedIndex;
//
//   @override
//   State<NavigationScreen> createState() => _NavigationScreenState();
// }
//
// class _NavigationScreenState extends State<NavigationScreen> {
//   int _selectedIndex = 0;
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   @override
//   void initState() {
//     NativeService.startService();
//     if (widget.page != null) {
//       _selectedIndex = widget.page!;
//     } else {
//       _selectedIndex = 0;
//     }
//
//     PermissionHandler.checkPermissions();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final List<Widget> widgetOptions = [
//       const Dashboard(),
//       const MyLoyality(),
//       const ProfileScreen(),
//     ];
//
//     return Scaffold(
//       body: WillPopScope(
//         onWillPop: () async {
//           if (_selectedIndex != 0) {
//             setState(() => _selectedIndex = 0);
//             return false; // don’t close
//           } else {
//             final shouldPop = await showDialog<bool>(
//               context: context,
//               builder: (context) => AlertDialog(
//                 title: const Text('Do you want to close app?'),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context, true), // allow pop
//                     child: const Text('Yes'),
//                   ),
//                   TextButton(
//                     onPressed: () => Navigator.pop(context, false), // cancel
//                     child: const Text('No'),
//                   ),
//                 ],
//               ),
//             );
//             return shouldPop ?? false;
//           }
//         },
//
//         child: Center(child: widgetOptions.elementAt(_selectedIndex)),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: Resources.colors.whiteColor,
//         items: <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(
//               Icons.home,
//               color: _selectedIndex == 0
//                   ? Resources.colors.themeColor
//                   : Resources.colors.greyColor,
//             ),
//             label: 'Home',
//           ),
//           // BottomNavigationBarItem(
//           //   icon: Icon(
//           //     Icons.wallet,
//           //     color: _selectedIndex == 1
//           //         ? Resources.colors.themeColor
//           //         : Resources.colors.greyColor,
//           //
//           //   ),
//           //
//           //   label: 'Wallet',
//           // ),
//           BottomNavigationBarItem(
//             icon: Image.asset(
//               Resources.images.homeLoyalImage,
//               color: _selectedIndex == 1
//                   ? Resources.colors.themeColor
//                   : Resources.colors.greyColor,
//               height: 20,
//               width: 20,
//             ),
//             label: 'My Payout',
//           ),
//
//           BottomNavigationBarItem(
//             icon: Icon(
//               Icons.person,
//               color: _selectedIndex == 2
//                   ? Resources.colors.themeColor
//                   : Resources.colors.greyColor,
//             ),
//             label: 'profile',
//           ),
//         ],
//         type: BottomNavigationBarType.fixed,
//         currentIndex: _selectedIndex,
//         selectedItemColor: Resources.colors.themeColor,
//         unselectedItemColor: Resources.colors.blackColor,
//         iconSize: 20,
//         unselectedLabelStyle: const TextStyle(
//           fontSize: 9,
//           fontWeight: FontWeight.bold,
//         ),
//         selectedLabelStyle: const TextStyle(
//           fontSize: 9,
//           fontWeight: FontWeight.bold,
//         ),
//         onTap: _onItemTapped,
//         elevation: 5,
//       ),
//     );
//   }
// }
