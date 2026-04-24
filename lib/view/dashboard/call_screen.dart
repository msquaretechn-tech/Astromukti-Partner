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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/home/home_bloc.dart';
import '../../bloc/notification/notification_bloc.dart';
import '../../resources/app_url.dart';
import '../../resources/resources.dart';
import '../widgets/appbar_profile.dart';
import '../widgets/data_not_found.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key, required this.title});
  final String title;

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  NotificationUpdateState? notifierData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeBloc>().add(
        VendorCallDetailEvent(type: widget.title.toLowerCase()),
      );
    });
  }

  Future<void> _onRefresh() async {
    context.read<HomeBloc>().add(
      VendorCallDetailEvent(type: widget.title.toLowerCase()),
    );
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("title : ${widget.title}");
    }
    return Scaffold(
      appBar: AppbarProfile(userName: "${widget.title} List"),
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

                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                          ' dd-MM-yyyy hh:mm a',
                        ).format(date);
                      } catch (_) {}
                    }
                    int minutes = int.parse(item.duration.toString());
                    Duration duration = Duration(minutes: minutes);

                    /// Icon type
                    // IconData iconData = Icons.call;
                    // if (widget.title == "Chat") {
                    //   iconData = Icons.chat;
                    // } else if (widget.title == "Video") {
                    //   iconData = Icons.video_call;
                    // }else if (widget.title == "Call") {
                    //   iconData = Icons.phone;
                    // }
                    double finalAmount = item.amount * 0.4;

                    if (kDebugMode) {
                      print("title : $finalAmount");
                      print("title : ${item.amount}");
                    }

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: Resources.colors.buttonColor.withAlpha(51),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundImage:
                                  item.userDetails?.avatar != null &&
                                      item.userDetails!.avatar!.isNotEmpty
                                  ? NetworkImage(
                                      "${AppUrl.baseUrl}/images/${item.userDetails!.avatar}",
                                    )
                                  : AssetImage(Resources.images.noImage)
                                        as ImageProvider,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "${item.userDetails?.name ?? ""} ${item.userDetails?.lastName ?? ""}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        "ID: ${item.userDetails?.uid ?? ""}",
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Date :$formattedDate",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "${widget.title == "Call" ? "Call" : "Chat"} Time : ${formatDuration(duration)}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  const SizedBox(height: 4),
                                  Text(
                                    "Fee : ₹${item.amount.toStringAsFixed(2)}/Min",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    " earning Amount : ₹${finalAmount.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    item.status == "success"
                                        ? "Completed"
                                        : "Failed",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: item.status == "success"
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Icon(iconData,
                            //     size: 20,
                            //     color: Resources.colors.buttonColor),
                          ],
                        ),
                      ),
                    );
                  },
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
