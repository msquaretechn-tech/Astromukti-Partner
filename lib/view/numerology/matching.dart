import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:astro_mukti/view/numerology/zodiac_details.dart';
import 'package:astro_mukti/view/widgets/appbar_profile.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../resources/app_url.dart';
import '../../resources/resources.dart';

class Matching extends StatefulWidget {
  const Matching({Key? key}) : super(key: key);

  @override
  State<Matching> createState() => _MatchingState();
}

class _MatchingState extends State<Matching> {
  bool _isLoading = false;

  // Api services for match making boy and girl
  String? boyLat;
  String? boyLon;
  String? girlLat;
  String? girlLon;

  Future<void> getMatchMaking() async {
    String apiUrl = 'https://json.astrologyapi.com/v1/match_birth_details';
    setState(() {
      _isLoading = true;
    });

    List<String> boyDob = _boyDobController.text.split('/');
    List<String> boyTime = _boyTimeController.text.split(':');
    List<String> girlDob = _girlDobController.text.split('/');
    List<String> girlTime = _girlTimeController.text.split(':');

    Map<String, dynamic> requestBody = {
      "m_day": int.parse(boyDob[0]),
      "m_month": int.parse(boyDob[1]),
      "m_year": int.parse(boyDob[2]),
      "m_hour": int.parse(boyTime[0]),
      "m_min": int.parse(boyTime[1]),
      "m_lat": boyLat,
      "m_lon": boyLon,
      "m_tzone": 5.5,
      "f_day": int.parse(girlDob[0]),
      "f_month": int.parse(girlDob[1]),
      "f_year": int.parse(girlDob[2]),
      "f_hour": int.parse(girlTime[0]),
      "f_min": int.parse(girlTime[1]),
      "f_lat": girlLat,
      "f_lon": girlLon,
      "f_tzone": 5.5
    };

    Map<String, String> headers = {
      'x-astrologyapi-key': AppUrl.apiSecret,
      'Content-Type': 'application/json',
    };

    try {
      await http
          .post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(requestBody),
      )
          .then((response) {
        setState(() {
          _isLoading = false;
        });
        log('Match Birth');
        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);
          log('Match Birth Details: $responseData');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ZodiacDetails(data: responseData),
            ),
          );
        } else {
          log('Error: ${response.statusCode}');
          Fluttertoast.showToast(msg: "Error occurred: ${response.statusCode}");
        }
      });
    } catch (e) {
      log('Exception: $e');
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(msg: "Exception occurred: $e");
    }
  }

  // on submit button
  void _submitDetails() {
    log("is working:${_boyNameController.text}");
    log("is working:${_boyDobController.text}");
    log("is working:${_boyTimeController.text}");
    log("is city:${_boyCityController.text}");
    log("is working:${_girlNameController.text}");
    log("is working:${_girlDobController.text}");
    log("is working:${_girlTimeController.text}");
    log("is City:${_girlCityController.text}");
    if (_boyNameController.text.isEmpty ||
        _boyDobController.text.isEmpty ||
        _boyTimeController.text.isEmpty ||
        _boyCityController.text.isEmpty ||
        _girlNameController.text.isEmpty ||
        _girlDobController.text.isEmpty ||
        _girlTimeController.text.isEmpty ||
        _girlCityController.text.isEmpty) {
      var snackBar = SnackBar(
          backgroundColor: Colors.white,
          content: Text(
            'All Field are required',
            style: Resources.styles.kTextStyle12B(Colors.black),
          ));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      getMatchMaking();
    }
  }

  // Controllers for Boy's details
  final _boyDobController = TextEditingController();
  final _boyTimeController = TextEditingController();
  final _boyCityController = TextEditingController();
  final _boyNameController = TextEditingController();
  // Controllers for girl's details
  final _girlDobController = TextEditingController();
  final _girlTimeController = TextEditingController();
  final _girlCityController = TextEditingController();
  final _girlNameController = TextEditingController();

  // get the  city data from the api
  String? _selectedCity;
  List<Map<String, dynamic>> _citySuggestions = [];

  Future<void> getAllCity(String allCity) async {
    String url = "https://json.astrologyapi.com/v1/geo_details";
    Map<String, dynamic> requestBody = {"place": allCity, "maxRows": 7};
    Map<String, String> headers = {
      'x-astrologyapi-key': AppUrl.apiSecret,
      'Content-Type': 'application/json',
    };
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      log("response:${response.body}");

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        log('get city Details: $responseData');
        _citySuggestions = List<Map<String, dynamic>>.from(
            responseData["geonames"].map((city) => city));
        // _citySuggestions = List<Map<String, dynamic>>.from(
        //     responseData["geonames"]
        //         .where((city) => city["country_code"] == "IN")
        //         .map((city) => city));
        boyLat = responseData["geonames"].isNotEmpty
            ? responseData["geonames"][0]['latitude']
            : null;
        boyLon = responseData["geonames"].isNotEmpty
            ? responseData["geonames"][0]['longitude']
            : null;
        girlLat = responseData["geonames"].isNotEmpty
            ? responseData["geonames"][0]['latitude']
            : null;
        girlLon = responseData["geonames"].isNotEmpty
            ? responseData["geonames"][0]['longitude']
            : null;

        log("suggestion11:$_citySuggestions");
      } else {
        log('Error: ${response.statusCode}');
      }
    } catch (e) {
      log('Exception: $e');
      _citySuggestions = [];
    }
  }

  Future<List<Map<String, dynamic>>> _getCitySuggestions(String pattern) async {
    await getAllCity(pattern);
    return _citySuggestions;
  }

  // function for date picker
  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // function for time selecting

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final now = DateTime.now();
      final selectedTime =
          DateTime(now.year, now.month, now.day, picked.hour, picked.minute);

      final timeFormatted = DateFormat('HH:mm').format(selectedTime);

      setState(() {
        controller.text = timeFormatted;
      });
    }
  }

  @override
  void dispose() {
    _boyDobController.dispose();
    _boyTimeController.dispose();
    _boyCityController.dispose();
    _girlDobController.dispose();
    _girlTimeController.dispose();
    _girlCityController.dispose();
    _girlNameController.dispose();
    _boyNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarProfile(userName: "Match Making"),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailsSection(
                  "Boy's Details",
                  _boyNameController,
                  _boyDobController,
                  _boyTimeController,
                  _boyCityController,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                _buildDetailsSection(
                  "Girl's Details",
                  _girlNameController,
                  _girlDobController,
                  _girlTimeController,
                  _girlCityController,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * .05),
                GestureDetector(
                  onTap: () {
                    _isLoading ? null : _submitDetails();
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    height: 55,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40), // pill shape
                      gradient: LinearGradient(
                        colors: _isLoading
                            ? [Colors.grey.shade400, Colors.grey.shade500]
                            : [
                          Color(0xFFF9E076),
                          Color(0xFFD4AF37),
                          Color(0xFFF9E076),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                      border: Border.all(color: Colors.white70, width: 1.5),
                    ),
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.yellowAccent)
                          : Text(
                        'Submit',
                        style: Resources.styles.kTextStyle16B(Colors.black),
                        textAlign: TextAlign.center,
                      ),
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

  Widget _buildDetailsSection(
    String title,
    TextEditingController nameController,
    TextEditingController dobController,
    TextEditingController timeController,
    TextEditingController cityController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          child: Text(
            title,
            style: Resources.styles.kTextStyle16B(Resources.colors.blackColor),
          ),
        ),
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            fillColor: Colors.white,
            filled: true,
            hintText: 'Name',
            hintStyle: Resources.styles.kTextStyle14B5(Colors.grey),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(width: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(width: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _selectDate(context, dobController),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: dobController,
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                      fillColor: Colors.white,
                      filled: true,
                      hintText: 'Date of Birth',
                      hintStyle: Resources.styles.kTextStyle14B5(Colors.grey),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(width: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(width: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => _selectTime(context, timeController),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: timeController,
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                      fillColor: Colors.white,
                      filled: true,
                      hintText: 'Time of Birth',
                      hintStyle: Resources.styles.kTextStyle14B5(Colors.grey),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(width: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(width: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TypeAheadField(
          controller: cityController,
          suggestionsCallback: (pattern) async {
            return await _getCitySuggestions(pattern);
          },
          builder: (context, controller, focusNode) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              autofocus: false,
              cursorColor: Resources.colors.buttonColor,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                fillColor: Colors.white,
                filled: true,
                hintText: 'Birth City',
                hintStyle: Resources.styles.kTextStyle14B5(Colors.grey),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(width: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(width: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
          itemBuilder: (context, Map<String, dynamic> suggestion) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
              child: Text(
                  "${suggestion["place_name"]}, ${suggestion["country_code"]}",
                style: Resources.styles.kTextStyle12B(Colors.black),
              ),
            );
          },
          onSelected: (suggestion) {
            setState(() {
              log("suggestion: $suggestion");
              _selectedCity =  "${suggestion["place_name"]} ${suggestion["country_code"]}";
              cityController.text =  "${suggestion["place_name"]} ${suggestion["country_code"]}";
            //  cityController.text =  "${suggestion["place_name"]} ${suggestion["country_code"]}";
              boyLat = suggestion["latitude"];
              boyLon = suggestion["longitude"];
              girlLat = suggestion["latitude"];
              girlLon = suggestion["longitude"];
            });
          },
          showOnFocus: true,
        )
      ],
    );
  }
}
