import 'dart:developer';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:astro_mukti/view/widgets/appbar_profile.dart';

import '../../resources/astro_api_services.dart';
import '../../resources/resources.dart';
import '../../routes/routes_name.dart';

class ZodiacDetails extends StatefulWidget {
  final Map<String, dynamic> data;
  const ZodiacDetails({Key? key, required this.data}) : super(key: key);

  @override
  State<ZodiacDetails> createState() => _ZodiacDetailsState();
}

class _ZodiacDetailsState extends State<ZodiacDetails>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  List<Tab> tabs = <Tab>[
    //const Tab(text: 'Lagna'),
    const Tab(text: 'Birth Details'),
    const Tab(text: 'Ashtakoot Points'),
    const Tab(text: 'Match Obstructions'),
    const Tab(text: 'Astro Details'),
    const Tab(text: 'Planet Details'),
    const Tab(text: 'Manglik Report'),
    const Tab(text: 'Dashakoot Points'),
  ];

  var ashData;
  var astroData;
  var planetAstroData;
  var manglikData;
  var dashakoot;
  var matchObstruction;
  var lagna;
  @override
  void initState() {
    tabController = TabController(length: tabs.length, vsync: this);
    super.initState();

    AstroApiServices().getAshtkootReport({
      "m_day": widget.data["male_astro_details"]["day"],
      "m_month": widget.data["male_astro_details"]["month"],
      "m_year": widget.data["male_astro_details"]["year"],
      "m_hour": widget.data["male_astro_details"]["hour"],
      "m_min": widget.data["male_astro_details"]["minute"],
      "m_lat": widget.data["male_astro_details"]["latitude"],
      "m_lon": widget.data["male_astro_details"]["longitude"],
      "m_tzone": 5.5,
      "f_day": widget.data["female_astro_details"]["day"],
      "f_month": widget.data["female_astro_details"]["month"],
      "f_year": widget.data["female_astro_details"]["year"],
      "f_hour": widget.data["female_astro_details"]["hour"],
      "f_min": widget.data["female_astro_details"]["minute"],
      "f_lat": widget.data["female_astro_details"]["latitude"],
      "f_lon": widget.data["female_astro_details"]["longitude"],
      "f_tzone": 5.5
    }).then((value) {
      setState(() {
        ashData = value;
      });
    });
    AstroApiServices().getAstroDetails({
      "m_day": widget.data["male_astro_details"]["day"],
      "m_month": widget.data["male_astro_details"]["month"],
      "m_year": widget.data["male_astro_details"]["year"],
      "m_hour": widget.data["male_astro_details"]["hour"],
      "m_min": widget.data["male_astro_details"]["minute"],
      "m_lat": widget.data["male_astro_details"]["latitude"],
      "m_lon": widget.data["male_astro_details"]["longitude"],
      "m_tzone": 5.5,
      "f_day": widget.data["female_astro_details"]["day"],
      "f_month": widget.data["female_astro_details"]["month"],
      "f_year": widget.data["female_astro_details"]["year"],
      "f_hour": widget.data["female_astro_details"]["hour"],
      "f_min": widget.data["female_astro_details"]["minute"],
      "f_lat": widget.data["female_astro_details"]["latitude"],
      "f_lon": widget.data["female_astro_details"]["longitude"],
      "f_tzone": 5.5
    }).then((value) {
      setState(() {
        astroData = value;
      });
    });
    AstroApiServices().getPlanetDetails({
      "m_day": widget.data["male_astro_details"]["day"],
      "m_month": widget.data["male_astro_details"]["month"],
      "m_year": widget.data["male_astro_details"]["year"],
      "m_hour": widget.data["male_astro_details"]["hour"],
      "m_min": widget.data["male_astro_details"]["minute"],
      "m_lat": widget.data["male_astro_details"]["latitude"],
      "m_lon": widget.data["male_astro_details"]["longitude"],
      "m_tzone": 5.5,
      "f_day": widget.data["female_astro_details"]["day"],
      "f_month": widget.data["female_astro_details"]["month"],
      "f_year": widget.data["female_astro_details"]["year"],
      "f_hour": widget.data["female_astro_details"]["hour"],
      "f_min": widget.data["female_astro_details"]["minute"],
      "f_lat": widget.data["female_astro_details"]["latitude"],
      "f_lon": widget.data["female_astro_details"]["longitude"],
      "f_tzone": 5.5
    }).then((value) {
      setState(() {
        planetAstroData = value;
      });
    });
    AstroApiServices().getManglikReport({
      "m_day": widget.data["male_astro_details"]["day"],
      "m_month": widget.data["male_astro_details"]["month"],
      "m_year": widget.data["male_astro_details"]["year"],
      "m_hour": widget.data["male_astro_details"]["hour"],
      "m_min": widget.data["male_astro_details"]["minute"],
      "m_lat": widget.data["male_astro_details"]["latitude"],
      "m_lon": widget.data["male_astro_details"]["longitude"],
      "m_tzone": 5.5,
      "f_day": widget.data["female_astro_details"]["day"],
      "f_month": widget.data["female_astro_details"]["month"],
      "f_year": widget.data["female_astro_details"]["year"],
      "f_hour": widget.data["female_astro_details"]["hour"],
      "f_min": widget.data["female_astro_details"]["minute"],
      "f_lat": widget.data["female_astro_details"]["latitude"],
      "f_lon": widget.data["female_astro_details"]["longitude"],
      "f_tzone": 5.5
    }).then((value) {
      setState(() {
        manglikData = value;
      });
    });
    AstroApiServices().getDashakootReport({
      "m_day": widget.data["male_astro_details"]["day"],
      "m_month": widget.data["male_astro_details"]["month"],
      "m_year": widget.data["male_astro_details"]["year"],
      "m_hour": widget.data["male_astro_details"]["hour"],
      "m_min": widget.data["male_astro_details"]["minute"],
      "m_lat": widget.data["male_astro_details"]["latitude"],
      "m_lon": widget.data["male_astro_details"]["longitude"],
      "m_tzone": 5.5,
      "f_day": widget.data["female_astro_details"]["day"],
      "f_month": widget.data["female_astro_details"]["month"],
      "f_year": widget.data["female_astro_details"]["year"],
      "f_hour": widget.data["female_astro_details"]["hour"],
      "f_min": widget.data["female_astro_details"]["minute"],
      "f_lat": widget.data["female_astro_details"]["latitude"],
      "f_lon": widget.data["female_astro_details"]["longitude"],
      "f_tzone": 5.5
    }).then((value) {
      log("hhhhh:$value");
      setState(() {
        dashakoot = value;
      });
    });

    AstroApiServices().getMatchObstructionReport({
      "m_day": widget.data["male_astro_details"]["day"],
      "m_month": widget.data["male_astro_details"]["month"],
      "m_year": widget.data["male_astro_details"]["year"],
      "m_hour": widget.data["male_astro_details"]["hour"],
      "m_min": widget.data["male_astro_details"]["minute"],
      "m_lat": widget.data["male_astro_details"]["latitude"],
      "m_lon": widget.data["male_astro_details"]["longitude"],
      "m_tzone": 5.5,
      "f_day": widget.data["female_astro_details"]["day"],
      "f_month": widget.data["female_astro_details"]["month"],
      "f_year": widget.data["female_astro_details"]["year"],
      "f_hour": widget.data["female_astro_details"]["hour"],
      "f_min": widget.data["female_astro_details"]["minute"],
      "f_lat": widget.data["female_astro_details"]["latitude"],
      "f_lon": widget.data["female_astro_details"]["longitude"],
      "f_tzone": 5.5
    }).then((value) {
      log("hhhhh:$value");
      setState(() {
        matchObstruction = value;
      });
    });
    AstroApiServices().getLagan({
      "m_day": widget.data["male_astro_details"]["day"],
      "m_month": widget.data["male_astro_details"]["month"],
      "m_year": widget.data["male_astro_details"]["year"],
      "m_hour": widget.data["male_astro_details"]["hour"],
      "m_min": widget.data["male_astro_details"]["minute"],
      "m_lat": widget.data["male_astro_details"]["latitude"],
      "m_lon": widget.data["male_astro_details"]["longitude"],
      "m_tzone": 5.5,
      "f_day": widget.data["female_astro_details"]["day"],
      "f_month": widget.data["female_astro_details"]["month"],
      "f_year": widget.data["female_astro_details"]["year"],
      "f_hour": widget.data["female_astro_details"]["hour"],
      "f_min": widget.data["female_astro_details"]["minute"],
      "f_lat": widget.data["female_astro_details"]["latitude"],
      "f_lon": widget.data["female_astro_details"]["longitude"],
      "f_tzone": 5.5
    }).then((value) {
      log("hhhhh:$value");
      setState(() {
        lagna = value;
      });});
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size for responsiveness
    final size = MediaQuery.of(context).size;

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppbarProfile(userName: 'Details',),
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
                     // buildLagnaSection(),
                      buildDetailsSection(),
                      buildAshtakootPointsSection(),
                      buildMatchObstructionsSection(),
                      buildAstroDetailsSection(),
                      buildPlanetDetailsSection(),
                      buildManglikReportSection(),
                      buildDashakootPointsSection(),
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

  // lagna widget
  // Widget buildLagnaSection() {
  //   return SvgCanvasWidget(
  //     rawSvg: lagna["svg"],
  //     width: 200,
  //     height: 200,
  //   );
  // }
// birth details
  Widget buildDetailsSection() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildDetailRow("Male Ayanamsha : ",
              "${widget.data["male_astro_details"]["ayanamsha"]}"),
          buildDetailRow("Male Sunrise : ",
              "${widget.data["male_astro_details"]["sunrise"]}"),
          buildDetailRow("Male Sunset : ",
              "${widget.data["male_astro_details"]["sunset"]}"),
          buildDetailRow("Female Ayanamsha : ",
              "${widget.data["female_astro_details"]["ayanamsha"]}"),
          buildDetailRow("Female Sunrise : ",
              "${widget.data["female_astro_details"]["sunrise"]}"),
          buildDetailRow("Female Sunset : ",
              "${widget.data["female_astro_details"]["sunset"]}"),
        ],
      ),
    );
  }

// ashtakoot
  Widget buildAshtakootPointsSection() {
    List<Map<String, dynamic>> points = [
      {"name": "Varna", "score": 1},
      {"name": "Vashya", "score": 2},
      {"name": "Tara", "score": 3},
      {"name": "Yoni", "score": 4},
      {"name": "Graha Maitri", "score": 5},
      {"name": "Gana", "score": 6},
      {"name": "Bhakut", "score": 7},
      {"name": "Nadi", "score": 8},
    ];

    return SingleChildScrollView(
      child: Column(
        children: points.map((point) {
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              onTap: () {
                GoRouter.of(context)
                    .pushNamed(RoutesName.horoscope, extra: ashData);
              },
              contentPadding: const EdgeInsets.all(6.0),
              leading: CircleAvatar(
                radius: 13,
                backgroundColor: Resources.colors.buttonColor.withOpacity(0.8),
                child: Text(
                  point['score'].toString(),
                  style: Resources.styles.kTextStyle14B(Colors.white),
                ),
              ),
              title: Text(
                point['name'],
                style: Resources.styles.kTextStyle16B(Colors.black87),
              ),
              trailing: Icon(
                Icons.star,
                color: Resources.colors.buttonColor,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // match obstructions
  Widget buildMatchObstructionsSection() {
    return matchObstruction!=null? SingleChildScrollView(
      child: Column(children: [
        Text(
          "${matchObstruction['vedha_report']}",
          style: Resources.styles.kTextStyle14B(Colors.grey),
        ),
      ]),
    ):Center(
      child: CircularProgressIndicator(
        color: Resources.colors.buttonColor,
      ),
    );
  }

  // Astro details
  Widget buildAstroDetailsSection() {
    return astroData != null
        ? SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          alignment: Alignment.center,
                          child: Text(
                            "Male Details",
                            textAlign: TextAlign.center,
                            style: Resources.styles.kTextStyle16B(Colors.black),
                          )),
                      const Divider(
                        thickness: .5,
                        color: Colors.grey,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Ascendant",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            "${astroData["male_astro_details"]["ascendant"]}",
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
                            "${astroData["male_astro_details"]["Varna"]}",
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
                            "${astroData["male_astro_details"]["Vashya"]}",
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
                            "${astroData["male_astro_details"]["Yoni"]}",
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
                            "${astroData["male_astro_details"]["Gan"]}",
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
                            "${astroData["male_astro_details"]["Nadi"]}",
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
                            "${astroData["male_astro_details"]["SignLord"]}",
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
                            "${astroData["male_astro_details"]["sign"]}",
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
                            "${astroData["male_astro_details"]["sign"]}",
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
                            "${astroData["male_astro_details"]["Naksahtra"]}",
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
                            "${astroData["male_astro_details"]["NaksahtraLord"]}",
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
                            astroData["male_astro_details"]["Charan"]
                                .toString(),
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
                            astroData["male_astro_details"]["Yog"].toString(),
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
                            astroData["male_astro_details"]["Karan"].toString(),
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
                            astroData["male_astro_details"]["Tithi"].toString(),
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
                            astroData["male_astro_details"]["Krishna"]
                                .toString(),
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
                            astroData["male_astro_details"]["yunja"].toString(),
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
                            astroData["male_astro_details"]["tatva"].toString(),
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
                            astroData["male_astro_details"]["name_alphabet"]
                                .toString(),
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
                            astroData["male_astro_details"]["paya"].toString(),
                            style: Resources.styles.kTextStyle14B(Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          alignment: Alignment.center,
                          child: Text(
                            "Female Details",
                            textAlign: TextAlign.center,
                            style: Resources.styles.kTextStyle16B(Colors.black),
                          )),
                      const Divider(
                        thickness: .5,
                        color: Colors.grey,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Ascendant",
                            style: Resources.styles.kTextStyle14B(Colors.black),
                          ),
                          Text(
                            "${astroData["female_astro_details"]["ascendant"]}",
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
                            "${astroData["female_astro_details"]["Varna"]}",
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
                            "${astroData["female_astro_details"]["Vashya"]}",
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
                            "${astroData["female_astro_details"]["Yoni"]}",
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
                            "${astroData["female_astro_details"]["Gan"]}",
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
                            "${astroData["female_astro_details"]["Nadi"]}",
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
                            "${astroData["female_astro_details"]["SignLord"]}",
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
                            "${astroData["female_astro_details"]["sign"]}",
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
                            "${astroData["female_astro_details"]["sign"]}",
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
                            "${astroData["female_astro_details"]["Naksahtra"]}",
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
                            "${astroData["female_astro_details"]["NaksahtraLord"]}",
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
                            astroData["female_astro_details"]["Charan"]
                                .toString(),
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
                            astroData["female_astro_details"]["Yog"].toString(),
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
                            astroData["female_astro_details"]["Karan"]
                                .toString(),
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
                            astroData["female_astro_details"]["Tithi"]
                                .toString(),
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
                            astroData["female_astro_details"]["Krishna"]
                                .toString(),
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
                            astroData["female_astro_details"]["yunja"]
                                .toString(),
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
                            astroData["female_astro_details"]["tatva"]
                                .toString(),
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
                            astroData["female_astro_details"]["name_alphabet"]
                                .toString(),
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
                            astroData["female_astro_details"]["paya"]
                                .toString(),
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

  bool isMaleSelected = true;
  // planet details
  Widget buildPlanetDetailsSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isMaleSelected = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isMaleSelected ? Resources.colors.buttonColor : Colors.grey,
              ),
              child: Text(
                'Male',
                style: Resources.styles.kTextStyle12B(
                    isMaleSelected ? Colors.white : Colors.black),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isMaleSelected = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: !isMaleSelected
                    ? Resources.colors.buttonColor
                    : Colors.grey,
              ),
              child: Text(
                'Female',
                style: Resources.styles.kTextStyle12B(
                    isMaleSelected ? Colors.white : Colors.black),
              ),
            ),
          ],
        ),
        Expanded(
          child: planetAstroData != null
              ? (isMaleSelected
                  ? buildPlanetBoyDetailsList(
                      planetAstroData["male_planet_details"])
                  : buildPlanetGirlDetailsList(
                      planetAstroData["female_planet_details"]))
              : Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Resources.colors.buttonColor,
                  ),
                ),
        ),
      ],
    );
  }

  // Manglik Report
  Widget buildManglikReportSection() {
    return manglikData != null
        ? SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        "Male",
                        style: Resources.styles.kTextStyle16B(Colors.grey),
                      ),
                    ),
                    const Divider(
                      thickness: .5,
                      color: Colors.grey,
                    ),
                    Text(
                      "Based on Aspect:",
                      style: Resources.styles.kTextStyle14B(Colors.black),
                    ),
                    Text(
                      (manglikData["male"]["manglik_present_rule"]
                              ["based_on_aspect"] as List)
                          .join("\n"),
                      style: Resources.styles.kTextStyle12B(Colors.grey),
                    ),
                    Text(
                      "Based on House:",
                      style: Resources.styles.kTextStyle14B(Colors.black),
                    ),
                    Text(
                      (manglikData["male"]["manglik_present_rule"]
                              ["based_on_house"] as List)
                          .join("\n"),
                      style: Resources.styles.kTextStyle12B(Colors.grey),
                    ),
                    Row(
                      children: [
                        Text("Manglik Status :",
                            style:
                                Resources.styles.kTextStyle14B(Colors.black)),
                        Text(" ${manglikData["male"]["manglik_status"]}",
                            style: Resources.styles.kTextStyle12B(Colors.grey)),
                      ],
                    ),
                    Row(
                      children: [
                        Text("Manglik Status :",
                            style:
                                Resources.styles.kTextStyle14B(Colors.black)),
                        Text(
                            " ${manglikData["male"]["percentage_manglik_present"].toString()}",
                            style: Resources.styles.kTextStyle12B(Colors.grey)),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Manglik Report :",
                            style:
                                Resources.styles.kTextStyle14B(Colors.black)),
                        Expanded(
                          child: Text(
                              " ${manglikData["male"]["manglik_report"]}",
                              style:
                                  Resources.styles.kTextStyle12B(Colors.grey)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        "Female",
                        style: Resources.styles.kTextStyle16B(Colors.grey),
                      ),
                    ),
                    const Divider(
                      thickness: .5,
                      color: Colors.grey,
                    ),
                    Text(
                      "Based on Aspect:",
                      style: Resources.styles.kTextStyle14B(Colors.black),
                    ),
                    Text(
                      (manglikData["female"]["manglik_present_rule"]
                              ["based_on_aspect"] as List)
                          .join("\n"),
                      style: Resources.styles.kTextStyle12B(Colors.grey),
                    ),
                    Text(
                      "Based on House:",
                      style: Resources.styles.kTextStyle14B(Colors.black),
                    ),
                    Text(
                      (manglikData["female"]["manglik_present_rule"]
                              ["based_on_house"] as List)
                          .join("\n"),
                      style: Resources.styles.kTextStyle12B(Colors.grey),
                    ),
                    Row(
                      children: [
                        Text("Manglik Status :",
                            style:
                                Resources.styles.kTextStyle14B(Colors.black)),
                        Text(" ${manglikData["female"]["manglik_status"]}",
                            style: Resources.styles.kTextStyle12B(Colors.grey)),
                      ],
                    ),
                    Row(
                      children: [
                        Text("Manglik Status :",
                            style:
                                Resources.styles.kTextStyle14B(Colors.black)),
                        Text(
                            " ${manglikData["female"]["percentage_manglik_present"].toString()}",
                            style: Resources.styles.kTextStyle12B(Colors.grey)),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Manglik Report :",
                            style:
                                Resources.styles.kTextStyle14B(Colors.black)),
                        Expanded(
                          child: Text(
                              " ${manglikData["female"]["manglik_report"]}",
                              style:
                                  Resources.styles.kTextStyle12B(Colors.grey)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                "Conclusion:",
                style: Resources.styles.kTextStyle14B(Colors.black),
              ),
              Text(
                " ${manglikData["conclusion"]["report"]}",
                style: Resources.styles.kTextStyle12B(Colors.grey),
              ),
            ]),
          )
        : Center(
            child: CircularProgressIndicator(
              color: Resources.colors.buttonColor,
            ),
          );
  }

  // dashakoot points
  Widget buildDashakootPointsSection() {
    List<Map<String, dynamic>> dashakootPoints = [
      {"name": "Dina"},
      {"name": "Gana"},
      {"name": "Yoni"},
      {"name": "Rashi"},
      {"name": "Rasyadhipati Maitri"},
      {"name": "Rajju"},
      {"name": "Vedha"},
      {"name": "Vashya"},
      {"name": "Mahendra"},
      {"name": "StreeDeergha"},
    ];

    return SingleChildScrollView(
      child: Column(
        children: List.generate(dashakootPoints.length, (index) {
          final point = dashakootPoints[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              onTap: () {
                GoRouter.of(context)
                    .pushNamed(RoutesName.dashakoot, extra: dashakoot);
              },
              contentPadding: const EdgeInsets.all(6.0),
              leading: CircleAvatar(
                radius: 10,
                backgroundColor: Resources.colors.buttonColor.withOpacity(0.8),
                child: Text(
                  (index + 1).toString(), // Display index starting from 1
                  style: Resources.styles.kTextStyle14B(Colors.white),
                ),
              ),
              title: Text(
                point['name'],
                style: Resources.styles.kTextStyle16B(Colors.black87),
              ),
              trailing: Icon(
                Icons.star,
                color: Resources.colors.buttonColor,
              ),
            ),
          );
        }),
      ),
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

  Widget buildPlanetBoyDetailsList(List<dynamic> planetDetails) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: planetAstroData["male_planet_details"].length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(6.0),
                    leading: CircleAvatar(
                      radius: 13,
                      backgroundColor:
                          Resources.colors.buttonColor.withOpacity(0.8),
                      child: Text(
                        planetAstroData["male_planet_details"][index]["name"]
                            [0],
                        style: Resources.styles.kTextStyle14B(Colors.white),
                      ),
                    ),
                    title: Text(
                      "${planetAstroData["male_planet_details"][index]["name"]}",
                      style: Resources.styles.kTextStyle16B(Colors.black87),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${planetAstroData["male_planet_details"][index]["fullDegree"]}',
                          style: Resources.styles.kTextStyle14(Colors.black54),
                        ),
                        Text(
                          '${planetAstroData["male_planet_details"][index]["sign"]}',
                          style: Resources.styles.kTextStyle14(Colors.black54),
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }

  Widget buildPlanetGirlDetailsList(List<dynamic> planetDetails) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: planetAstroData["female_planet_details"].length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(6.0),
                    leading: CircleAvatar(
                      radius: 13,
                      backgroundColor:
                          Resources.colors.buttonColor.withOpacity(0.8),
                      child: Text(
                        planetAstroData["female_planet_details"][index]["name"]
                            [0],
                        style: Resources.styles.kTextStyle14B(Colors.white),
                      ),
                    ),
                    title: Text(
                      "${planetAstroData["female_planet_details"][index]["name"]}",
                      style: Resources.styles.kTextStyle16B(Colors.black87),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${planetAstroData["female_planet_details"][index]["fullDegree"]}',
                          style: Resources.styles.kTextStyle14(Colors.black54),
                        ),
                        Text(
                          '${planetAstroData["female_planet_details"][index]["sign"]}',
                          style: Resources.styles.kTextStyle14(Colors.black54),
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ],
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