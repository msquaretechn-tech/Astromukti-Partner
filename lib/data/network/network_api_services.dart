import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:astro_mukti/resources/resources.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import '../../main.dart';
import '../../routes/routes_name.dart';
import '../app_excpation.dart';
import '../local/pref_service.dart';
import 'base_api_service.dart';
import 'package:http/http.dart' as http;

class NetworkApiServices extends BaseApiServices {
  /// Get data from the server ///
  @override
  Future getApiResponse(String url) async {
    dynamic responseJson;
    try {
      var token = PrefService().getToken();
      log("Url : $url");
      log("token :$token");
      print("Url : $url");
      print("token :$token");
      final response = await http
          .get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'});
      responseJson = returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
    return responseJson;
  }

  /// Post Data from the server ///
  @override
  Future postApiResponse(String url, Map<String, dynamic> mData) async {
    dynamic responseJson;
    try {
      log("Url : $url");
      var token = PrefService().getToken();
      log("mData : $mData");

      Response response = await http.post(Uri.parse(url),
          body: mData, headers: {'Authorization': 'Bearer $token'});

      log("Response body : ${response.body}");
      responseJson = returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
    return responseJson;
  }

  /// data patch///
  /// Future<dynamic> patchApiResponse(String url, Map<String, dynamic> data) async {
  Future<dynamic> patchApiResponse(
      String url, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse(url),
      body: jsonEncode(data),
      headers: {
        'Content-Type': 'application/json',
        // Add any authorization headers if needed:
        // 'Authorization': 'Bearer YOUR_TOKEN',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to patch data: ${response.body}');
    }
  }

  /// Delete data from the server ///
  @override
  Future<void> deleteApiResponse(String url, dynamic data) async {
    dynamic responseJson;
    try {
      var token = PrefService().getToken();
      log("Url : $url");
      log("mData : $data");
      Response response = await delete(Uri.parse(url), body: data, headers: {
        'Authorization': 'Bearer $token',
      });
      log("response : ${returnResponse(response)}");
      responseJson = returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
    return responseJson;
  }

  /// Post Data with image  from the server ///
  @override
  Future filePostApiResponseWithImage(String url, method,
      Map<String, dynamic> formData, List<MultipartFile> file) async {
    try {
      final request = http.MultipartRequest(
        method,
        Uri.parse(url),
      );

      log("URL  : $url");
      log("method : $method");
      log("formData : $formData");
      // log("formData : $files");
      var token = PrefService().getToken();
      request.headers.addAll({
        'Authorization': 'Bearer $token', // Replace with your actual token
        'Content-Type': 'multipart/form-data',
      });

      // Add form fields
      formData.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Add image files
      if (file.isNotEmpty) {
        for (var f in file) {
          log("Image Url: $f");
          request.files.add(f);
        }
      }

      log('request.fields :${request.fields}');
      log('request.files :${request.files}');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      log("response :$response");
      log("response body :${response.body}");

      log("res registration data : ${jsonDecode(response.body)}");

      return returnResponse(response);
    } catch (e) {
      if (kDebugMode) {
        print("Error : ${e.runtimeType}");
      }
    }
  }

  // dynamic returnResponse(http.Response response) {
  //   switch (response.statusCode) {
  //     case 200:
  //       dynamic responseJson = jsonDecode(response.body);
  //       return responseJson;
  //     case 201:
  //       dynamic responseJson = jsonDecode(response.body);
  //       return responseJson;
  //     case 400:
  //       throw BadRequestException(response.body.toString());
  //     case 404:
  //       throw UnauthorisedException(response.body.toString());
  //     default:
  //       throw FetchDataException(
  //           'Error Accrued While communication with server with status code ${response.statusCode}');
  //   }
  // }
  dynamic returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson;
      case 201:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson;
      case 400:
        dynamic errorJson = jsonDecode(response.body);
        Fluttertoast.showToast(msg: errorJson['message']);
        throw BadRequestException(errorJson['message']);
      case 404:
        dynamic errorJson = jsonDecode(response.body);
        Fluttertoast.showToast(msg: errorJson['message']);
        throw UnauthorisedException(response.body.toString());
      case 401:
        dynamic errorJson = jsonDecode(response.body);
        Fluttertoast.showToast(msg: errorJson['message']);
        PrefService.clear();
        GoRouter.of(navigationKey.currentContext!)
            .pushReplacement(RoutesName.loginScreen);
        throw UnauthorisedException(response.body.toString());
      case 403:
        dynamic errorJson = jsonDecode(response.body);
        Fluttertoast.showToast
          (msg: errorJson['message'],
          backgroundColor: Colors.red
        );
        throw UnauthorisedException(response.body.toString());
      case 409:
        dynamic errorJson = jsonDecode(response.body);
        Fluttertoast.showToast
          (msg: errorJson['message'],
            backgroundColor: Colors.red
        );
        throw UnauthorisedException(response.body.toString());
      default:
        Fluttertoast.showToast(
            msg:
                'Error Occurred While communication with server with status code ${response.statusCode}');
        throw FetchDataException(
            'Error Occurred While communication with server with status code ${response.statusCode}');
    }
  }
}
