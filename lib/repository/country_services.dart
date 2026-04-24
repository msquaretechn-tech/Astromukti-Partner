import 'dart:developer';

import 'package:http/http.dart' as http;

import '../model/city_model.dart';
import '../model/country_model.dart';

class CountryStateCityServices {
  static const countriesStateURL =
      'https://countriesnow.space/api/v0.1/countries/states';
  static const cityURL =
      'https://countriesnow.space/api/v0.1/countries/state/cities';
  // Fetch country and state data
  Future<CountryStateModel> getCountriesStates() async {
    try {
      var url = Uri.parse(countriesStateURL);
      var response = await http.get(url);
      if (response.statusCode == 200) {
        final CountryStateModel responseModel =
            countryStateModelFromJson(response.body);
        return responseModel;
      } else {
        return CountryStateModel(
            error: true,
            msg: 'Something went wrong: ${response.statusCode}',
            data: []);
      }
    } catch (e) {
      log('Exception: ${e.toString()}');
      throw Exception(e.toString());
    }
  }

  // Fetch cities for a selected country and state
  Future<CitiesModel> getCities({
    required String country,
    required String state,
  }) async {
    try {
      var url = Uri.parse(
          "https://countriesnow.space/api/v0.1/countries/state/cities/q?country=$country&state=$state");
      var response = await http.get(url);
      if (response.statusCode == 200) {
        final CitiesModel responseModel = citiesModelFromJson(response.body);
        log("API Response: ${response.body}");
        log("Response Cities: ${responseModel.data}");
        return responseModel;
      } else {
        return CitiesModel(
            error: true,
            msg: 'Something went wrong: ${response.statusCode}',
            data: []);
      }
    } catch (e) {
      log('Exception: ${e.toString()}');
      throw Exception(e.toString());
    }
  }
}
