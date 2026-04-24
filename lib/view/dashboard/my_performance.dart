// import 'dart:developer';
//
//
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
//
// import '../../repository/repository.dart';
// import '../../resources/resources.dart';
//
// class MyPerformance extends StatefulWidget {
//   const MyPerformance({super.key});
//
//   @override
//   State<MyPerformance> createState() => _MyPerformanceState();
// }
//
// class _MyPerformanceState extends State<MyPerformance> {
//   var dailyPerformances;
//   var weeklyPerformances;
//   var monthlyPerformances;
//   @override
//   void initState() {
//     super.initState();
//     Repository().dailyPerformance().then((value) {
//       setState(() {
//         dailyPerformances = value;
//       });
//       log("dailyPerformances $dailyPerformances");
//     });
//     Repository().weeklyPerformance("weekly").then((value) {
//       setState(() {
//         weeklyPerformances = value;
//       });
//       log("weeklyPerformances $weeklyPerformances");
//     });
//     Repository().monthPerformance("monthly").then((value) {
//       setState(() {
//         monthlyPerformances = value;
//       });
//       log("monthlyPerformances $monthlyPerformances");
//     });
//   }
//
//   int _selectedIndex = 0;
//   // for daily
//   List<BarChartGroupData> _generateHorizontalBarData() {
//     if (dailyPerformances == null || dailyPerformances.isEmpty) {
//       return [];
//     }
//     return dailyPerformances
//         .map<BarChartGroupData>((e) {
//       return BarChartGroupData(
//         x: e["totalAmount"],
//         barRods: [
//           BarChartRodData(
//             toY: double.parse(e["totalAmount"].toString()) / 10,
//             width: 25,
//             color: Resources.colors.buttonColor,
//             borderRadius: BorderRadius.zero,
//           ),
//         ],
//       );
//     })
//         .take(5)
//         .toList();
//   }
//
//   // for weekly
//   List<BarChartGroupData> _generateWeeklyHorizontalBarData() {
//     if (weeklyPerformances == null || dailyPerformances.isEmpty) {
//       return [];
//     }
//     return weeklyPerformances
//         .map<BarChartGroupData>((e) {
//       return BarChartGroupData(
//         x: e["totalAmount"],
//         barRods: [
//           BarChartRodData(
//             toY: double.parse(e["totalAmount"].toString()) / 50,
//             width: 25,
//             color: Resources.colors.buttonColor,
//             borderRadius: BorderRadius.zero,
//           ),
//         ],
//       );
//     })
//         .take(5)
//         .toList();
//   }
//
//   // for monthly
//   List<BarChartGroupData> _generateMonthlyPerformancesHorizontalBarData() {
//     if (monthlyPerformances == null || monthlyPerformances.isEmpty) {
//       return [];
//     }
//     return monthlyPerformances
//         .map<BarChartGroupData>((e) {
//       return BarChartGroupData(
//         x: e["totalAmount"],
//         barRods: [
//           BarChartRodData(
//             toY: double.parse(e["totalAmount"].toString()) / 50,
//             width: 25,
//             color: Resources.colors.buttonColor,
//             borderRadius: BorderRadius.zero,
//           ),
//         ],
//       );
//     })
//         .take(5)
//         .toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         backgroundColor: Colors.transparent,
//         title: Text(
//           "My Performance",
//           style: Resources.styles.kTextStyle16B(Colors.black),
//         ),
//       ),
//       body: SafeArea(
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         Repository().dailyPerformance().then((value) {
//                           dailyPerformances = value;
//                         });
//                         setState(() {
//                           _selectedIndex = 0;
//                         });
//                       },
//                       child: Card(
//                         elevation: 5,
//                         color: _selectedIndex == 0
//                             ? Resources.colors.buttonColor
//                             : Resources.colors.whiteColor,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10)),
//                         child: Container(
//                           height: MediaQuery.of(context).size.height * .1,
//                           width: MediaQuery.of(context).size.width * .3,
//                           alignment: Alignment.center,
//                           decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10)),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Image.asset(
//                                 Resources.images.calenderImage,
//                                 color: _selectedIndex == 0
//                                     ? Resources.colors.whiteColor
//                                     : Resources.colors.blackColor,
//                               ),
//                               const SizedBox(
//                                 height: 2,
//                               ),
//                               Text(
//                                 "Daily\nPerformance",
//                                 textAlign: TextAlign.center,
//                                 style: Resources.styles.kTextStyle12B(
//                                   _selectedIndex == 0
//                                       ? Resources.colors.whiteColor
//                                       : Resources.colors.blackColor,
//                                 ),
//                               )
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: MediaQuery.of(context).size.width * .01),
//                     GestureDetector(
//                       onTap: () {
//                         // Repository().weeklyPerformance("week").then((value) {
//                         //   weeklyPerformances = value;
//                         // });
//                         setState(() {
//                           _selectedIndex = 1;
//                         });
//                       },
//                       child: Card(
//                         elevation: 5,
//                         color: _selectedIndex == 1
//                             ? Resources.colors.buttonColor
//                             : Resources.colors.whiteColor,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10)),
//                         child: Container(
//                           height: MediaQuery.of(context).size.height * .1,
//                           width: MediaQuery.of(context).size.width * .3,
//                           alignment: Alignment.center,
//                           decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10)),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Image.asset(
//                                 Resources.images.calenderImage,
//                                 color: _selectedIndex == 1
//                                     ? Resources.colors.whiteColor
//                                     : Resources.colors.blackColor,
//                               ),
//                               const SizedBox(
//                                 height: 2,
//                               ),
//                               Text(
//                                 "Weekly\nPerformance",
//                                 textAlign: TextAlign.center,
//                                 style: Resources.styles.kTextStyle12B(
//                                   _selectedIndex == 1
//                                       ? Resources.colors.whiteColor
//                                       : Resources.colors.blackColor,
//                                 ),
//                               )
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: MediaQuery.of(context).size.width * .01),
//                     GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           _selectedIndex = 2;
//                         });
//                       },
//                       child: Card(
//                         elevation: 5,
//                         color: _selectedIndex == 2
//                             ? Resources.colors.buttonColor
//                             : Resources.colors.whiteColor,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10)),
//                         child: Container(
//                           height: MediaQuery.of(context).size.height * .1,
//                           width: MediaQuery.of(context).size.width * .3,
//                           alignment: Alignment.center,
//                           decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10)),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Image.asset(
//                                 Resources.images.calenderImage,
//                                 color: _selectedIndex == 2
//                                     ? Resources.colors.whiteColor
//                                     : Resources.colors.blackColor,
//                               ),
//                               const SizedBox(
//                                 height: 2,
//                               ),
//                               Text(
//                                 "Monthly Performance",
//                                 textAlign: TextAlign.center,
//                                 style: Resources.styles.kTextStyle12B(
//                                   _selectedIndex == 2
//                                       ? Resources.colors.whiteColor
//                                       : Resources.colors.blackColor,
//                                 ),
//                               )
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(
//                   height: MediaQuery.of(context).size.height * .1,
//                 ),
//                 _selectedIndex == 0
//                     ? dailyPerformance()
//                     : _selectedIndex == 1
//                     ? weeklyPerformance()
//                     : monthlyPerformance()
//               ],
//             ),
//           )),
//     );
//   }
//
//   // for daily performance
//   Widget dailyPerformance() {
//     return dailyPerformances != null && dailyPerformances.isNotEmpty
//         ? Column(
//       children: [
//         SizedBox(height: MediaQuery.of(context).size.height * .02),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//           // Reduce height to prevent overlap
//           child: SizedBox(
//             height: MediaQuery.of(context).size.height * .3, // Adjusted height
//             child: RotatedBox(
//               quarterTurns: 4,
//               child: BarChart(
//                 BarChartData(
//                   alignment: BarChartAlignment.spaceBetween,
//                   maxY: 100,
//                   minY: 0,
//                   groupsSpace: 20,
//                   barTouchData: BarTouchData(enabled: false),
//                   titlesData: FlTitlesData(
//                     bottomTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         reservedSize: 40,
//                         getTitlesWidget: (value, meta) {
//                           if (value.toInt() == 0) {
//                             return const SizedBox.shrink();
//                           }
//                           return Padding(
//                             padding: const EdgeInsets.only(bottom: 8.0),
//                             child: Text(
//                               '₹${value.toStringAsFixed(1)}',
//                               style: Resources.styles.kTextStyle12B(Colors.black),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     leftTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         reservedSize: 28,
//                         getTitlesWidget: (value, meta) {
//                           return Padding(
//                             padding: const EdgeInsets.only(left: 4.0),
//                             child: Text(
//                               dailyPerformances != null &&
//                                   dailyPerformances.isNotEmpty &&
//                                   value.toInt() < dailyPerformances.length
//                                   ? (dailyPerformances[value.toInt()]["_id"])
//                                   .toString()
//                                   .substring(8, 10)
//                                   : "",
//                               style: Resources.styles.kTextStyle12B(Colors.black),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     topTitles: const AxisTitles(
//                       sideTitles: SideTitles(showTitles: false),
//                     ),
//                     rightTitles: const AxisTitles(
//                       sideTitles: SideTitles(showTitles: false),
//                     ),
//                   ),
//                   gridData: const FlGridData(show: false),
//                   borderData: FlBorderData(
//                     show: true,
//                     border: const Border(
//                       bottom: BorderSide(color: Colors.grey, width: 1),
//                       left: BorderSide(color: Colors.grey, width: 1),
//                       right: BorderSide(color: Colors.transparent),
//                       top: BorderSide(color: Colors.transparent),
//                     ),
//                   ),
//                   barGroups: _generateHorizontalBarData(),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     )
//         : Center(
//       child: Text(
//         "No Data",
//         style: Resources.styles.kTextStyle14B(Colors.black),
//       ),
//     );
//   }
//
//
//
//   // weekly performance
//   Widget weeklyPerformance() {
//     return weeklyPerformances != null && weeklyPerformances.isNotEmpty
//         ? Column(
//       children: [
//         SizedBox(height: MediaQuery.of(context).size.height * .02),
//         Container(
//           padding:
//           const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//           child: SizedBox(
//             height: MediaQuery.of(context).size.height * .4,
//             child: RotatedBox(
//               quarterTurns: 4,
//               child: BarChart(
//                 BarChartData(
//                   alignment: BarChartAlignment.spaceBetween,
//                   maxY: 100,
//                   minY: 0,
//                   groupsSpace: 20,
//                   barTouchData: BarTouchData(enabled: false),
//                   titlesData: FlTitlesData(
//                     bottomTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         reservedSize: 40,
//                         getTitlesWidget: (value, meta) {
//                           if (value.toInt() == 0) {
//                             return const SizedBox.shrink();
//                           }
//                           return Padding(
//                             padding: const EdgeInsets.only(bottom: 8.0),
//                             child: Text(
//                               '₹${value.toStringAsFixed(1)}',
//                               style: Resources.styles
//                                   .kTextStyle12B(Colors.black),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     leftTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         reservedSize: 28,
//                         getTitlesWidget: (value, meta) {
//                           int index = value.toInt();
//                           return Padding(
//                             padding: const EdgeInsets.only(left: 4.0),
//                             child: Text(
//                               (weeklyPerformances != null &&
//                                   index < weeklyPerformances.length)
//                                   ? weeklyPerformances[index]["_id"]
//                               ["week"]
//                                   .toString()
//                                   : "",
//                               style: Resources.styles
//                                   .kTextStyle12B(Colors.black),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     topTitles: const AxisTitles(
//                       sideTitles: SideTitles(showTitles: false),
//                     ),
//                     rightTitles: const AxisTitles(
//                       sideTitles: SideTitles(showTitles: false),
//                     ),
//                   ),
//                   gridData: const FlGridData(show: false),
//                   borderData: FlBorderData(
//                     show: true,
//                     border: const Border(
//                       bottom: BorderSide(color: Colors.grey, width: 1),
//                       left: BorderSide(color: Colors.grey, width: 1),
//                       right: BorderSide(color: Colors.transparent),
//                       top: BorderSide(color: Colors.transparent),
//                     ),
//                   ),
//                   barGroups: _generateWeeklyHorizontalBarData(),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     )
//         : Center(
//       child: Text(
//         "No Data",
//         style: Resources.styles.kTextStyle14B(Colors.black),
//       ),
//     );
//   }
//
//   // for daily performance
//   Widget monthlyPerformance() {
//     return monthlyPerformances != null && monthlyPerformances.isNotEmpty
//         ? Column(
//       children: [
//         SizedBox(height: MediaQuery.of(context).size.height * .02),
//         Container(
//           padding:
//           const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//           child: SizedBox(
//             height: MediaQuery.of(context).size.height * .4,
//             child: RotatedBox(
//               quarterTurns: 4,
//               child: BarChart(
//                 BarChartData(
//                   alignment: BarChartAlignment.spaceBetween,
//                   maxY: 100,
//                   minY: 0,
//                   groupsSpace: 20,
//                   barTouchData: BarTouchData(enabled: false),
//                   titlesData: FlTitlesData(
//                     bottomTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         reservedSize: 40,
//                         getTitlesWidget: (value, meta) {
//                           if (value.toInt() == 0) {
//                             return const SizedBox.shrink();
//                           }
//                           return Padding(
//                             padding: const EdgeInsets.only(bottom: 8.0),
//                             child: Text(
//                               '₹${value.toStringAsFixed(1)}',
//                               style: Resources.styles
//                                   .kTextStyle12B(Colors.black),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     leftTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         reservedSize: 28,
//                         getTitlesWidget: (value, meta) {
//                           int index = value.toInt();
//                           return Padding(
//                             padding: const EdgeInsets.only(left: 4.0),
//                             child: Text(
//                               (monthlyPerformances != null &&
//                                   index < monthlyPerformances.length)
//                                   ? monthlyPerformances[index]["_id"]
//                               ["month"]
//                                   .toString()
//                                   : "",
//                               style: Resources.styles
//                                   .kTextStyle12B(Colors.black),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     topTitles: const AxisTitles(
//                       sideTitles: SideTitles(showTitles: false),
//                     ),
//                     rightTitles: const AxisTitles(
//                       sideTitles: SideTitles(showTitles: false),
//                     ),
//                   ),
//                   gridData: const FlGridData(show: false),
//                   borderData: FlBorderData(
//                     show: true,
//                     border: const Border(
//                       bottom: BorderSide(color: Colors.grey, width: 1),
//                       left: BorderSide(color: Colors.grey, width: 1),
//                       right: BorderSide(color: Colors.transparent),
//                       top: BorderSide(color: Colors.transparent),
//                     ),
//                   ),
//                   barGroups:
//                   _generateMonthlyPerformancesHorizontalBarData(),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     )
//         : Center(
//       child: Text(
//         "No Data",
//         style: Resources.styles.kTextStyle14B(Colors.black),
//       ),
//     );
//   }
// }


import 'dart:developer';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../repository/repository.dart';
import '../../resources/resources.dart';

class MyPerformance extends StatefulWidget {
  const MyPerformance({super.key});

  @override
  State<MyPerformance> createState() => _MyPerformanceState();
}

class _MyPerformanceState extends State<MyPerformance> {
  List<dynamic> dailyPerformances = [];
  List<dynamic> weeklyPerformances = [];
  List<dynamic> monthlyPerformances = [];

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    dailyPerformances = await Repository().dailyPerformance();
    weeklyPerformances = await Repository().weeklyPerformance("weekly");
    monthlyPerformances = await Repository().monthPerformance("monthly");

    log("Daily: $dailyPerformances");
    log("Weekly: $weeklyPerformances");
    log("Monthly: $monthlyPerformances");

    setState(() {});
  }

  // ======================= BAR DATA =======================

  List<BarChartGroupData> _buildBarData(
      List<dynamic> data,
      double divideBy,
      ) {
    return List.generate(
      data.length > 5 ? 5 : data.length,
          (index) {
        final value =
            double.tryParse(data[index]["totalAmount"].toString()) ?? 0;
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: value / divideBy,
              width: 22,
              color: Resources.colors.buttonColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        );
      },
    );
  }

  double _getMaxY(List<dynamic> data, double divideBy) {
    if (data.isEmpty) return 10;
    final max = data
        .map((e) =>
    double.tryParse(e["totalAmount"].toString()) ?? 0)
        .reduce((a, b) => a > b ? a : b);
    return (max / divideBy) + 10;
  }

  // ======================= CHART =======================

  Widget _buildChart({
    required List<dynamic> data,
    required double divideBy,
    required String Function(int index) labelBuilder,
  }) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          "No Data",
          style: Resources.styles.kTextStyle14B(Colors.black),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1.2,
      child: RotatedBox(
        quarterTurns: 4,
        child: BarChart(
          BarChartData(
            maxY: _getMaxY(data, divideBy),
            minY: 0,
            alignment: BarChartAlignment.spaceBetween,
            groupsSpace: 18,
            barTouchData: BarTouchData(enabled: false),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(
              show: true,
              border: const Border(
                bottom: BorderSide(color: Colors.grey),
                left: BorderSide(color: Colors.grey),
              ),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  getTitlesWidget: (value, _) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '₹${value.toInt()}',
                      style: Resources.styles.kTextStyle12B(Colors.black),
                    ),
                  ),
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  getTitlesWidget: (value, _) {
                    final index = value.toInt();
                    if (index >= data.length) return const SizedBox();
                    return Text(
                      labelBuilder(index),
                      style:
                      Resources.styles.kTextStyle12B(Colors.black),
                    );
                  },
                ),
              ),
              topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            barGroups: _buildBarData(data, divideBy),
          ),
        ),
      ),
    );
  }

  // ======================= UI =======================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: Text(
          "My Performance",
          style: Resources.styles.kTextStyle16B(Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _tabButtons(size),
            const SizedBox(height: 20),
            Expanded(child: _currentChart()),
          ],
        ),
      ),
    );
  }

  Widget _tabButtons(Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        3,
            (index) => _tabCard(
          index,
          ["Daily", "Weekly", "Monthly"][index],
        ),
      ),
    );
  }

  Widget _tabCard(int index, String title) {
    final selected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Card(
          elevation: selected ? 6 : 2,
          color: selected
              ? Resources.colors.buttonColor
              : Resources.colors.whiteColor,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              children: [
                Icon(
                  Icons.calendar_month,
                  color: selected
                      ? Colors.white
                      : Resources.colors.blackColor,
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: Resources.styles.kTextStyle12B(
                    selected ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _currentChart() {
    switch (_selectedIndex) {
      case 0:
        return _buildChart(
          data: dailyPerformances,
          divideBy: 10,
          labelBuilder: (i) =>
              dailyPerformances[i]["_id"].toString().substring(8, 10),
        );
      case 1:
        return _buildChart(
          data: weeklyPerformances,
          divideBy: 50,
          labelBuilder: (i) =>
              weeklyPerformances[i]["_id"]["week"].toString(),
        );
      default:
        return _buildChart(
          data: monthlyPerformances,
          divideBy: 50,
          labelBuilder: (i) =>
              monthlyPerformances[i]["_id"]["month"].toString(),
        );
    }
  }
}
