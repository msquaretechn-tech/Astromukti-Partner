
import 'package:flutter/material.dart';
import 'package:astro_mukti/view/widgets/appbar_profile.dart';

import '../../resources/astro_api_services.dart';
import '../../resources/resources.dart';

class DailyHoroscopeDetails extends StatefulWidget {
  final Map<String, dynamic> inputData;
  final Map<String, dynamic> outPutData;
  const DailyHoroscopeDetails(
      {super.key, required this.inputData, required this.outPutData});

  @override
  State<DailyHoroscopeDetails> createState() => _DailyHoroscopeDetailsState();
}

class _DailyHoroscopeDetailsState extends State<DailyHoroscopeDetails>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  List<Tab> tabs = <Tab>[
    const Tab(text: 'Today'),
    const Tab(text: 'Tomorrow'),
    const Tab(text: 'Previous Day'),
  ];

  var nextData;
  var previousData;
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: tabs.length, vsync: this);
    AstroApiServices().getNextHoroscope(widget.inputData).then((value) {
      setState(() {
        nextData = value;
      });
    });
    AstroApiServices().getPreviousHoroscope(widget.inputData).then((value) {
      setState(() {
        previousData = value;
      });
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar:AppbarProfile(userName: 'Daily Horoscope Details',),
        body: SafeArea(
          child: Column(
            children: [
              TabBar(
                isScrollable: true,
                indicatorColor: Resources.colors.buttonColor,
                controller: tabController,
                unselectedLabelColor: Resources.colors.blackColor,
                labelColor: Resources.colors.buttonColor,
                labelStyle: Resources.styles.kTextStyle16(Colors.black),
                unselectedLabelStyle:
                    Resources.styles.kTextStyle16B5(Colors.black),
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
                      buildDailyNakshatraPrediction(),
                      buildNextNakshatraPrediction(),
                      buildPreviousNakshatraPrediction(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Daily Nakshatra details
  Widget buildDailyNakshatraPrediction() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Birth Moon Sign",
                  style: Resources.styles.kTextStyle14B(Colors.black),
                ),
                Text(
                  "${widget.outPutData["birth_moon_sign"]}",
                  style: Resources.styles.kTextStyle12B(Colors.grey),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Birth Moon Nakshatra",
                  style: Resources.styles.kTextStyle14B(Colors.black),
                ),
                Text(
                  "${widget.outPutData["birth_moon_nakshatra"]}",
                  style: Resources.styles.kTextStyle12B(Colors.grey),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Prediction date",
                  style: Resources.styles.kTextStyle14B(Colors.black),
                ),
                Text(
                  "${widget.outPutData["prediction_date"]}",
                  style: Resources.styles.kTextStyle12B(Colors.grey),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: Resources.colors.buttonColor, width: .5),
                  borderRadius: BorderRadius.circular(0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Health :",
                    style: Resources.styles.kTextStyle14B(Colors.black),
                  ),
                  Text(
                    "${widget.outPutData["prediction"]["health"]}",
                    style: Resources.styles.kTextStyle12B(Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: Resources.colors.buttonColor, width: .5),
                  borderRadius: BorderRadius.circular(0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Emotions :",
                    style: Resources.styles.kTextStyle14B(Colors.black),
                  ),
                  Text(
                    "${widget.outPutData["prediction"]["emotions"]}",
                    style: Resources.styles.kTextStyle12B(Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: Resources.colors.buttonColor, width: .5),
                  borderRadius: BorderRadius.circular(0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Profession :",
                    style: Resources.styles.kTextStyle14B(Colors.black),
                  ),
                  Text(
                    "${widget.outPutData["prediction"]["profession"]}",
                    style: Resources.styles.kTextStyle12B(Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: Resources.colors.buttonColor, width: .5),
                  borderRadius: BorderRadius.circular(0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "luck :",
                    style: Resources.styles.kTextStyle14B(Colors.black),
                  ),
                  Text(
                    "${widget.outPutData["prediction"]["luck"]}",
                    style: Resources.styles.kTextStyle12B(Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: Resources.colors.buttonColor, width: .5),
                  borderRadius: BorderRadius.circular(0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Profession Life :",
                    style: Resources.styles.kTextStyle14B(Colors.black),
                  ),
                  Text(
                    "${widget.outPutData["prediction"]["personal_life"]}",
                    style: Resources.styles.kTextStyle12B(Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: Resources.colors.buttonColor, width: .5),
                  borderRadius: BorderRadius.circular(0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Travel :",
                    style: Resources.styles.kTextStyle14B(Colors.black),
                  ),
                  Text(
                    "${widget.outPutData["prediction"]["travel"]}",
                    style: Resources.styles.kTextStyle12B(Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Next Nakshatra details
  Widget buildNextNakshatraPrediction() {
    return nextData != null
        ? SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Birth Moon Sign",
                        style: Resources.styles.kTextStyle14B(Colors.black),
                      ),
                      Text(
                        "${nextData["birth_moon_sign"]}",
                        style: Resources.styles.kTextStyle12B(Colors.grey),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Birth Moon Nakshatra",
                        style: Resources.styles.kTextStyle14B(Colors.black),
                      ),
                      Text(
                        "${nextData["birth_moon_nakshatra"]}",
                        style: Resources.styles.kTextStyle12B(Colors.grey),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Prediction date",
                        style: Resources.styles.kTextStyle14B(Colors.black),
                      ),
                      Text(
                        "${nextData["prediction_date"]}",
                        style: Resources.styles.kTextStyle12B(Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Resources.colors.buttonColor, width: .5),
                        borderRadius: BorderRadius.circular(0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Health :",
                          style: Resources.styles.kTextStyle14B(Colors.black),
                        ),
                        Text(
                          "${nextData["prediction"]["health"]}",
                          style: Resources.styles.kTextStyle12B(Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Resources.colors.buttonColor, width: .5),
                        borderRadius: BorderRadius.circular(0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Emotions :",
                          style: Resources.styles.kTextStyle14B(Colors.black),
                        ),
                        Text(
                          "${nextData["prediction"]["emotions"]}",
                          style: Resources.styles.kTextStyle12B(Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Resources.colors.buttonColor, width: .5),
                        borderRadius: BorderRadius.circular(0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Profession :",
                          style: Resources.styles.kTextStyle14B(Colors.black),
                        ),
                        Text(
                          "${nextData["prediction"]["profession"]}",
                          style: Resources.styles.kTextStyle12B(Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Resources.colors.buttonColor, width: .5),
                        borderRadius: BorderRadius.circular(0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "luck :",
                          style: Resources.styles.kTextStyle14B(Colors.black),
                        ),
                        Text(
                          "${nextData["prediction"]["luck"]}",
                          style: Resources.styles.kTextStyle12B(Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Resources.colors.buttonColor, width: .5),
                        borderRadius: BorderRadius.circular(0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Profession Life :",
                          style: Resources.styles.kTextStyle14B(Colors.black),
                        ),
                        Text(
                          "${nextData["prediction"]["personal_life"]}",
                          style: Resources.styles.kTextStyle12B(Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Resources.colors.buttonColor, width: .5),
                        borderRadius: BorderRadius.circular(0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Travel :",
                          style: Resources.styles.kTextStyle14B(Colors.black),
                        ),
                        Text(
                          "${nextData["prediction"]["travel"]}",
                          style: Resources.styles.kTextStyle12B(Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        : Center(
            child: CircularProgressIndicator(
              color: Resources.colors.buttonColor,
            ),
          );
  }

  // previous Nakshatra details
  Widget buildPreviousNakshatraPrediction() {
    return previousData != null
        ? SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Birth Moon Sign",
                        style: Resources.styles.kTextStyle14B(Colors.black),
                      ),
                      Text(
                        "${previousData["birth_moon_sign"]}",
                        style: Resources.styles.kTextStyle12B(Colors.grey),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Birth Moon Nakshatra",
                        style: Resources.styles.kTextStyle14B(Colors.black),
                      ),
                      Text(
                        "${previousData["birth_moon_nakshatra"]}",
                        style: Resources.styles.kTextStyle12B(Colors.grey),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Prediction date",
                        style: Resources.styles.kTextStyle14B(Colors.black),
                      ),
                      Text(
                        "${previousData["prediction_date"]}",
                        style: Resources.styles.kTextStyle12B(Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Resources.colors.buttonColor, width: .5),
                        borderRadius: BorderRadius.circular(0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Health :",
                          style: Resources.styles.kTextStyle14B(Colors.black),
                        ),
                        Text(
                          "${previousData["prediction"]["health"]}",
                          style: Resources.styles.kTextStyle12B(Colors.grey),
                        ),
                      ],
                    ),
                  ), const SizedBox(
                    height: 5,
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Resources.colors.buttonColor, width: .5),
                        borderRadius: BorderRadius.circular(0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Emotions :",
                          style: Resources.styles.kTextStyle14B(Colors.black),
                        ),
                        Text(
                          "${previousData["prediction"]["emotions"]}",
                          style: Resources.styles.kTextStyle12B(Colors.grey),
                        ),
                      ],
                    ),
                  ), const SizedBox(
                    height: 5,
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Resources.colors.buttonColor, width: .5),
                        borderRadius: BorderRadius.circular(0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Profession :",
                          style: Resources.styles.kTextStyle14B(Colors.black),
                        ),
                        Text(
                          "${previousData["prediction"]["profession"]}",
                          style: Resources.styles.kTextStyle12B(Colors.grey),
                        ),
                      ],
                    ),
                  ), const SizedBox(
                    height: 5,
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Resources.colors.buttonColor, width: .5),
                        borderRadius: BorderRadius.circular(0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "luck :",
                          style: Resources.styles.kTextStyle14B(Colors.black),
                        ),
                        Text(
                          "${previousData["prediction"]["luck"]}",
                          style: Resources.styles.kTextStyle12B(Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Resources.colors.buttonColor, width: .5),
                        borderRadius: BorderRadius.circular(0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Profession Life :",
                          style: Resources.styles.kTextStyle14B(Colors.black),
                        ),
                        Text(
                          "${previousData["prediction"]["personal_life"]}",
                          style: Resources.styles.kTextStyle12B(Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Resources.colors.buttonColor, width: .5),
                        borderRadius: BorderRadius.circular(0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Travel :",
                          style: Resources.styles.kTextStyle14B(Colors.black),
                        ),
                        Text(
                          "${previousData["prediction"]["travel"]}",
                          style: Resources.styles.kTextStyle12B(Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        : Center(
            child: CircularProgressIndicator(
              color: Resources.colors.buttonColor,
            ),
          );
  }
}
