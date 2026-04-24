import 'dart:convert';
import 'dart:developer';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:astro_mukti/view/widgets/appbar_profile.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../resources/app_url.dart';
import '../../resources/astro_api_services.dart';
import '../../resources/resources.dart';
import '../../routes/routes_name.dart';

class ZodiacSign extends StatefulWidget {
  const ZodiacSign(
      {Key? key,
      required this.dob,
      required this.dot,
      required this.dop,
      required this.name,
      required this.gender,
      required this.latitude,
      required this.longitude})
      : super(key: key);
  final String dob;
  final String dot;
  final String dop;
  final String name;
  final String gender;
  final double latitude;
  final double longitude;
  @override
  State<ZodiacSign> createState() => _ZodiacSignState();
}

class _ZodiacSignState extends State<ZodiacSign> {
  final _dobController = TextEditingController();
  final _timeController = TextEditingController();
  final _nameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

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

  String? lat;
  String? lon;
  String? _selectedCity;
  // get All City
  List<Map<String, dynamic>> _citySuggestions = [];
  Future<void> getAllCity(String allCity) async {
    String url = "https://json.astrologyapi.com/v1/geo_details";
    Map<String, dynamic> requestBody = {"place": allCity, "maxRows": 7};
    Map<String, String> headers = {
      'Authorization':
          'Basic ${base64Encode(utf8.encode('${AppUrl.apiKey}:${AppUrl.apiSecret}'))}',
      'Content-Type': 'application/json'
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

        lat = responseData["geonames"].isNotEmpty
            ? responseData["geonames"][0]['latitude']
            : null;
        lon = responseData["geonames"].isNotEmpty
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

  String? _selectGender;
  final List<String> _gender = [
    'Male',
    'Female',
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name;
    _selectGender = widget.gender;
    _dobController.text = widget.dob;
    _timeController.text = widget.dot;
    _cityController.text = widget.dop;
    lat = widget.latitude.toString();
    lon = widget.longitude.toString();
    log("lat:$lat log : $lon");
    // _selectGender = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarProfile(
        userName:
          "Kundli",

      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
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
                DropdownButtonFormField<String>(
                  value:
                      _selectGender != null && _gender.contains(_selectGender)
                          ? _selectGender
                          : null,
                  onChanged: (newValue) {
                    setState(() {
                      _selectGender = newValue;
                    });
                  },
                  items: _gender.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'Select gender',
                    hintStyle: const TextStyle(color: Colors.grey),
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
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _dobController,
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              fillColor: Colors.white,
                              filled: true,
                              hintText: 'Date of Birth',
                              hintStyle:
                                  Resources.styles.kTextStyle14B5(Colors.grey),
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
                        onTap: () => _selectTime(context, _timeController),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _timeController,
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              fillColor: Colors.white,
                              filled: true,
                              hintText: 'Time of Birth',
                              hintStyle:
                                  Resources.styles.kTextStyle14B5(Colors.grey),
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
                  controller: _cityController,
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
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 15),
                      child: Text(
                        "${suggestion["place_name"]}, ${suggestion["country_code"]}",
                        style: Resources.styles.kTextStyle12B(Colors.black),
                      ),
                    );
                  },
                  onSelected: (suggestion) {
                    setState(() {
                      log("suggestion: $suggestion");
                      _selectedCity =
                          "${suggestion["place_name"]} ${suggestion["country_code"]}";
                      _cityController.text =
                          "${suggestion["place_name"]} ${suggestion["country_code"]}";
                      lat = suggestion["latitude"];
                      lon = suggestion["longitude"];
                    });
                  },
                  showOnFocus: true,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    List<String> dob = _dobController.text.split('/');
                    List<String> time = _timeController.text.split(':');

                    if (_nameController.text.isEmpty ||
                        _selectGender!.isEmpty ||
                        _dobController.text.isEmpty ||
                        _timeController.text.isEmpty) {
                      var snackBar = SnackBar(
                          backgroundColor: Colors.white,
                          content: Text(
                            'All fields are required',
                            style: Resources.styles.kTextStyle12B(Colors.black),
                          ));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    } else {
                      EasyLoading.show(
                          status: 'loading...',
                          dismissOnTap: false,
                          maskType: EasyLoadingMaskType.clear);
                      try {
                        // Await the API call
                        var birthDetails =
                            await AstroApiServices().getKundliReport({
                          "day": int.parse(dob[0]),
                          "month": int.parse(dob[1]),
                          "year": int.parse(dob[2]),
                          "hour": int.parse(time[0]),
                          "min": int.parse(time[1]),
                          "lat": lat,
                          "lon": lon,
                          "tzone": 5.5
                        });
                        log("birthDetails: $birthDetails");
                        GoRouter.of(context)
                            .pushNamed(RoutesName.kundliDetails, extra: {
                          "inputData": {
                            "day": int.parse(dob[0]),
                            "month": int.parse(dob[1]),
                            "year": int.parse(dob[2]),
                            "hour": int.parse(time[0]),
                            "min": int.parse(time[1]),
                            "lat": lat,
                            "lon": lon,
                            "tzone": 5.5
                          },
                          "birthDetails": birthDetails
                        });
                      } catch (e) {
                        log("Error fetching Kundli data: $e");
                        var snackBar = SnackBar(
                            backgroundColor: Colors.white,
                            content: Text(
                              'Failed to fetch Kundli data',
                              style:
                                  Resources.styles.kTextStyle12B(Colors.black),
                            ));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } finally {
                        EasyLoading.dismiss();
                      }
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    height: 55,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40), // pill shape
                      gradient: LinearGradient(
                        colors: [
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
                      child: Text(
                        'Submit',
                        style: Resources.styles.kTextStyle14B(Colors.black),
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
}
