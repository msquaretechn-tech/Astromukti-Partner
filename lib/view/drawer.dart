import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:astro_mukti/view/dashboard/remedy/assign_remedy.dart';
import 'package:astro_mukti/view/screen/contact_us.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/auth/auth_bloc.dart';
import '../data/local/pref_service.dart';
import '../repository/repository.dart';
import '../resources/app_url.dart';
import '../resources/resources.dart';
import '../routes/routes_name.dart';
import 'dashboard/remedy/comment_remedy.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({Key? key}) : super(key: key);

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthGetVendorProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: Resources.dimens.width(context) * 0.57,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthGetVendorSuccessState) {
                final userDetails = state.response;
                log("userDetails $userDetails ");
                return DrawerHeader(
                  decoration: BoxDecoration(color: Resources.colors.themeColor),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          GoRouter.of(context).pushReplacementNamed(
                            RoutesName.navigationScreen,
                            extra: 2,
                          );
                        },
                        child:
                            userDetails.avatar != null &&
                                userDetails.avatar != ""
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(
                                  "${AppUrl.baseUrl}/images/${userDetails.avatar}",
                                ),
                                radius: 35,
                              )
                            : CircleAvatar(
                                backgroundImage: AssetImage(
                                  Resources.images.noImage,
                                ),
                                radius: 35,
                              ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .003,
                      ),
                      Text(
                        "${userDetails.name ?? ""} ${userDetails.lastName ?? ""}",
                        textAlign: TextAlign.start,
                        style: Resources.styles.kTextStyle12B5(Colors.black),
                      ),
                      Text(
                        userDetails.mobile ?? "",
                        textAlign: TextAlign.start,
                        style: Resources.styles.kTextStyle12B5(Colors.black),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox();
            },
          ),
          // ListTile(
          //   onTap: () {
          //     GoRouter.of(context).pushReplacementNamed(
          //       RoutesName.navigationScreen,
          //       extra: 3,
          //     );
          //   },
          //   leading: Icon(
          //     Icons.person,
          //     color: Resources.colors.buttonColor,
          //   ),
          //   title: Text(
          //     "Profile",
          //     style: Resources.styles.kTextStyle14B(Colors.black),
          //   ),
          // ),
          InkWell(
            onTap: () {
              GoRouter.of(context).pushNamed(RoutesName.bankScreen);
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance,
                    size: 20,
                    color: Resources.colors.blackColor,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Add Bank",
                    style: Resources.styles.kTextStyle14(Colors.black),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 3),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ExpertiseScreen()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                children: [
                  Icon(
                    Icons.add_circle_outline_sharp,
                    size: 20,
                    color: Resources.colors.blackColor,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Add Expertise",
                    style: Resources.styles.kTextStyle14(Colors.black),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 3),
          InkWell(
            onTap: () {
              GoRouter.of(context).pushNamed(RoutesName.followProfile);
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                children: [
                  Icon(
                    Icons.follow_the_signs,
                    size: 20,
                    color: Resources.colors.blackColor,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Followers",
                    style: Resources.styles.kTextStyle14(Colors.black),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 3),
          // ListTile(
          //   onTap: () {
          //     GoRouter.of(context).pushNamed(RoutesName.walletScreen);
          //   },
          //   leading: Icon(Icons.wallet, color: Resources.colors.buttonColor),
          //   title: Text(
          //     "Wallet",
          //     style: Resources.styles.kTextStyle14B(Colors.black),
          //   ),
          // ),
          InkWell(
            onTap: () {
              GoRouter.of(context).pushNamed(RoutesName.review);
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                children: [
                  Image.asset(
                    Resources.images.myReviewImage,

                    height: 20,
                    width: 20,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Customer Review",
                    style: Resources.styles.kTextStyle14(Colors.black),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 3),
          InkWell(
            onTap: () {
              GoRouter.of(context).pushNamed(RoutesName.loginRoute);
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    color: Resources.colors.blackColor,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Login Hours",
                    style: Resources.styles.kTextStyle14(Colors.black),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 3),
          InkWell(
            onTap: () async {
              final Uri url = Uri.parse(
                'https://www.astromukti.com/privacy-policy',
              );
              await launchUrl(url);
              await launchUrl(url);
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                children: [
                  Icon(
                    Icons.privacy_tip_rounded,
                    color: Resources.colors.blackColor,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Privacy Policy",
                    style: Resources.styles.kTextStyle14(Colors.black),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 3),
          InkWell(
            onTap: () async {
              final Uri url = Uri.parse(
                'https://www.astromukti.com/terms-conditions',
              );
              await launchUrl(url);
              await launchUrl(url);
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                children: [
                  Icon(
                    Icons.privacy_tip_rounded,
                    color: Resources.colors.blackColor,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Terms & Conditions",
                    style: Resources.styles.kTextStyle14(Colors.black),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 3),
          InkWell(
            onTap: () async {
              final Uri url = Uri.parse('https://www.astromukti.com/about-us');
              await launchUrl(url);
              await launchUrl(url);
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                children: [
                  Icon(
                    Icons.privacy_tip_outlined,
                    color: Resources.colors.blackColor,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "About",
                    style: Resources.styles.kTextStyle14(Colors.black),
                  ),
                ],
              ),
            ),
          ),

          // ListTile(
          //   contentPadding: const EdgeInsets.symmetric(
          //     horizontal: 10,
          //     vertical: 0,
          //   ),
          //   onTap: () {
          //     GoRouter.of(context).pushNamed(RoutesName.blocUser);
          //   },
          //   leading: Icon(
          //     Icons.block_rounded,
          //     color: Resources.colors.blackColor,
          //   ),
          //   title: Text(
          //     "Blocked Users",
          //     style: Resources.styles.kTextStyle14B(Colors.black),
          //   ),
          // ),
          SizedBox(height: 3),
          InkWell(
            onTap: () async {
              Repository()
                  .updateProfile({
                    "isOnline": false,
                    "isNowAvailable": false,
                    "isAudioCallAvailable": false,
                    "isChatAvailable": false,
                    "isVideoCallAvailable": false,
                  }, [])
                  .then((value) {
                    log("value:$value");
                    PrefService.clear().then((value) {
                      Navigator.popUntil(context, (route) => route.isFirst);
                      GoRouter.of(
                        context,
                      ).pushReplacementNamed(RoutesName.loginScreen);
                    });
                  });
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                children: [
                  Icon(Icons.logout, color: Resources.colors.blackColor),
                  SizedBox(width: 10),
                  Text(
                    "logout",
                    style: Resources.styles.kTextStyle14(Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
