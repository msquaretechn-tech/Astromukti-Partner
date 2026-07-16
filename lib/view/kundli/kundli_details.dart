import 'dart:developer';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:astro_mukti/view/widgets/appbar_profile.dart';

import '../../resources/astro_api_services.dart';
import '../../resources/resources.dart';

class KundliDetails extends StatefulWidget {
  final Map<String, dynamic> inputData;
  final Map<String, dynamic> birthDetails;
  const KundliDetails({
    super.key,
    required this.inputData,
    required this.birthDetails,
  });

  @override
  State<KundliDetails> createState() => _KundliDetailsState();
}

class _KundliDetailsState extends State<KundliDetails>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  List<Tab> tabs = <Tab>[
    const Tab(text: 'Birth Details'),
    const Tab(text: 'Lagna'),
    const Tab(text: 'Moon'),
    const Tab(text: 'Sun'),
    const Tab(text: 'Navamansha '),
    const Tab(text: 'Ayanamsha'),
    const Tab(text: 'Astro Details'),
    const Tab(text: 'Planet Details'),
    const Tab(text: 'GhatChakra'),
    const Tab(text: 'Major Dasha'),
    const Tab(text: 'Current Dasha'),
  ];
  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  var lagna;
  var navamansha;
  var moon;
  var sun;
  var astroDetails;
  var planetDetails;
  var ayanamsha;
  var ghatChakra;
  List<dynamic>? mejorDasha;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: tabs.length, vsync: this);
    super.initState();
    AstroApiServices().getKundliAstroReport(widget.inputData).then((value) {
      setState(() {
        astroDetails = value;
      });
    });
    AstroApiServices().getKundliPlanetReport(widget.inputData).then((value) {
      setState(() {
        planetDetails = value;
      });
    });
    AstroApiServices().getAyanamshaPlanetReport(widget.inputData).then((value) {
      setState(() {
        ayanamsha = value;
      });
    });
    AstroApiServices().getGhatChakraPlanetReport(widget.inputData).then((
      value,
    ) {
      setState(() {
        ghatChakra = value;
      });
    });
    AstroApiServices().getLagan(widget.inputData).then((value) {
      setState(() {
        lagna = value;
      });
    });
    AstroApiServices().getMoon(widget.inputData).then((value) {
      setState(() {
        moon = value;
      });
    });
    AstroApiServices().getNavamansha(widget.inputData).then((value) {
      setState(() {
        navamansha = value;
      });
    });
    AstroApiServices().getSun(widget.inputData).then((value) {
      setState(() {
        sun = value;
      });
    });

    // for mejor dasha
    loadMajorDasha();

    // for current  dash
    loadCurrentDasha();
  }
  var currentDasha = [];

  void loadCurrentDasha() async {
    var value = await AstroApiServices().currentDasha(widget.inputData);
    setState(() {
      currentDasha = value ?? [];
    });

  }

  void loadMajorDasha() async {
    var value = await AstroApiServices().getMahaDasha(widget.inputData);
    setState(() {
      mejorDasha = value;
    });
  }
  @override
  Widget build(BuildContext context) {
    // Get the screen size for responsiveness
    final size = MediaQuery.of(context).size;

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppbarProfile(userName: 'Kundli Details'),
        body: SafeArea(
          child: Column(
            children: [
              TabBar(
                isScrollable: true,
                indicatorColor: Resources.colors.greenColor,
                controller: tabController,
                unselectedLabelColor: Resources.colors.blackColor,
                labelColor: Resources.colors.blackColor,
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
                    horizontal: size.width * 0.01,
                    vertical: size.height * 0.02,
                  ),
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      buildDetailsSection(),
                      buildLaganaSection(),
                      buildMoonSection(),
                      buildSunSection(),
                      buildNavamanshaSection(),
                      buildAyanamshaSection(),
                      buildAstroDetailsSection(),
                      buildPlanetDetailsSection(),
                      buildGhatChakraSection(),
                      buildMajorDashaSection(),
                      buildCurrentDashaSection(),
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

  //lagna widget
  Widget buildLaganaSection() {
    return lagna != null
        ? SvgCanvasWidget(
            rawSvg: lagna["svg"],
            width: MediaQuery.of(context).size.width * 9,
            height: MediaQuery.of(context).size.height * 5,
          )
        : Center(
            child: CircularProgressIndicator(
              color: Resources.colors.buttonColor,
            ),
          );
  }

  //Moon widget
  Widget buildMoonSection() {
    return moon != null
        ? SvgCanvasWidget(
            rawSvg: moon["svg"],
            width: MediaQuery.of(context).size.width * 9,
            height: MediaQuery.of(context).size.height * 5,
          )
        : Center(
            child: CircularProgressIndicator(
              color: Resources.colors.buttonColor,
            ),
          );
  }

  //Sun widget
  Widget buildSunSection() {
    return sun != null
        ? SvgCanvasWidget(
            rawSvg: sun["svg"],
            width: MediaQuery.of(context).size.width * 9,
            height: MediaQuery.of(context).size.height * 5,
          )
        : Center(
            child: CircularProgressIndicator(
              color: Resources.colors.buttonColor,
            ),
          );
  }

  //Navamansha widget
  Widget buildNavamanshaSection() {
    return navamansha != null
        ? SvgCanvasWidget(
            rawSvg: navamansha["svg"],
            width: MediaQuery.of(context).size.width * 9,
            height: MediaQuery.of(context).size.height * 5,
          )
        : Center(
            child: CircularProgressIndicator(
              color: Resources.colors.buttonColor,
            ),
          );
  }

  // birth details
  Widget buildDetailsSection() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildDetailRow("Ayanamsha : ", "${widget.birthDetails["ayanamsha"]}"),
          buildDetailRow("Sunrise : ", "${widget.birthDetails["sunrise"]}"),
          buildDetailRow("Sunset : ", "${widget.birthDetails["sunset"]}"),
        ],
      ),
    );
  }

  // ashtakoot
  Widget buildAyanamshaSection() {
    return ayanamsha != null
        ? ListView.builder(
            itemCount: ayanamsha.length,
            itemBuilder: (context, index) {
              return Container(
                color: Colors.grey.shade200,
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  onTap: () {},
                  contentPadding: const EdgeInsets.all(6.0),
                  leading: Text(
                    ayanamsha[index]["type"].toString(),
                    style: Resources.styles.kTextStyle14B(Colors.black),
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ayanamsha[index]["degree"].toString(),
                        style: Resources.styles.kTextStyle14B(Colors.black87),
                      ),
                      Text(
                        ayanamsha[index]["formatted"].toString(),
                        style: Resources.styles.kTextStyle14B(Colors.black87),
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        : Center(
            child: CircularProgressIndicator(
              color: Resources.colors.buttonColor,
            ),
          );
  }

  // Astro details
  Widget buildAstroDetailsSection() {
    return astroDetails != null
        ? SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 5,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Ascendant",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            "${astroDetails["ascendant"]}",
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Varna",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            "${astroDetails["Varna"]}",
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Vashya",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            "${astroDetails["Vashya"]}",
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Yoni",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            "${astroDetails["Yoni"]}",
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Gan",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            "${astroDetails["Gan"]}",
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Nadi",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            "${astroDetails["Nadi"]}",
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "SignLord",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            "${astroDetails["SignLord"]}",
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Sign",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            "${astroDetails["sign"]}",
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Naksahtra",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            "${astroDetails["Naksahtra"]}",
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "NaksahtraLord",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            "${astroDetails["NaksahtraLord"]}",
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Charan",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            astroDetails["Charan"].toString(),
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Yog",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            astroDetails["Yog"].toString(),
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Karan",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            astroDetails["Karan"].toString(),
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Tithi",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            "${astroDetails["Tithi"]}",
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Krishna",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            "${astroDetails["Krishna"]}",
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Yunja",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            "${astroDetails["yunja"]}",
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Tatva",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            "${astroDetails["tatva"]}",
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Name Alphabet",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            "${astroDetails["name_alphabet"]}",
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Paya",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            "${astroDetails["paya"]}",
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : Center(
            child: CircularProgressIndicator(
              backgroundColor: Resources.colors.buttonColor,
            ),
          );
  }

  // planet details
  Widget buildPlanetDetailsSection() {
    return planetDetails != null
        ? ListView.builder(
            // physics: const NeverScrollableScrollPhysics(),
            // shrinkWrap: true,
            itemCount: planetDetails.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Name",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            planetDetails[index]["name"].toString(),
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                          // Spacing between avatar and text
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Sign",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            planetDetails[index]["sign"].toString(),
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "SignLord",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            "${planetDetails[index]["signLord"]}".toString(),
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Nakshatra",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            "${planetDetails[index]["nakshatra"]}".toString(),
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "nakshatraLord",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            "${planetDetails[index]["nakshatraLord"]}"
                                .toString(),
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Nakshatra Pad",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            "${planetDetails[index]["nakshatra_pad"]}"
                                .toString(),
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "House",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            "${planetDetails[index]["house"]}".toString(),
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Planet Awastha",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            "${planetDetails[index]["planet_awastha"]}"
                                .toString(),
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        : Center(
            child: CircularProgressIndicator(
              color: Resources.colors.buttonColor,
            ),
          );
  }

  // Manglik Report
  Widget buildGhatChakraSection() {
    return ghatChakra != null
        ? SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 5,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Month",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            "${ghatChakra["month"]}",
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Tithi",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            "${ghatChakra["tithi"]}",
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Day",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            "${ghatChakra["day"]}",
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Nakshatra",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            "${ghatChakra["nakshatra"]}",
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Yog",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            "${ghatChakra["yog"]}",
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Karan",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            "${ghatChakra["karan"]}",
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Pahar",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            "${ghatChakra["pahar"]}",
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Moon",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            ghatChakra["moon"].toString(),
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : Center(
            child: CircularProgressIndicator(
              color: Resources.colors.buttonColor,
            ),
          );
  }

  // Major dasha report

  Widget buildMajorDashaSection() {
    if (mejorDasha == null) {
      return Center(child: CircularProgressIndicator());
    }

    List majorDasha = mejorDasha!;
    return mejorDasha != null
        ? ListView.builder(
          shrinkWrap: true,
          itemCount: majorDasha.length,
          itemBuilder: (context, index) {
            var dasha = majorDasha[index];

            return Container(
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 5),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Planet: ${dasha["planet"]}"),
                  Text("Planet ID: ${dasha["planet_id"]}"),
                  Text("Start: ${dasha["start"]}"),
                  Text("End: ${dasha["end"]}"),
                ],
              ),
            );
          },
        )
        : Center(
            child: CircularProgressIndicator(
              color: Resources.colors.buttonColor,
            ),
          );
  }

  // current dasha
  Widget buildCurrentDashaSection() {
    if (currentDasha == null || currentDasha.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: currentDasha.length,
      itemBuilder: (context, index) {
        var dasha = currentDasha[index];

        log("current dasha is open");

        return Container(
          margin: EdgeInsets.all(8),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 5),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Planet: ${dasha["planet"]}", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Planet ID: ${dasha["planet_id"]}"),
              Text("Start: ${dasha["start"]}"),
              Text("End: ${dasha["end"]}"),
            ],
          ),
        );
      },
    );
  }


  Widget buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
        color: Colors.grey[300],
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                title,
                style: Resources.styles.kTextStyle16B(Colors.black87),
              ),
            ),
            Expanded(
              flex: 4,
              child: Text(
                value,
                style: Resources.styles.kTextStyle14(Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SvgCanvasWidget extends StatefulWidget {
  final String rawSvg;
  final double width;
  final double height;

  const SvgCanvasWidget({
    required this.rawSvg,
    this.width = 100.0,
    this.height = 100.0,
  });

  @override
  _SvgCanvasWidgetState createState() => _SvgCanvasWidgetState();
}

class _SvgCanvasWidgetState extends State<SvgCanvasWidget> {
  ui.Image? _svgImage;

  @override
  void initState() {
    super.initState();
    _loadSvgImage();
  }

  Future<void> _loadSvgImage() async {
    final PictureInfo pictureInfo = await vg.loadPicture(
      SvgStringLoader(widget.rawSvg),
      null,
    );

    // Convert the picture to an image.
    final ui.Image image = await pictureInfo.picture.toImage(
      widget.width.toInt(),
      widget.height.toInt(),
    );

    // Clean up resources.
    pictureInfo.picture.dispose();

    // Set the loaded image to the state.
    setState(() {
      _svgImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _svgImage == null
        ? const Center(child: CircularProgressIndicator())
        : CustomPaint(
            size: Size(widget.width, widget.height),
            painter: _SvgImagePainter(_svgImage!),
          );
  }
}

class _SvgImagePainter extends CustomPainter {
  final ui.Image image;

  _SvgImagePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the image on the canvas.
    final paint = Paint();
    canvas.drawImage(image, Offset.zero, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


