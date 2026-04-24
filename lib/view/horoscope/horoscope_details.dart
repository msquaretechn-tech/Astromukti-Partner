import 'dart:developer';


import 'package:flutter/material.dart';
import 'package:astro_mukti/view/widgets/appbar_profile.dart';

import '../../resources/resources.dart';

class HoroscopeDetails extends StatefulWidget {
  final Map<String, dynamic> data;
  const HoroscopeDetails({super.key, required this.data});

  @override
  State<HoroscopeDetails> createState() => _HoroscopeDetailsState();
}

class _HoroscopeDetailsState extends State<HoroscopeDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppbarProfile(userName: "Details"),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8),
        color: Resources.colors.buttonColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Total",
                style:
                    Resources.styles.kTextStyle16(Resources.colors.blackColor),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                "${widget.data["total"]["total_points"]}",
                style:
                    Resources.styles.kTextStyle16(Resources.colors.blackColor),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                "${widget.data["total"]["received_points"]}",
                style:
                    Resources.styles.kTextStyle16(Resources.colors.blackColor),
                textAlign: TextAlign.center,
              ),
            ),
            const Icon(
              Icons.done,
              color: Colors.black,
            )
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Text(
                "${widget.data["conclusion"]["report"]}",
                style:
                    Resources.styles.kTextStyle16(Resources.colors.blackColor),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
              color: Colors.grey[300],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "Attribute",
                      style: Resources.styles
                          .kTextStyle16B(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Total",
                      style: Resources.styles
                          .kTextStyle16B(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Match",
                      style: Resources.styles
                          .kTextStyle16B(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Varna",
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.data["varna"]["total_points"].toString() ?? "",
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.data["varna"]["received_points"].toString() ?? "",
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Icon(
                    Icons.done,
                    color: widget.data["varna"]["total_points"] ==
                            widget.data["varna"]["received_points"]
                        ? Colors.green
                        : Colors.red,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Vashya",
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.data["vashya"]["total_points"].toString() ?? "",
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.data["vashya"]["received_points"].toString() ?? "",
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Icon(
                    Icons.done,
                    color: widget.data["vashya"]["total_points"] ==
                            widget.data["vashya"]["received_points"]
                        ? Colors.green
                        : Colors.red,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Tara",
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.data["tara"]["total_points"].toString() ?? "",
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.data["tara"]["received_points"].toString() ?? "",
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Icon(
                    Icons.done,
                    color: widget.data["tara"]["total_points"] ==
                            widget.data["tara"]["received_points"]
                        ? Colors.green
                        : Colors.red,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Yoni",
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.data["yoni"]["total_points"].toString() ?? "",
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.data["yoni"]["received_points"].toString() ?? "",
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Icon(
                    Icons.done,
                    color: widget.data["yoni"]["total_points"] ==
                            widget.data["yoni"]["received_points"]
                        ? Colors.green
                        : Colors.red,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Maitri",
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.data["maitri"]["total_points"].toString() ?? "",
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.data["maitri"]["received_points"].toString() ?? "",
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Icon(
                    Icons.done,
                    color: widget.data["maitri"]["total_points"] ==
                            widget.data["maitri"]["received_points"]
                        ? Colors.green
                        : Colors.red,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "gan",
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.data["gan"]["total_points"].toString() ?? "",
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.data["gan"]["received_points"].toString() ?? "",
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Icon(
                    Icons.done,
                    color: widget.data["gan"]["total_points"] ==
                            widget.data["gan"]["received_points"]
                        ? Colors.green
                        : Colors.red,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Bhakut",
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.data["bhakut"]["total_points"].toString() ?? "",
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.data["bhakut"]["received_points"].toString() ?? "",
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Icon(
                    Icons.done,
                    color: widget.data["bhakut"]["total_points"] ==
                            widget.data["bhakut"]["received_points"]
                        ? Colors.green
                        : Colors.red,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Nadi",
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.data["nadi"]["total_points"].toString() ?? "",
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.data["nadi"]["received_points"].toString() ?? "",
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Icon(
                    Icons.done,
                    color: widget.data["nadi"]["total_points"] ==
                            widget.data["nadi"]["received_points"]
                        ? Colors.green
                        : Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
