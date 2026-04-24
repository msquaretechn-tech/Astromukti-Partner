// import 'dart:developer';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
//
// import '../../bloc/auth/auth_bloc.dart';
// import '../../repository/repository.dart';
// import '../../resources/app_url.dart';
// import '../../resources/resources.dart';
// import '../drawer.dart';
//
// class WalletScreen extends StatefulWidget {
//   const WalletScreen({super.key});
//
//   @override
//   State<WalletScreen> createState() => _WalletScreenState();
// }
//
// class _WalletScreenState extends State<WalletScreen> {
//   int _selectedIndex = 0;
//   List<dynamic> wallet = [];
//   List<dynamic> gift = [];
//   double totalEarnings = 0.0;
//   double giftPrice = 0.0;
//
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     context.read<AuthBloc>().add(AuthGetVendorProfileEvent());
//     fetchTransactions("call");
//     Repository().getGift().then((value) {
//       setState(() {
//         gift = value ?? [];
//         // final List<dynamic> giftList = value["data"]; // from your API
//         giftPrice = calculateGiftEarnings(gift);
//         isLoading = false;
//       });
//     });
//   }
//
//   void fetchTransactions(String type) {
//     setState(() {
//       isLoading = true;
//     });
//
//     Repository().earningTransaction(type).then((value) {
//       setState(() {
//         wallet = value ?? [];
//         totalEarnings = calculateTotalEarnings(wallet);
//         isLoading = false;
//       });
//     }).catchError((error) {
//       setState(() {
//         isLoading = false;
//       });
//       log("Error fetching transactions: $error");
//     });
//
//     log("wallet:$wallet");
//   }
//
//   double calculateTotalEarnings(List<dynamic> wallet) {
//     return wallet.fold(
//         0.0, (sum, transaction) => sum + (transaction["amount"] ?? 0.0));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: const DrawerPage(),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         centerTitle: true,
//         title: Text(
//           "Wallet",
//           style: Resources.styles.kTextStyle16B(Resources.colors.blackColor),
//         ),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 BlocBuilder<AuthBloc, AuthState>(
//                   builder: (_, state) {
//                     if (state is AuthLoadingState) {
//                       return const Center(child: CircularProgressIndicator());
//                     }
//
//                     if (state is AuthGetVendorSuccessState) {
//                       final u = state.response;
//
//                       return Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [
//                               Colors.orangeAccent,
//                               Resources.colors.themeColor,
//                             ],
//                           ),
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: Column(
//                           children: [
//                             Row(
//                               children: [
//                                 CircleAvatar(
//                                   radius: 30,
//                                   backgroundImage: u.avatar != null
//                                       ? NetworkImage(
//                                       "${AppUrl.baseUrl}/images/${u.avatar}")
//                                       : AssetImage(Resources.images.noImage)
//                                   as ImageProvider,
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: Text(
//                                     "${u.name} ${u.lastName}",
//                                     style: Resources.styles.kTextStyle16B(
//                                       Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 12),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 const Text(
//                                   "Balance",
//                                   style: TextStyle(color: Colors.white),
//                                 ),
//                                 Text(
//                                   "₹ ${u.walletAmount.toStringAsFixed(2)}",
//                                   style: Resources.styles.kTextStyle18B(
//                                     Colors.white,
//                                   ),
//                                 ),
//                               ],
//                             )
//                           ],
//                         ),
//                       );
//                     }
//
//                     return const SizedBox();
//                   },
//                 ),
//                 BlocBuilder<AuthBloc, AuthState>(
//                   builder: (context, state) {
//                     if (state is AuthLoadingState && state.isLoading) {
//                       return Center(
//                         child: CircularProgressIndicator(
//                           color: Resources.colors.buttonColor,
//                         ),
//                       );
//                     } else if (state is AuthGetVendorSuccessState) {
//                       final userDetails = state.response;
//                       return Container(
//                         alignment: Alignment.centerLeft,
//                         padding: const EdgeInsets.symmetric(horizontal: 10),
//                         width: double.infinity,
//                         height: MediaQuery.of(context).size.height * .05,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(5),
//                           border: Border.all(color: Colors.black),
//                         ),
//                         child: Text("₹ ${userDetails.callRate}/min",
//                             style: Resources.styles
//                                 .kTextStyle14B(Resources.colors.blackColor)),
//                       );
//                     } else if (state is AuthErrorState) {
//                       return Center(
//                         child: Text("Error: ${state.error.toString()}"),
//                       );
//                     } else {
//                       return const SizedBox();
//                     }
//                   },
//                 ),
//                 SizedBox(height: MediaQuery.of(context).size.height * .02),
//                 Container(
//                   padding: const EdgeInsets.all(15),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       GestureDetector(
//                         onTap: () {
//                           fetchTransactions("call");
//                           setState(() {
//                             _selectedIndex = 0;
//                           });
//                         },
//                         child: Text(
//                           "Call",
//                           style: Resources.styles.kTextStyle14B(
//                             _selectedIndex == 0
//                                 ? Resources.colors.buttonColor
//                                 : Resources.colors.blackColor,
//                           ),
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: () {
//                           fetchTransactions("chat");
//                           setState(() {
//                             _selectedIndex = 1;
//                           });
//                         },
//                         child: Text(
//                           "Chat",
//                           style: Resources.styles.kTextStyle14B(
//                             _selectedIndex == 1
//                                 ? Resources.colors.buttonColor
//                                 : Resources.colors.blackColor,
//                           ),
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: () {
//                           fetchTransactions("video");
//                           setState(() {
//                             _selectedIndex = 2;
//                           });
//                         },
//                         child: Text(
//                           "Video",
//                           style: Resources.styles.kTextStyle14B(
//                             _selectedIndex == 2
//                                 ? Resources.colors.buttonColor
//                                 : Resources.colors.blackColor,
//                           ),
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             _selectedIndex = 3;
//                           });
//                         },
//                         child: Text(
//                           "Gift",
//                           style: Resources.styles.kTextStyle14B(
//                             _selectedIndex == 3
//                                 ? Resources.colors.buttonColor
//                                 : Resources.colors.blackColor,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 _selectedIndex == 0 ||
//                     _selectedIndex == 1 ||
//                     _selectedIndex == 2
//                     ? callBuild()
//                     : giftBuild(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   String formatToIndianStandardTime(String dateString) {
//     DateTime utcDateTime = DateTime.parse(dateString);
//
//     DateTime indianDateTime =
//     utcDateTime.add(const Duration(hours: 5, minutes: 30));
//
//     return DateFormat('dd-MM-yyyy, HH:mm').format(indianDateTime);
//   }
//
//   // Widget for call
//   Widget callBuild() {
//     return isLoading
//         ? Center(
//       child: CircularProgressIndicator(
//         color: Resources.colors.buttonColor,
//       ),
//     )
//         : wallet.isEmpty
//         ? Center(
//       child: Text(
//         "No Data Available",
//         style: Resources.styles.kTextStyle12B(Colors.black),
//       ),
//     )
//         : Container(
//       padding:
//       const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             alignment: Alignment.center,
//             height: MediaQuery.of(context).size.height * .05,
//             width: MediaQuery.of(context).size.width * .5,
//             decoration: BoxDecoration(
//                 color: Resources.colors.themeColor,
//                 borderRadius: BorderRadius.circular(10)),
//             child: Text(
//               "Total Earning : ₹ ${(totalEarnings * .4).toStringAsFixed(2)}",
//               style: Resources.styles.kTextStyle14B(Colors.white),
//             ),
//           ),
//           ListView.builder(
//               physics: const NeverScrollableScrollPhysics(),
//               shrinkWrap: true,
//               itemCount: wallet.length,
//               itemBuilder: (context, index) {
//                 final transaction = wallet[index];
//                 print('transaction $transaction');
//                 return ListTile(
//                   contentPadding: EdgeInsets.zero,
//                   leading: transaction["userDetails"]?["avatar"] !=
//                       null &&
//                       transaction["userDetails"]["avatar"]
//                           .isNotEmpty
//                       ? CircleAvatar(
//                     radius: 20,
//                     backgroundImage: NetworkImage(
//                         "${AppUrl.baseUrl}/images/${transaction["userDetails"]["avatar"]}"),
//                   )
//                       : CircleAvatar(
//                     radius: 35,
//                     backgroundImage:
//                     AssetImage(Resources.images.noImage),
//                   ),
//                   title: Text(
//                     "${transaction["userDetails"]["name"]} ${transaction["userDetails"]["lastName"]}",
//                     style:
//                     Resources.styles.kTextStyle14B(Colors.black),
//                   ),
//                   subtitle: Text(
//                     formatToIndianStandardTime(
//                         "${transaction["createdAt"]}"),
//                     style:
//                     Resources.styles.kTextStyle12B(Colors.grey),
//                   ),
//                   // trailing: Text(
//                   //   "₹ ${transaction["amount"]}",
//                   //   style:
//                   //       Resources.styles.kTextStyle14B(Colors.black),
//                   // ),
//                   trailing: Text(
//                     "₹ ${(transaction["amount"] * 0.4).toStringAsFixed(2)}",
//                     style:
//                     Resources.styles.kTextStyle14B(Colors.black),
//                   ),
//                 );
//               }),
//         ],
//       ),
//     );
//   }
//
//   // Widget for gift
//   double calculateGiftEarnings(List<dynamic> gifts) {
//     double total = 0.0;
//     for (var g in gifts) {
//       final amount = g["totalAmount"];
//       total += double.tryParse(amount.toString()) ?? 0.0;
//     }
//     return total;
//   }
//
//   Widget giftBuild() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             alignment: Alignment.center,
//             height: MediaQuery.of(context).size.height * .05,
//             width: MediaQuery.of(context).size.width * .5,
//             decoration: BoxDecoration(
//               color: Resources.colors.themeColor,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Text(
//               "Total Earning : ₹ ${(giftPrice * 0.4).toStringAsFixed(2)}",
//               style: Resources.styles.kTextStyle14B(Colors.white),
//             ),
//           ),
//           const Divider(),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   "Type of Gift",
//                   style: Resources.styles.kTextStyle14B(Colors.black),
//                 ),
//                 Text(
//                   "Type Gift",
//                   style: Resources.styles.kTextStyle14B(Colors.black),
//                 ),
//                 Text(
//                   "Total Amount",
//                   style: Resources.styles.kTextStyle14B(Colors.black),
//                 ),
//               ],
//             ),
//           ),
//           const Divider(),
//           ListView.builder(
//               physics: const NeverScrollableScrollPhysics(),
//               shrinkWrap: true,
//               itemCount: gift.length,
//               itemBuilder: (context, index) {
//                 final gifts = gift[index];
//                 return Container(
//                   padding:
//                   const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Card(
//                         color: Resources.colors.whiteColor,
//                         elevation: 5,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10)),
//                         child: Container(
//                           alignment: Alignment.center,
//                           width: MediaQuery.of(context).size.width * .14,
//                           padding: const EdgeInsets.all(5),
//                           decoration: BoxDecoration(
//                               color: Resources.colors.whiteColor,
//                               borderRadius: BorderRadius.circular(10)),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               gifts["giftDetails"]["icon"] != null &&
//                                   gifts["giftDetails"]["icon"].isNotEmpty
//                                   ? Image.network(
//                                 "${AppUrl.baseUrl}/icons/${gifts["giftDetails"]["icon"]}",
//                                 height: 20,
//                                 width: 20,
//                               )
//                                   : Image.network(
//                                 Resources.images.noImage,
//                                 height: 20,
//                                 width: 20,
//                               ),
//                               Text(
//                                 "${gifts["giftDetails"]["label"]}",
//                                 style:
//                                 Resources.styles.kTextStyle10B(Colors.grey),
//                               ),
//                               Text(
//                                 "₹ ${gifts["giftDetails"]["price"]}",
//                                 style:
//                                 Resources.styles.kTextStyle10B(Colors.grey),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       Text(
//                         "${gifts["giftDetails"]["label"]}",
//                         style: Resources.styles.kTextStyle12B(Colors.black),
//                       ),
//                       Text(
//                         "₹ ${(gifts["totalAmount"] * 0.40).toStringAsFixed(2)}/-",
//                         style: Resources.styles.kTextStyle12B(Colors.black),
//                       ),
//                     ],
//                   ),
//                 );
//               })
//         ],
//       ),
//     );
//   }
// }
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:astro_mukti/view/widgets/appbar_profile.dart';
import 'package:intl/intl.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../repository/repository.dart';
import '../../resources/app_url.dart';
import '../../resources/resources.dart';
import '../drawer.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int _selectedIndex = 0;

  List<dynamic> wallet = [];
  List<dynamic> gift = [];

  double totalEarnings = 0.0;
  double giftPrice = 0.0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    context.read<AuthBloc>().add(AuthGetVendorProfileEvent());

    fetchTransactions("call");

    /// Fetch Gift Earnings
    Repository().getGift().then((value) {
      gift = value ?? [];
      giftPrice = calculateGiftEarnings(gift);
    });
  }

  void fetchTransactions(String type) {
    setState(() => isLoading = true);

    Repository().earningTransaction(type).then((value) {
      wallet = value ?? [];
      totalEarnings = calculateTotalEarnings(wallet);
      setState(() => isLoading = false);
    }).catchError((e) {
      log("Transaction error: $e");
      setState(() => isLoading = false);
    });
  }

  double calculateTotalEarnings(List<dynamic> wallet) {
    return wallet.fold(
      0.0,
          (sum, e) => sum + (e["amount"] ?? 0.0),
    );
  }

  double calculateGiftEarnings(List<dynamic> gifts) {
    return gifts.fold(
      0.0,
          (sum, e) => sum + (double.tryParse(e["totalAmount"].toString()) ?? 0),
    );
  }

  String formatDate(String date) {
    final dt = DateTime.parse(date).add(const Duration(hours: 5, minutes: 30));
    return DateFormat('dd-MM-yyyy, HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(

      appBar: AppbarProfile(
        userName: "Wallet",

      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              /// ================= WALLET HEADER =================
              BlocBuilder<AuthBloc, AuthState>(
                builder: (_, state) {
                  if (state is AuthLoadingState) {
                    return  Center(child: CircularProgressIndicator(
                      color: Resources.colors.buttonColor,
                      strokeWidth: .5,

                    ));
                  }

                  if (state is AuthGetVendorSuccessState) {
                    final u = state.response;

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orangeAccent,
                            Resources.colors.themeColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: u.avatar != null
                                    ? NetworkImage(
                                    "${AppUrl.baseUrl}/images/${u.avatar}")
                                    : AssetImage(Resources.images.noImage)
                                as ImageProvider,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "${u.name} ${u.lastName}",
                                  style: Resources.styles.kTextStyle16B(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Balance",
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                "₹ ${u.walletAmount.toStringAsFixed(2)}",
                                style: Resources.styles.kTextStyle18B(
                                  Colors.white,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),

              const SizedBox(height: 16),

              /// ================= TABS =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildTab("Call", 0, "call"),
                  buildTab("Chat", 1, "chat"),
                  buildTab("Video", 2, "video"),
                 // buildTab("Gift", 3, ""),
                ],
              ),

              const SizedBox(height: 16),

              /// ================= CONTENT =================
              _selectedIndex == 3 ? giftBuild() : callBuild(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTab(String title, int index, String type) {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        if (type.isNotEmpty) fetchTransactions(type);
      },
      child: Text(
        title,
        style: Resources.styles.kTextStyle14B(
          _selectedIndex == index
              ? Resources.colors.themeColor
              : Colors.black,
        ),
      ),
    );
  }

  /// ================= CALL / CHAT / VIDEO =================
  Widget callBuild() {
    if (isLoading) {
      return  Center(child: CircularProgressIndicator(
        color: Resources.colors.buttonColor,
        strokeWidth: .5,


      ));
    }

    if (wallet.isEmpty) {
      return const Center(child: Text("No Data Available"));
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Resources.colors.themeColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "Total Earning : ₹ ${(totalEarnings * .4).toStringAsFixed(2)}",
            style: Resources.styles.kTextStyle14B(Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          itemCount: wallet.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (_, i) {
            final t = wallet[i];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: t["userDetails"]["avatar"] != null
                    ? NetworkImage(
                    "${AppUrl.baseUrl}/images/${t["userDetails"]["avatar"]}")
                    : AssetImage(Resources.images.noImage) as ImageProvider,
              ),
              title: Text(
                "${t["userDetails"]["name"]} ${t["userDetails"]["lastName"]}",
              ),
              subtitle: Text(formatDate(t["createdAt"])),
              trailing: Text(
                "₹ ${(t["amount"] * .4).toStringAsFixed(2)}",
              ),
            );
          },
        )
      ],
    );
  }

  /// ================= GIFT SECTION =================
  /// COMMENTED & RESPONSIVE
  Widget giftBuild() {
    if (gift.isEmpty) {
      return const Center(child: Text("No Gift Data"));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// TOTAL GIFT EARNINGS
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Resources.colors.themeColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "Total Gift Earning : ₹ ${(giftPrice * .4).toStringAsFixed(2)}",
            style: Resources.styles.kTextStyle14B(Colors.white),
          ),
        ),

        const SizedBox(height: 10),

        /// GIFT LIST
        ListView.builder(
          itemCount: gift.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (_, i) {
            final g = gift[i];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: Image.network(
                  "${AppUrl.baseUrl}/icons/${g["giftDetails"]["icon"]}",
                  height: 30,
                ),
                title: Text(g["giftDetails"]["label"]),
                subtitle:
                Text("Price: ₹ ${g["giftDetails"]["price"]}"),
                trailing: Text(
                  "₹ ${(g["totalAmount"] * .4).toStringAsFixed(2)}",
                ),
              ),
            );
          },
        )
      ],
    );
  }
}
