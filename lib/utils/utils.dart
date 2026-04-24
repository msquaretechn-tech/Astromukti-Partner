import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../resources/resources.dart';

import 'package:in_app_update/in_app_update.dart';

class Utils {
  static void fieldFocusChange(
      BuildContext context, FocusNode current, FocusNode nextFocus) {
    current.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  static snackBar(String message, BuildContext context) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.white,
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: Resources.styles.kTextStyle12B(Resources.colors.blackColor),
        )));
  }

  static const appId = '7e6606da1a924439acfde3318c446154';

  static String formatMongoDate(String mongoTimeString) {
    // DateTime mongoDateTime = DateTime.parse(mongoTimeString).toLocal(); // Convert UTC to local time
    DateTime mongoDateTime =
        DateTime.parse(mongoTimeString); // Convert UTC to local time

    // Format the date and time using the desired format
    // String formattedDateTime = DateFormat('dd-MM-yyyy', 'en_IN').format(mongoDateTime);
    String formattedDateTime = DateFormat(
      'dd-MM-yyyy',
    ).format(mongoDateTime);

    return formattedDateTime;
  }

  static String formatMongoTime(String mongoTimeString) {
    // DateTime mongoDateTime = DateTime.parse(mongoTimeString).toLocal(); // Convert UTC to local time

    DateTime mongoDateTime = DateTime.parse(mongoTimeString).toLocal();

    String formattedDateTime = DateFormat('hh:mm a').format(mongoDateTime);

    return formattedDateTime;
  }

  // format call timer duration
  static String formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  static String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "";

    try {
      // Parse the date string
      DateTime parsedDate =
          DateFormat("EEE MMM dd yyyy HH:mm:ss 'GMT'Z (zzz)").parse(dateString);

      // Format it to the desired format
      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } catch (e) {
      // Handle parsing error
      print("Invalid date format: $e");
      return "";
    }
  }

  // for the chat timer

  static int incrementMinutes(String time) {
    List<String> parts = time.split(':');
    int minutes = int.parse(parts[0]);
    int seconds = int.parse(parts[1]);

    if (seconds == 59) {
      minutes++;
    }

    return minutes;
  }

  // Function to format the string into valid JSON
// Function to format the string into valid JSON
  String formatToJson(String input) {
    // Remove curly braces
    input = input.replaceAll(RegExp(r'[{}]'), '');

    // Replace key: value with "key": "value"
    input = input.replaceAllMapped(RegExp(r'(\w+):'), (match) {
      return '"${match.group(1)}":';
    });

    // Handle values with commas inside (such as "01/01/2017,13:57")
    input = input.replaceAllMapped(RegExp(r'(\d{2}/\d{2}/\d{4},\d{2}:\d{2})'),
        (match) {
      return '"${match.group(0)}"';
    });

// Handle booleans and numbers (true, false, and integers/floats)
    input =
        input.replaceAllMapped(RegExp(r'(true|false|\d+\.\d+|\d+)'), (match) {
      return match.group(0)!;
    });

// Handle values with periods like file paths (e.g., "avatar-1740733580675-315192463.png")
    input = input.replaceAllMapped(RegExp(r'(\w+\.[a-zA-Z]+)'), (match) {
      return '"${match.group(0)}"';
    });

    // Return the formatted string wrapped in curly braces
    return '{$input}';
  }


  void checkForUpdates() {
    InAppUpdate.checkForUpdate().then((updateInfo) {
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (updateInfo.immediateUpdateAllowed) {
          // Perform immediate update
          InAppUpdate.performImmediateUpdate().then((appUpdateResult) {
            if (appUpdateResult == AppUpdateResult.success) {
              // App Update successful
            }
          }).catchError((e) {
            // Handle any errors that occur during the immediate update
            print("Immediate update failed: $e");
          });
        } else if (updateInfo.flexibleUpdateAllowed) {
          // Perform flexible update
          InAppUpdate.startFlexibleUpdate().then((appUpdateResult) {
            if (appUpdateResult == AppUpdateResult.success) {
              // App Update successful
              InAppUpdate.completeFlexibleUpdate().then((result) {
                // Handle the result of the completion
              }).catchError((e) {
                // Handle any errors that occur during completion
                print("Flexible update completion failed: $e");
              });
            }
          }).catchError((e) {
            // Handle any errors that occur during the flexible update
            print("Flexible update failed: $e");
          });
        }else{

        }
      }
    }).catchError((e) {
      // Handle any errors that occur during the update check
      print("Check for update failed: $e");
    });
  }




  String formatDates(String isoDate) {
    final dateTime = DateTime.parse(isoDate).toLocal();
    return DateFormat('hh:mm a dd/MM/yyyy').format(dateTime);
  }


}
