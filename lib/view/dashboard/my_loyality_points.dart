// import 'dart:developer';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:astro_mukti/view/widgets/appbar_profile.dart';
//
// import '../../bloc/myEarning/earning_bloc.dart';
// import '../../model/my_earning_model.dart';
// import '../../resources/resources.dart';
// import '../drawer.dart';
//
// class MyLoyality extends StatefulWidget {
//   const MyLoyality({super.key});
//
//   @override
//   State<MyLoyality> createState() => _MyLoyalityState();
// }
//
// class _MyLoyalityState extends State<MyLoyality> {
//   @override
//   void initState() {
//     super.initState();
//     context.read<EarningBloc>().add(EarningGetEvent());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: const DrawerPage(),
//       appBar: AppbarProfile(userName: 'Payout history'),
//       body: BlocConsumer<EarningBloc, EarningState>(
//         listener: (context, state) {},
//         builder: (context, state) {
//           log("Current state: $state");
//           if (state is EarningLoadingState) {
//             return Center(
//               child: CircularProgressIndicator(
//                 color: Resources.colors.buttonColor,
//               ),
//             );
//           } else if (state is EarningGetState) {
//             final earningData = state.earning;
//             if (earningData.isEmpty) {
//               return Center(
//                 child: Text(
//                   'No Earning Available',
//                   style: Resources.styles.kTextStyle12B(Colors.black),
//                 ),
//               );
//             }
//             final sortedData = [...earningData];
//             sortedData.sort((a, b) {
//               final aYear = a.id?.year ?? 0;
//               final bYear = b.id?.year ?? 0;
//               final aMonth = a.id?.month ?? 0;
//               final bMonth = b.id?.month ?? 0;
//
//               if (aYear != bYear) return bYear.compareTo(aYear);
//               return bMonth.compareTo(aMonth);
//             });
//             return ListView.builder(
//               itemCount: earningData.length,
//               itemBuilder: (BuildContext context, int index) {
//                 final model = earningData[index];
//                 final totalAmount =
//                     double.tryParse(model.totalAmount.toString()) ?? 0.0;
//                 final earningAfterRatio = totalAmount * 0.4;
//                 final tds = earningAfterRatio * 0.1;
//                 final netEarnings = earningAfterRatio - tds;
//                 String getBillingLabel(int index, MyEarningModel model) {
//                   final month = model.id?.month ?? DateTime.now().month;
//                   final year = model.id?.year ?? DateTime.now().year;
//
//                   // Get first day of the month
//                   final firstDay = DateTime(year, month, 1);
//
//                   // Get last day by moving to next month, then subtracting one day
//                   final lastDay = DateTime(year, month + 1, 0);
//
//                   // Format as DD/MM/YYYY
//                   final formatted =
//                       "${firstDay.day}/${firstDay.month}/${firstDay.year} to ${lastDay.day}/${lastDay.month}/${lastDay.year}";
//
//                   if (index == 0) {
//                     return "This month: $formatted";
//                   } else if (index == 1) {
//                     return formatted;
//                   } else {
//                     return " $formatted";
//                   }
//                 }
//
//                 return Container(
//                   height: MediaQuery.of(context).size.height * 0.25,
//                   margin: EdgeInsets.all(10),
//                   padding: EdgeInsets.symmetric(horizontal: 15),
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     border: Border.all(
//                       width: .1,
//                       color: Resources.colors.themeColor,
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Resources.colors.themeColor.withValues(
//                           alpha: 0.5,
//                         ),
//                         spreadRadius: 2,
//                         blurRadius: 1,
//                         offset: Offset(0, 1),
//                       ),
//                     ],
//                     borderRadius: BorderRadius.circular(10),
//
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         getBillingLabel(index, model),
//                         style: Resources.styles.kTextStyle14B(Colors.black),
//                       ),
//                       SizedBox(
//                         height: MediaQuery.of(context).size.height * 0.01,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             "Total Payout ",
//                             style: Resources.styles.kTextStyle14B(Colors.black),
//                           ),
//                           Text(
//                             "₹ ${earningAfterRatio.toStringAsFixed(2)}",
//                             style: Resources.styles.kTextStyle14(Colors.black),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             "TDS (10%) ",
//                             style: Resources.styles.kTextStyle14B(Colors.black),
//                           ),
//                           Text(
//                             "₹ ${tds.toStringAsFixed(2)}",
//                             style: Resources.styles.kTextStyle14(Colors.black),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             "Net Payout",
//                             style: Resources.styles.kTextStyle14B(Colors.black),
//                           ),
//                           Text(
//                             "₹ ${netEarnings.toStringAsFixed(2)}",
//                             style: Resources.styles.kTextStyle14(Colors.black),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             );
//           } else {
//             return Center(
//               child: Text(
//                 'Something went wrong!',
//                 style: Resources.styles.kTextStyle12(Colors.red),
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }
// }
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
//
// import '../../bloc/home/home_bloc.dart';
// import '../../bloc/notification/notification_bloc.dart';
// import '../../resources/app_url.dart';
// import '../../resources/resources.dart';
// import '../widgets/appbar_profile.dart';
// import '../widgets/data_not_found.dart';
//
// class CallScreen extends StatefulWidget {
//   const CallScreen({super.key, required this.title});
//   final String title;
//
//   @override
//   State<CallScreen> createState() => _CallScreenState();
// }
//
// class _CallScreenState extends State<CallScreen> {
//   @override
//   void initState() {
//     context.read<HomeBloc>().add(
//       VendorCallDetailEvent(widget.title.toLowerCase()),
//     );
//     super.initState();
//   }
//
//   NotificationUpdateState? notifierData;
//   String iconType = "call";
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppbarProfile(userName: "${widget.title} List"),
//       body: BlocConsumer<HomeBloc, HomeState>(
//         listener: (context, state) {},
//         builder: (context, state) {
//           switch (state.runtimeType) {
//             case HomeLoadingState _:
//               return Center(
//                 child: CircularProgressIndicator(
//                   color: Resources.colors.buttonColor,
//                 ),
//               );
//             case VendorCallDetailSuccessState _:
//               final vendorCallData = state as VendorCallDetailSuccessState;
//
//               return vendorCallData.callHistory.isNotEmpty
//                   ? ListView.builder(
//                       padding: const EdgeInsets.all(8.0),
//                       itemCount: vendorCallData.callHistory.length,
//                       itemBuilder: (context, index) {
//                         String currentStatus =
//                             vendorCallData.callHistory[index].status ?? "";
//                         // Formatting the date and time
//                         String formattedDate;
//
//                         if (vendorCallData.callHistory[index].createdAt !=
//                             null) {
//                           DateTime createdAtDateTime;
//
//                           if (vendorCallData.callHistory[index].createdAt
//                               is DateTime) {
//                             createdAtDateTime =
//                                 vendorCallData.callHistory[index].createdAt
//                                     as DateTime;
//                           } else if (vendorCallData
//                                   .callHistory[index]
//                                   .createdAt
//                               is String) {
//                             try {
//                               createdAtDateTime = DateTime.parse(
//                                 vendorCallData.callHistory[index].createdAt
//                                     .toString(),
//                               );
//                             } catch (e) {
//                               createdAtDateTime = DateTime.now();
//                             }
//                           } else {
//                             createdAtDateTime = DateTime.now();
//                           }
//
//                           // 👉 Convert to IST (UTC + 5:30)
//                           createdAtDateTime = createdAtDateTime.toUtc().add(
//                             const Duration(hours: 5, minutes: 30),
//                           );
//
//                           formattedDate = DateFormat(
//                             'hh:mm a dd/MM/yyyy',
//                           ).format(createdAtDateTime);
//                         } else {
//                           formattedDate = 'Unknown date';
//                         }
//
//                         IconData iconData;
//                         if (widget.title == "Chat") {
//                           iconData = Icons.chat;
//                         } else if (widget.title == "Call") {
//                           iconData = Icons.call;
//                         } else if (widget.title == "Video") {
//                           iconData = Icons.video_call;
//                         } else {
//                           iconData = Icons.call;
//                         }
//                         return BlocConsumer<
//                           NotificationBloc,
//                           NotificationState
//                         >(
//                           listener: (context, state) {
//                             if (state.runtimeType ==
//                                 NotificationUpdateState) {
//                               notifierData = state as NotificationUpdateState;
//                               log("noty $notifierData");
//                             }
//                           },
//                           builder: (context, state) {
//                             return Card(
//                               elevation: 3,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 side: BorderSide(
//                                   color: Resources.colors.buttonColor
//                                       .withOpacity(.2),
//                                   width: 1,
//                                 ),
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(10),
//                                 child: Row(
//                                   crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                   children: [
//                                     //
//                                     //Avatar
//                                     CircleAvatar(
//                                       radius: 26,
//                                       backgroundImage:
//                                           vendorCallData
//                                                       .callHistory[index]
//                                                       .userDetails
//                                                       ?.avatar !=
//                                                   null &&
//                                               vendorCallData
//                                                   .callHistory[index]
//                                                   .userDetails!
//                                                   .avatar!
//                                                   .isNotEmpty
//                                           ? NetworkImage(
//                                               "${AppUrl.baseUrl}/images/${vendorCallData.callHistory[index].userDetails!.avatar}",
//                                             )
//                                           : AssetImage(
//                                                   Resources.images.noImage,
//                                                 )
//                                                 as ImageProvider,
//                                     ),
//                                     const SizedBox(width: 10),
//                                     // Details
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           // Name & ID
//                                           Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment
//                                                     .spaceBetween,
//                                             children: [
//                                               Text(
//                                                 "${vendorCallData.callHistory[index].userDetails?.name ?? "Astrologer Name"} ${vendorCallData.callHistory[index].userDetails?.lastName ?? "Astrologer Name"}",
//                                                 style: const TextStyle(
//                                                   fontSize: 14,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                               Text(
//                                                 "ID : ${vendorCallData.callHistory[index].userDetails?.uid ?? ""}",
//                                                 style: const TextStyle(
//                                                   fontSize: 11,
//                                                   color: Colors.grey,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                           const SizedBox(height: 6),
//
//                                           Text(
//                                             formattedDate,
//                                             style: const TextStyle(
//                                               fontSize: 11,
//                                               color: Colors.grey,
//                                             ),
//                                           ),
//                                           const SizedBox(
//                                             height: 6,
//                                           ), // Duration
//                                           Text(
//                                             "Duration : ${vendorCallData.callHistory[index].duration}",
//                                             style: const TextStyle(
//                                               fontSize: 12,
//                                             ),
//                                           ),
//                                           const SizedBox(height: 4), // Charge
//                                           Text(
//                                             "Charge : ₹${vendorCallData.callHistory[index].amount.toStringAsFixed(2)}/-",
//                                             style: const TextStyle(
//                                               fontSize: 12,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         );
//                       },
//                     )
//                   : const DataNotFound();
//             default:
//               return const SizedBox();
//           }
//         },
//       ),
//     );
//   }
// }

import 'dart:developer';
import 'package:astro_mukti/view/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/home/home_bloc.dart';
import '../../bloc/notification/notification_bloc.dart';
import '../../resources/app_url.dart';
import '../../resources/resources.dart';
import '../widgets/appbar_profile.dart';
import '../widgets/data_not_found.dart';

class MyLoyality extends StatefulWidget {
  const MyLoyality({super.key});

  @override
  State<MyLoyality> createState() => _MyLoyalityState();
}

class _MyLoyalityState extends State<MyLoyality> {
  NotificationUpdateState? notifierData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeBloc>().add(VendorCallDetailEvent());
      context.read<AuthBloc>().add(AuthGetVendorProfileEvent());
    });
  }

  Future<void> _onRefresh() async {
    context.read<HomeBloc>().add(VendorCallDetailEvent());
    context.read<AuthBloc>().add(AuthGetVendorProfileEvent());
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarProfile(userName: "Astro Earning"),
      drawer: DrawerPage(),
      body: BlocListener<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationUpdateState) {
            notifierData = state;
            log("Notification Update: $notifierData");
          }
        },
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              /// 🔄 LOADING
              if (state is HomeLoadingState) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Resources.colors.buttonColor,
                  ),
                );
              }

              /// ✅ SUCCESS
              if (state is VendorCallDetailSuccessState) {
                if (state.callHistory.isEmpty) {
                  return const DataNotFound();
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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

                            return  Padding(
                              padding: EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "₹ ${u.walletAmount.toStringAsFixed(2)}",
                                    style: Resources.styles.kTextStyle18B(
                                      Colors.black,
                                    ),
                                  ),
                                  Text(
                                    "Total Earning",
                                    style: Resources.styles.kTextStyle16(
                                      Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return const SizedBox();
                        },
                      ),

                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(8),
                        itemCount: state.callHistory.length,
                        itemBuilder: (context, index) {
                          final item = state.callHistory[index];

                          /// Date formatting
                          String formattedDate = 'Unknown date';

                          if (item.createdAt != null) {
                            try {
                              DateTime date = item.createdAt is DateTime
                                  ? item.createdAt as DateTime
                                  : DateTime.parse(item.createdAt.toString());

                              date = date.toUtc().add(
                                const Duration(hours: 5, minutes: 30),
                              );

                              formattedDate = DateFormat(
                                'EEE, MMM dd yyyy',
                              ).format(date);
                            } catch (_) {}
                          }

                          int minutes = int.parse(item.duration.toString());
                          Duration duration = Duration(minutes: minutes);

                          final perCallAmount=item.amount* 0.4;



                          return Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: Resources.colors.buttonColor.withAlpha(
                                  51,
                                ),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        alignment: Alignment.topLeft,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        height: 30,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius: BorderRadius.circular(
                                            0,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.calendar_month,size: 20,),
                                            SizedBox(width: 15,),
                                            Text(
                                              formattedDate,
                                              style: Resources.styles.kTextStyle16(
                                                Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "User Name: ${item.userDetails?.name ?? ""} ${item.userDetails?.lastName ?? ""}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                        ),
                                        child: Text(
                                          "Consultation Id: ${item.userDetails?.uid ?? ""}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                        ),
                                        child: Text(
                                          "Consultation Type : ${item.type}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                        ),
                                        child: Text(
                                          "Duration : ${formatDuration(duration)}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                        ),
                                        child: Text(
                                          "Amount : ${item.amount}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                        ),
                                        child: Text(
                                          "Earning Amount : ${perCallAmount.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }

              /// ❌ ERROR / DEFAULT
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));

    return "$hours:$minutes:$seconds";
  }
}
