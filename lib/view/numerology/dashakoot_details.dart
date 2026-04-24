
import 'package:flutter/material.dart';
import 'package:astro_mukti/view/widgets/appbar_profile.dart';

import '../../resources/resources.dart';

class DashakootDetails extends StatefulWidget {
  final Map<String, dynamic> data;
  const DashakootDetails({super.key, required this.data});

  @override
  State<DashakootDetails> createState() => _DashakootDetailsState();
}

class _DashakootDetailsState extends State<DashakootDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarProfile(userName: 'Dashakoot Details',),
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
            // Container(
            //   padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            //   child: Text(
            //     "${widget.data["conclusion"]["report"]}",
            //     style:
            //         Resources.styles.kTextStyle16(Resources.colors.blackColor),
            //   ),
            // ),
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
                      "Dina",
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.data["dina"]["total_points"].toString(),
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.data["dina"]["received_points"].toString(),
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Icon(
                    Icons.done,
                    color: widget.data["dina"]["total_points"] ==
                            widget.data["dina"]["received_points"]
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
                      "Gana",
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.data["gana"]["total_points"].toString(),
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.data["gana"]["received_points"].toString(),
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Icon(
                    Icons.done,
                    color: widget.data["gana"]["total_points"] ==
                            widget.data["gana"]["received_points"]
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
                      widget.data["yoni"]["total_points"].toString(),
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.data["yoni"]["received_points"].toString(),
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
                      "Rashi",
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.data["rashi"]["total_points"].toString(),
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.data["rashi"]["received_points"].toString(),
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Icon(
                    Icons.done,
                    color: widget.data["rashi"]["total_points"] ==
                            widget.data["rashi"]["received_points"]
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
                      "Rasyadhipati",
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.data["rasyadhipati"]["total_points"].toString(),
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.data["rasyadhipati"]["received_points"].toString(),
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Icon(
                    Icons.done,
                    color: widget.data["rasyadhipati"]["total_points"] ==
                            widget.data["rasyadhipati"]["received_points"]
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
                      "Rajju",
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.data["rajju"]["total_points"].toString(),
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.data["rajju"]["received_points"].toString(),
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Icon(
                    Icons.done,
                    color: widget.data["rajju"]["total_points"] ==
                            widget.data["rajju"]["received_points"]
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
                      "Vedha",
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.data["vedha"]["total_points"].toString(),
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.data["vedha"]["received_points"].toString(),
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Icon(
                    Icons.done,
                    color: widget.data["vedha"]["total_points"] ==
                            widget.data["vedha"]["received_points"]
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
                      widget.data["vashya"]["total_points"].toString(),
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.data["vashya"]["received_points"].toString(),
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
                      "Mahendra",
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.data["mahendra"]["total_points"].toString(),
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.data["mahendra"]["received_points"].toString(),
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Icon(
                    Icons.done,
                    color: widget.data["mahendra"]["total_points"] ==
                            widget.data["mahendra"]["received_points"]
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
                      "StreeDeergha",
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.data["streeDeergha"]["total_points"].toString(),
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.data["streeDeergha"]["received_points"].toString(),
                      style: Resources.styles
                          .kTextStyle14(Resources.colors.blackColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Icon(
                    Icons.done,
                    color: widget.data["streeDeergha"]["total_points"] ==
                            widget.data["streeDeergha"]["received_points"]
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
