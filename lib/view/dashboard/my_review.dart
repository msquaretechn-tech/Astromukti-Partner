import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:astro_mukti/view/widgets/appbar_profile.dart';
import 'package:intl/intl.dart';

import '../../bloc/rating_bloc/rating_bloc.dart';
import '../../resources/app_url.dart';
import '../../resources/resources.dart';

class MyReview extends StatefulWidget {
  const MyReview({super.key});

  @override
  State<MyReview> createState() => _MyReviewState();
}

class _MyReviewState extends State<MyReview>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Add listener to handle tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _dispatchRatingEvent();
      }
    });

    // Initial dispatch for the default tab
    _dispatchRatingEvent();
  }

  // Function to dispatch RatingGetEvent based on the current tab
  void _dispatchRatingEvent() {
    String tabType;
    switch (_tabController.index) {
      case 0:
        tabType = "Chat";
        break;
      case 1:
        tabType = "Call";
        break;
      case 2:
        tabType = "Video";
        break;
      default:
        tabType = "Chat";
    }

    context.read<RatingBloc>().add(RatingGetEvent(tabType));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarProfile(userName: 'Customer Reviews'),
      body: BlocConsumer<RatingBloc, RatingState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is RatingLoadingState) {
            return Center(
              child: CircularProgressIndicator(
                color: Resources.colors.buttonColor,
              ),
            );
          }
          else if (state is RatingGetState) {
            final ratingData = state;
            final ratings = ratingData.ratings;

            if (ratings.isEmpty) {
              return Center(
                child: Text(
                  'No Ratings Available',
                  style: Resources.styles.kTextStyle12(Colors.black),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: ratings.length,
              itemBuilder: (context, index) {
                final rating = ratings[index];
                log(" ID : ${rating.userDetails?.uid},");
                // Formatting the date and time
                String formattedDate;
                if (rating.createdAt != null) {
                  DateTime createdAtDateTime;

                  if (rating.createdAt is DateTime) {
                    createdAtDateTime = rating.createdAt as DateTime;
                  } else if (rating.createdAt is String) {
                    try {
                      createdAtDateTime = DateTime.parse(
                        rating.createdAt.toString(),
                      );
                    } catch (e) {
                      createdAtDateTime = DateTime.now();
                    }
                  } else {
                    createdAtDateTime = DateTime.now();
                  }

                  formattedDate = DateFormat(
                    'hh:mm a dd/MM/yyyy',
                  ).format(createdAtDateTime);
                } else {
                  formattedDate = 'Unknown date';
                }
                return Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      width: .1,
                      color: Resources.colors.themeColor,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Resources.colors.themeColor.withValues(
                          alpha: 0.3,
                        ),
                        spreadRadius: 2,
                        blurRadius: 1,
                        offset: Offset(0, 1),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage:
                                    (rating.userDetails!.avatar != null &&
                                        rating.userDetails!.avatar!.isNotEmpty)
                                    ? NetworkImage(
                                        "${AppUrl.baseUrl}/images/${rating.userDetails!.avatar}",
                                      )
                                    : AssetImage(Resources.images.noImage)
                                          as ImageProvider,
                              ),
                              const SizedBox(width: 5),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${rating.userDetails!.name} ${rating.userDetails!.lastName}",
                                    style: Resources.styles.kTextStyle12B(
                                      Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        index < rating.rating!.toInt()
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Resources.colors.buttonColor,
                                        size: 15,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            "ID : ${rating.userDetails?.uid}",
                            style: Resources.styles.kTextStyle10B(Colors.black),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .01,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          rating.description ?? "No comment provided.",
                          style: Resources.styles.kTextStyle12(Colors.black),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .01,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Posted: $formattedDate",
                            style: Resources.styles.kTextStyle12B(Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Text(
                'Something went wrong!',
                style: Resources.styles.kTextStyle14B(Colors.red),
              ),
            );
          }
        },
      ),
    );
  }

  // for chat
  // Widget chatBuild() {
  //   return BlocConsumer<RatingBloc, RatingState>(
  //     listener: (context, state) {},
  //     builder: (context, state) {
  //       if (state is RatingLoadingState) {
  //         return Center(
  //           child:
  //               CircularProgressIndicator(color: Resources.colors.yellowColor),
  //         );
  //       } else if (state is RatingGetState) {
  //         final ratingData = state;
  //         final ratings = ratingData.ratings;
  //
  //         if (ratings.isEmpty) {
  //           return Center(
  //             child: Text('No Ratings Available',
  //                 style: Resources.styles.kTextStyle12(Colors.black)),
  //           );
  //         }
  //
  //         return ListView.builder(
  //           padding: const EdgeInsets.all(10),
  //           itemCount: ratings.length,
  //           itemBuilder: (context, index) {
  //             final rating = ratings[index];
  //             // Formatting the date and time
  //             String formattedDate;
  //             if (rating.createdAt != null) {
  //               DateTime createdAtDateTime;
  //
  //               if (rating.createdAt is DateTime) {
  //                 createdAtDateTime = rating.createdAt as DateTime;
  //               } else if (rating.createdAt is String) {
  //                 try {
  //                   createdAtDateTime =
  //                       DateTime.parse(rating.createdAt.toString());
  //                 } catch (e) {
  //                   createdAtDateTime = DateTime.now();
  //                 }
  //               } else {
  //                 createdAtDateTime = DateTime.now();
  //               }
  //
  //               formattedDate =
  //                   DateFormat('hh:mm a dd/MM/yyyy').format(createdAtDateTime);
  //             } else {
  //               formattedDate = 'Unknown date';
  //             }
  //             return Container(
  //               margin: const EdgeInsets.symmetric(vertical: 10),
  //               padding:
  //                   const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  //               decoration: BoxDecoration(
  //                 border: Border.all(color: Resources.colors.blackColor),
  //                 borderRadius: BorderRadius.circular(10),
  //               ),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Row(
  //                         children: [
  //                           CircleAvatar(
  //                             radius: 20,
  //                             backgroundImage: NetworkImage(
  //                                 "${AppUrl.baseUrl}/images/${rating.userDetails!.avatar ?? ""}"),
  //                           ),
  //                           const SizedBox(width: 10),
  //                           Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               Text(
  //                                 rating.userDetails!.name ?? "",
  //                                 style: Resources.styles
  //                                     .kTextStyle12B(Colors.black),
  //                               ),
  //                               const SizedBox(height: 4),
  //                               Row(
  //                                 children: List.generate(5, (index) {
  //                                   return Icon(
  //                                     index < rating.rating!.toInt()
  //                                         ? Icons.star
  //                                         : Icons.star_border,
  //                                     color: Resources.colors.yellowColor,
  //                                     size: 15,
  //                                   );
  //                                 }),
  //                               ),
  //                             ],
  //                           ),
  //                         ],
  //                       ),
  //                       Text(
  //                         "ID : ${rating.id}",
  //                         style: Resources.styles.kTextStyle12B(Colors.black),
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(height: MediaQuery.of(context).size.height * .01),
  //                   Text(
  //                     rating.description ?? "No comment provided.",
  //                     style: Resources.styles.kTextStyle12(Colors.black),
  //                   ),
  //                   SizedBox(height: MediaQuery.of(context).size.height * .01),
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.end,
  //                     children: [
  //                       Text(
  //                         "Posted: $formattedDate",
  //                         style: Resources.styles.kTextStyle12B(Colors.grey),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             );
  //           },
  //         );
  //       } else {
  //         return Center(
  //           child: Text('Something went wrong!',
  //               style: Resources.styles.kTextStyle12(Colors.red)),
  //         );
  //       }
  //     },
  //   );
  // }
}
