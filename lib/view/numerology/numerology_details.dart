import 'dart:convert';
import 'dart:developer';

import 'package:astro_mukti/view/widgets/appbar_profile.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../resources/app_url.dart';
import '../../resources/resources.dart';
import 'numerology_list.dart';

class NumerologyDetails extends StatefulWidget {
  final Map<String, dynamic> data;
  const NumerologyDetails({super.key, required this.data});

  @override
  State<NumerologyDetails> createState() => _NumerologyDetailsState();
}

class _NumerologyDetailsState extends State<NumerologyDetails> {
  final _dobController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
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

  Future<void> getMatchBirthDetails() async {
    setState(() {
      _isLoading = true;
    });

    String apiUrl = 'https://json.astrologyapi.com/v1/numero_table';
    Map<String, dynamic> requestBody = {
      "day": int.parse(_dobController.text.split('/')[0]),
      "month": int.parse(_dobController.text.split('/')[1]),
      "year": int.parse(_dobController.text.split('/')[2]),
      "name": _nameController.text,
    };

    Map<String, String> headers = {
      'Authorization':
          'Basic ${base64Encode(utf8.encode('${AppUrl.apiKey}:${AppUrl.apiSecret}'))}',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        log('response: $responseData');

        // Navigate to NumerologyList page with the response data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NumerologyList(responseData: responseData),
          ),
        );
      } else {
        log('Error: ${response.statusCode}');
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      log('Exception: $e');
      var snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          'An error occurred: $e',
          style: Resources.styles.kTextStyle12B(Colors.white),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _submitDetails() {
    if (_nameController.text.isEmpty || _dobController.text.isEmpty) {
      var snackBar = SnackBar(
        backgroundColor: Colors.white,
        content: Text(
          'All Field are required',
          style: Resources.styles.kTextStyle12B(Colors.black),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      getMatchBirthDetails();
    }
  }

  @override
  void initState() {
    _nameController.text = widget.data['name'] ?? '';
    _dobController.text = widget.data['dob'] ?? '';
    super.initState();
  }

  @override
  void dispose() {
    _dobController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarProfile(userName: 'Numerology'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailsSection(_nameController, _dobController),
                SizedBox(height: 20,),
                // GestureDetector(
                //   onTap: _isLoading ? null : _submitDetails, // Disable button if loading
                //   child: Container(
                //     margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                //     height: 50,
                //     width: double.infinity,
                //     decoration: BoxDecoration(
                //       color: _isLoading
                //           ? Colors.grey
                //           : Resources.colors.themeColor, // Change color if loading
                //       borderRadius: BorderRadius.circular(10),
                //     ),
                //     child: Center(
                //       child: _isLoading
                //           ? CircularProgressIndicator(
                //         color: Resources.colors.themeColor,
                //       ) // Show loader
                //           : const Text(
                //         'Submit',
                //         style: TextStyle(
                //           color: Colors.white,
                //           fontSize: 16,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
            GestureDetector(
              onTap: _isLoading ? null : _submitDetails,
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
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                        "Submit",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
    TextEditingController nameController,
    TextEditingController dobController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            hintText: 'Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => _selectDate(context, dobController),
          child: AbsorbPointer(
            child: TextFormField(
              controller: dobController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                hintText: 'DOB',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
