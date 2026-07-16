import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'app_url.dart';

class AstroApiServices {
  // for ashtakoot Points (match making)
  var ashtkootData;
  Future<dynamic> getAshtkootReport(Map<String, dynamic> formData) async {
    String apiUrl = 'https://json.astrologyapi.com/v1/match_ashtakoot_points';
    Map<String, String> headers = {
      'x-astrologyapi-key': AppUrl.apiSecret,
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(formData),
      );

      if (response.statusCode == 200) {
        ashtkootData = jsonDecode(response.body);
        log('ashtkoot: $ashtkootData');
        return ashtkootData;
      } else {
        log('Error: ${response.statusCode}');
      }
    } catch (e) {
      log('Exception: $e');
    } finally {}
  }

  // for astro details in match making
  var astroDetails;
  Future<dynamic> getAstroDetails(Map<String, dynamic> formData) async {
    String apiUrl = 'https://json.astrologyapi.com/v1/match_astro_details';
    Map<String, String> headers = {
      'x-astrologyapi-key': AppUrl.apiSecret,
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(formData),
      );

      if (response.statusCode == 200) {
        astroDetails = jsonDecode(response.body);
        log('astroDetails: $astroDetails');
        return astroDetails;
      } else {
        log('Error: ${response.statusCode}');
      }
    } catch (e) {
      log('Exception: $e');
    } finally {}
  }

  // for planet details in match making
  var planetData;
  Future<dynamic> getPlanetDetails(Map<String, dynamic> formData) async {
    String apiUrl = 'https://json.astrologyapi.com/v1/match_planet_details';
    Map<String, String> headers = {
      'x-astrologyapi-key': AppUrl.apiSecret,
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(formData),
      );

      if (response.statusCode == 200) {
        planetData = jsonDecode(response.body);
        log('planetData: $planetData');
        return planetData;
      } else {
        log('Error: ${response.statusCode}');
      }
    } catch (e) {
      log('Exception: $e');
    } finally {}
  }

  // for Manglik Report
  var manglikReport;
  Future<dynamic> getManglikReport(Map<String, dynamic> formData) async {
    String apiUrl = 'https://json.astrologyapi.com/v1/match_manglik_report';
    Map<String, String> headers = {
      'x-astrologyapi-key': AppUrl.apiSecret,
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(formData),
      );

      if (response.statusCode == 200) {
        manglikReport = jsonDecode(response.body);
        log('manglikReport: $manglikReport');
        return manglikReport;
      } else {
        log('Error: ${response.statusCode}');
      }
    } catch (e) {
      log('Exception: $e');
    } finally {}
  }

  // for dashakoot Point
  var dashakootReport;
  Future<dynamic> getDashakootReport(Map<String, dynamic> formData) async {
    String apiUrl = 'https://json.astrologyapi.com/v1/match_dashakoot_points';
    Map<String, String> headers = {
      'x-astrologyapi-key': AppUrl.apiSecret,
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(formData),
      );

      if (response.statusCode == 200) {
        dashakootReport = jsonDecode(response.body);
        log('dashakootReport: $dashakootReport');
        return dashakootReport;
      } else {
        log('Error: ${response.statusCode}');
      }
    } catch (e) {
      log('Exception: $e');
    } finally {}
  }

  // for kundli (birth details)
  var kundliReport;
  Future<dynamic> getKundliReport(Map<String, dynamic> formData) async {
    await Future.delayed(
      const Duration(seconds: 1),
    ); // Add delay between requests
    String apiUrl = 'https://json.astrologyapi.com/v1/birth_details';
    Map<String, String> headers = {
      // 'x-astrologyapi-key':
      //     'Basic ${base64Encode(utf8.encode('${AppUrl.apiKey}:${AppUrl.apiSecret}'))}',
      'x-astrologyapi-key': AppUrl.apiSecret,
      'Content-Type': 'application/json',
    };
    log("urlApp:$apiUrl");
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(formData),
      );

      if (response.statusCode == 200) {
        kundliReport = jsonDecode(response.body);
        log('kundliReport: $kundliReport');
        return kundliReport;
      } else {
        log('Error: ${response.statusCode}');
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      log('Exception: $e');
      throw Exception('Failed to fetch Kundli report: $e');
    }
  }

  // for Astro details in kundli Match

  Future<dynamic> getKundliAstroReport(Map<String, dynamic> formData) async {
    String apiUrl = 'https://json.astrologyapi.com/v1/astro_details';
    Map<String, String> headers = {
      // 'x-astrologyapi-key':
      //     'Basic ${base64Encode(utf8.encode('${AppUrl.apiKey}:${AppUrl.apiSecret}'))}',
      'x-astrologyapi-key': AppUrl.apiSecret,
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(formData),
      );
      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');
      if (response.statusCode == 200) {
        // Decode the JSON response
        var data = jsonDecode(response.body);
        log('kundliAstroReport data: $data');
        return data;
      } else {
        log('Error: ${response.statusCode} - ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      log('Exception occurred: $e');
      return null;
    }
  }

  // for Api planet in kundli
  Future<dynamic> getKundliPlanetReport(Map<String, dynamic> formData) async {
    String apiUrl = 'https://json.astrologyapi.com/v1/planets';
    Map<String, String> headers = {
      // 'x-astrologyapi-key':
      //     'Basic ${base64Encode(utf8.encode('${AppUrl.apiKey}:${AppUrl.apiSecret}'))}',
      'x-astrologyapi-key': AppUrl.apiSecret,
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(formData),
      );
      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');
      if (response.statusCode == 200) {
        // Decode the JSON response
        var data = jsonDecode(response.body);
        log('kundliPlanetReport data: $data');
        return data;
      } else {
        log('Error: ${response.statusCode} - ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      log('Exception occurred: $e');
      return null;
    }
  }

  // for api Ayanamsha in kundli
  Future<dynamic> getAyanamshaPlanetReport(
    Map<String, dynamic> formData,
  ) async {
    String apiUrl = 'https://json.astrologyapi.com/v1/ayanamsha';
    Map<String, String> headers = {
      // 'x-astrologyapi-key':
      //     'Basic ${base64Encode(utf8.encode('${AppUrl.apiKey}:${AppUrl.apiSecret}'))}',
      'x-astrologyapi-key': AppUrl.apiSecret,
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(formData),
      );
      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');
      if (response.statusCode == 200) {
        // Decode the JSON response
        var data = jsonDecode(response.body);
        log('Ayanamsha: $data');
        return data;
      } else {
        log('Error: ${response.statusCode} - ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      log('Exception occurred: $e');
      return null;
    }
  }

  // for Api ghat_chakra in kundli
  Future<dynamic> getGhatChakraPlanetReport(
    Map<String, dynamic> formData,
  ) async {
    String apiUrl = 'https://json.astrologyapi.com/v1/ghat_chakra';
    Map<String, String> headers = {
      // 'x-astrologyapi-key':
      //     'Basic ${base64Encode(utf8.encode('${AppUrl.apiKey}:${AppUrl.apiSecret}'))}',
      'x-astrologyapi-key': AppUrl.apiSecret,
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(formData),
      );
      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');
      if (response.statusCode == 200) {
        // Decode the JSON response
        var data = jsonDecode(response.body);
        log('Ayanamsha: $data');
        return data;
      } else {
        log('Error: ${response.statusCode} - ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      log('Exception occurred: $e');
      return null;
    }
  }

  // for api match obstructions in matchmaking
  Future<dynamic> getMatchObstructionReport(
    Map<String, dynamic> formData,
  ) async {
    String apiUrl = 'https://json.astrologyapi.com/v1/match_obstructions';
    Map<String, String> headers = {
      // 'x-astrologyapi-key':
      //     'Basic ${base64Encode(utf8.encode('${AppUrl.apiKey}:${AppUrl.apiSecret}'))}',
      'x-astrologyapi-key': AppUrl.apiSecret,
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(formData),
      );
      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');
      if (response.statusCode == 200) {
        // Decode the JSON response
        var data = jsonDecode(response.body);
        log('Ayanamsha: $data');
        return data;
      } else {
        log('Error: ${response.statusCode} - ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      log('Exception occurred: $e');
      return null;
    }
  }

  // daily horoscope
  Future<dynamic> getDailyHoroscope(Map<String, dynamic> formData) async {
    String apiUrl =
        'https://json.astrologyapi.com/v1/daily_nakshatra_prediction';
    Map<String, String> headers = {
      // 'x-astrologyapi-key':
      //     'Basic ${base64Encode(utf8.encode('${AppUrl.apiKey}:${AppUrl.apiSecret}'))}',
      'x-astrologyapi-key': AppUrl.apiSecret,
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(formData),
      );
      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');
      if (response.statusCode == 200) {
        // Decode the JSON response
        var data = jsonDecode(response.body);
        log('daily horoscope: $data');
        return data;
      } else {
        log('Error: ${response.statusCode} - ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      log('Exception occurred: $e');
      return null;
    }
  }

  // next day  horoscope
  Future<dynamic> getNextHoroscope(Map<String, dynamic> formData) async {
    String apiUrl =
        'https://json.astrologyapi.com/v1/daily_nakshatra_prediction/next';
    Map<String, String> headers = {
      // 'x-astrologyapi-key':
      //     'Basic ${base64Encode(utf8.encode('${AppUrl.apiKey}:${AppUrl.apiSecret}'))}',
      'x-astrologyapi-key': AppUrl.apiSecret,
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(formData),
      );
      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');
      if (response.statusCode == 200) {
        // Decode the JSON response
        var data = jsonDecode(response.body);
        log('daily horoscope: $data');
        return data;
      } else {
        log('Error: ${response.statusCode} - ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      log('Exception occurred: $e');
      return null;
    }
  }

  // previous day  horoscope
  Future<dynamic> getPreviousHoroscope(Map<String, dynamic> formData) async {
    String apiUrl =
        'https://json.astrologyapi.com/v1/daily_nakshatra_prediction/previous';
    Map<String, String> headers = {
      // 'x-astrologyapi-key':
      //     'Basic ${base64Encode(utf8.encode('${AppUrl.apiKey}:${AppUrl.apiSecret}'))}',
      'x-astrologyapi-key': AppUrl.apiSecret,
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(formData),
      );
      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');
      if (response.statusCode == 200) {
        // Decode the JSON response
        var data = jsonDecode(response.body);
        log('daily horoscope: $data');
        return data;
      } else {
        log('Error: ${response.statusCode} - ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      log('Exception occurred: $e');
      return null;
    }
  }

  // for lagan
  Future<dynamic> getLagan(Map<String, dynamic> formData) async {
    String apiUrl = 'https://json.astrologyapi.com/v1/horo_chart_image/D1';
    Map<String, String> headers = {
      // 'x-astrologyapi-key':
      //     'Basic ${base64Encode(utf8.encode('${AppUrl.apiKey}:${AppUrl.apiSecret}'))}',
      'x-astrologyapi-key': AppUrl.apiSecret,
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(formData),
      );
      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');
      if (response.statusCode == 200) {
        // Decode the JSON response
        var data = jsonDecode(response.body);
        log('daily horoscope: $data');
        return data;
      } else {
        log('Error: ${response.statusCode} - ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      log('Exception occurred: $e');
      return null;
    }
  }

  // for d2
  Future<dynamic> getNavamansha(Map<String, dynamic> formData) async {
    String apiUrl = 'https://json.astrologyapi.com/v1/horo_chart_image/D9';
    Map<String, String> headers = {
      // 'x-astrologyapi-key':
      //     'Basic ${base64Encode(utf8.encode('${AppUrl.apiKey}:${AppUrl.apiSecret}'))}',
      'x-astrologyapi-key': AppUrl.apiSecret,
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(formData),
      );
      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');
      if (response.statusCode == 200) {
        // Decode the JSON response
        var data = jsonDecode(response.body);
        log('daily horoscope: $data');
        return data;
      } else {
        log('Error: ${response.statusCode} - ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      log('Exception occurred: $e');
      return null;
    }
  }

  // for moon
  Future<dynamic> getMoon(Map<String, dynamic> formData) async {
    String apiUrl = 'https://json.astrologyapi.com/v1/horo_chart_image/moon';
    Map<String, String> headers = {
      // 'x-astrologyapi-key':
      //     'Basic ${base64Encode(utf8.encode('${AppUrl.apiKey}:${AppUrl.apiSecret}'))}',
      'x-astrologyapi-key': AppUrl.apiSecret,
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(formData),
      );
      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');
      if (response.statusCode == 200) {
        // Decode the JSON response
        var data = jsonDecode(response.body);
        log('daily horoscope: $data');
        return data;
      } else {
        log('Error: ${response.statusCode} - ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      log('Exception occurred: $e');
      return null;
    }
  }

  // for Sun
  Future<dynamic> getSun(Map<String, dynamic> formData) async {
    String apiUrl = 'https://json.astrologyapi.com/v1/horo_chart_image/sun';
    Map<String, String> headers = {
      // 'x-astrologyapi-key':
      //     'Basic ${base64Encode(utf8.encode('${AppUrl.apiKey}:${AppUrl.apiSecret}'))}',
      'x-astrologyapi-key': AppUrl.apiSecret,
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(formData),
      );
      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');
      if (response.statusCode == 200) {
        // Decode the JSON response
        var data = jsonDecode(response.body);
        log('maha dasha: $data');
        return data;
      } else {
        log('Error: ${response.statusCode} - ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      log('Exception occurred: $e');
      return null;
    }
  }

  // maha dasha api
  Future<dynamic> getMahaDasha(Map<String, dynamic> formData) async {
    String apiUrl = 'https://json.astrologyapi.com/v1/major_vdasha';
    Map<String, String> headers = {
      // 'x-astrologyapi-key':
      //     'Basic ${base64Encode(utf8.encode('${AppUrl.apiKey}:${AppUrl.apiSecret}'))}',
      'x-astrologyapi-key': AppUrl.apiSecret,
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(formData),
      );
      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');
      if (response.statusCode == 200) {
        // Decode the JSON response
        var data = jsonDecode(response.body);
        log('daily horoscope: $data');
        return data;
      } else {
        log('Error: ${response.statusCode} - ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      log('Exception occurred: $e');
      return null;
    }
  }

  // current mha dasha
  Future<dynamic> currentDasha(Map<String, dynamic> formData) async {
    String apiUrl = 'https://json.astrologyapi.com/v1/current_vdasha_all';

    log("url current dasha : $apiUrl");

    Map<String, String> headers = {
      // 'x-astrologyapi-key':
      //     'Basic ${base64Encode(utf8.encode('${AppUrl.apiKey}:${AppUrl.apiSecret}'))}',
      'x-astrologyapi-key': AppUrl.apiSecret,
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(formData),
      );
      log("response.body:${response}");
      log("response.statusCode:${response.statusCode}");
      log("response.body:${response.body}");
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        log('current dasha: $data');
        // Return only major dasha list
        return data["major"]["dasha_period"];
      } else {
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
}
