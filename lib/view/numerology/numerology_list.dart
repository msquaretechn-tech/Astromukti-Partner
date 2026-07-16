import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:astro_mukti/view/widgets/appbar_profile.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import '../../resources/app_url.dart';
import '../../resources/resources.dart';

class NumerologyList extends StatefulWidget {
  final Map<String, dynamic> responseData;
  const NumerologyList({super.key, required this.responseData});

  @override
  State<NumerologyList> createState() => _NumerologyListState();
}

class _NumerologyListState extends State<NumerologyList>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  List<Tab> tabs = <Tab>[
    const Tab(text: 'Numbers'),
    const Tab(text: 'Radical Number'),
    //const Tab(text: 'Favorable Time'),
  ];

  @override
  void initState() {
    tabController = TabController(length: tabs.length, vsync: this);
    super.initState();
    getNumerologyReport();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  // get Report data
  var numroReportData;
  Future<void> getNumerologyReport() async {
    String apiUrl = 'https://json.astrologyapi.com/v1/numero_report';
    Map<String, dynamic> requestBody = {
      "day": int.parse(widget.responseData["date"].split('-')[0]),
      "month": int.parse(widget.responseData["date"].split('-')[1]),
      "year": int.parse(widget.responseData["date"].split('-')[2]),
      "name": widget.responseData["name"],
    };

    Map<String, String> headers = {
      'x-astrologyapi-key': AppUrl.apiSecret,
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        numroReportData = jsonDecode(response.body);
        log('numroReportData: $numroReportData');
        setState(() {});
      } else {
        log('Error: ${response.statusCode}');
      }
    } catch (e) {
      log('Exception: $e');
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return DefaultTabController(
      length: tabs.length,
      child: SafeArea(
        child: Scaffold(
          appBar: AppbarProfile(userName: "Numerology Details"),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TabBar(
                  isScrollable: true,
                  indicatorColor: Resources.colors.buttonColor,
                  controller: tabController,
                  unselectedLabelColor: Resources.colors.blackColor,
                  labelColor: Resources.colors.buttonColor,
                  labelStyle: Resources.styles.kTextStyle16(Colors.black),
                  unselectedLabelStyle: Resources.styles.kTextStyle16B5(
                    Colors.black,
                  ),
                  tabs: tabs.map((e) {
                    return Tab(text: e.text);
                  }).toList(),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.04,
                      vertical: size.height * 0.02,
                    ),
                    child: TabBarView(
                      controller: tabController,
                      children: [
                        // completed
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    height: size.height * .1,
                                    width:
                                        size.width * .3, // Adjust width as needed
                                    decoration: BoxDecoration(
                                      color: Resources.colors.buttonColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Radical Number",
                                          style: Resources.styles.kTextStyle12B(
                                            Resources.colors.whiteColor,
                                          ),
                                        ),
        
                                        Text(
                                          "${widget.responseData["radical_number"]}",
                                          style: Resources.styles.kTextStyle16B(
                                            Resources.colors.whiteColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    height: size.height * .1,
                                    width:
                                        size.width * .3, // Adjust width as needed
                                    decoration: BoxDecoration(
                                      color: Resources.colors.buttonColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Destiny Number",
                                          style: Resources.styles.kTextStyle12B(
                                            Resources.colors.whiteColor,
                                          ),
                                        ),
                                        Text(
                                          "${widget.responseData["destiny_number"]}",
                                          style: Resources.styles.kTextStyle16B(
                                            Resources.colors.whiteColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    height: size.height * .1,
                                    width:
                                        size.width * .3, // Adjust width as needed
                                    decoration: BoxDecoration(
                                      color: Resources.colors.buttonColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Name Number",
                                          style: Resources.styles.kTextStyle12B(
                                            Resources.colors.whiteColor,
                                          ),
                                        ),
                                        Text(
                                          "${widget.responseData["name_number"]}",
                                          style: Resources.styles.kTextStyle16B(
                                            Resources.colors.whiteColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Card(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Text(
                                        "Name",
                                        style: Resources.styles.kTextStyle16(
                                          Colors.black,
                                        ),
                                      ),
                                      Text(
                                        "${widget.responseData["name"]}",
                                        style: Resources.styles.kTextStyle16B(
                                          Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Card(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Birth Date",
                                            style: Resources.styles.kTextStyle14(
                                              Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "${widget.responseData["date"]}",
                                            style: Resources.styles.kTextStyle14B(
                                              Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Card(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Destiny Number",
                                            style: Resources.styles.kTextStyle14(
                                              Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "${widget.responseData["destiny_number"]}",
                                            style: Resources.styles.kTextStyle14B(
                                              Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Card(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Evil Num",
                                            style: Resources.styles.kTextStyle14(
                                              Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "${widget.responseData["evil_num"]}",
                                            style: Resources.styles.kTextStyle14B(
                                              Resources.colors.themeColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Card(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Friendly Num",
                                            style: Resources.styles.kTextStyle14(
                                              Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "${widget.responseData["friendly_num"]}",
                                            style: Resources.styles.kTextStyle14B(
                                              Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Card(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Natural Num",
                                            style: Resources.styles.kTextStyle14(
                                              Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "${widget.responseData["neutral_num"]}",
                                            style: Resources.styles.kTextStyle14B(
                                              Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Card(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Radical Number",
                                            style: Resources.styles.kTextStyle14(
                                              Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "${widget.responseData["radical_num"]}",
                                            style: Resources.styles.kTextStyle14B(
                                              Resources.colors.blackColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Card(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Radical Ruler",
                                            style: Resources.styles.kTextStyle14(
                                              Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "${widget.responseData["radical_ruler"]}",
                                            style: Resources.styles.kTextStyle14B(
                                              Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Card(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Favorite Day",
                                            style: Resources.styles.kTextStyle14(
                                              Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "${widget.responseData["fav_day"]}",
                                            style: Resources.styles.kTextStyle14B(
                                              Resources.colors.blackColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Card(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Favorite God",
                                            style: Resources.styles.kTextStyle14(
                                              Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "${widget.responseData["fav_god"]}",
                                            style: Resources.styles.kTextStyle14B(
                                              Resources.colors.blackColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Card(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Favorite Metal",
                                            style: Resources.styles.kTextStyle14(
                                              Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "${widget.responseData["fav_metal"]}",
                                            style: Resources.styles.kTextStyle14B(
                                              Resources.colors.blackColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Card(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Favorite Sub Stone",
                                            style: Resources.styles.kTextStyle14(
                                              Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "${widget.responseData["fav_substone"]}",
                                            style: Resources.styles.kTextStyle14B(
                                              Resources.colors.blackColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Card(
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Name Number",
                                              style: Resources.styles
                                                  .kTextStyle14(Colors.black),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              "${widget.responseData["name_number"]} ",
                                              style: Resources.styles
                                                  .kTextStyle14B(
                                                    Resources.colors.blackColor,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Card(
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Favorite Color",
                                              style: Resources.styles
                                                  .kTextStyle14(Colors.black),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              "${widget.responseData["fav_color"]} ",
                                              style: Resources.styles
                                                  .kTextStyle14B(
                                                    Resources.colors.blackColor,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Card(
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Favorite Stone",
                                              style: Resources.styles
                                                  .kTextStyle14(Colors.black),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              "${widget.responseData["fav_stone"]} ",
                                              style: Resources.styles
                                                  .kTextStyle14B(
                                                    Resources.colors.blackColor,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Card(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Favourable ",
                                            style: Resources.styles.kTextStyle14(
                                              Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "${widget.responseData["fav_mantra"]}",
                                            style: Resources.styles.kTextStyle14B(
                                              Resources.colors.blackColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
        
                        numroReportData != null
                            ? SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 10,
                                      ),
                                      height: size.height * .2,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(Resources.images.num),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "${widget.responseData["radical_num"]}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 40,
                                              color: Resources.colors.whiteColor,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "${numroReportData["title"]}",
                                            style: Resources.styles.kTextStyle16B(
                                              Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 10,
                                      ),
                                      child: Text(
                                        "${numroReportData["description"]}",
                                        style: Resources.styles.kTextStyle14B(
                                          Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Center(
                                child: CircularProgressIndicator(
                                  backgroundColor: Resources.colors.buttonColor,
                                ),
                              ),
        
                        // SingleChildScrollView(
                        //     child: Column(
                        //       children: [
                        //         Container(
                        //           alignment: Alignment.center,
                        //           margin: const EdgeInsets.symmetric(
                        //               horizontal: 10, vertical: 10),
                        //           height: size.height * .2,
                        //           width: double.infinity,
                        //           decoration: BoxDecoration(
                        //             image: DecorationImage(
                        //                 image: AssetImage(Resources.images.num),
                        //                 fit: BoxFit.cover),
                        //           ),
                        //           child: Column(
                        //             crossAxisAlignment: CrossAxisAlignment.center,
                        //             mainAxisAlignment: MainAxisAlignment.center,
                        //             children: [
                        //               Text(
                        //                 "7",
                        //                 style: TextStyle(
                        //                     fontWeight: FontWeight.bold,
                        //                     fontSize: 40,
                        //                     color: Resources.colors.whiteColor),
                        //               ),
                        //               const SizedBox(
                        //                 height: 5,
                        //               ),
                        //               Text(
                        //                 "what the number say",
                        //                 style: Resources.styles
                        //                     .kTextStyle16B(Colors.white),
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //         Container(
                        //           padding: const EdgeInsets.symmetric(
                        //               horizontal: 10, vertical: 10),
                        //           child: Text(
                        //             "orem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book",
                        //             style:
                        //             Resources.styles.kTextStyle14B(Colors.grey),
                        //           ),
                        //         )
                        //       ],
                        //     )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
