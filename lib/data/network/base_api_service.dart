import 'package:http/http.dart'as http;

abstract class BaseApiServices {
  Future<dynamic> getApiResponse(String url);

  Future<dynamic> postApiResponse(String url, Map<String, dynamic> mData);
  Future<dynamic> patchApiResponse(String url, Map<String, dynamic> mData);

  Future<dynamic> deleteApiResponse(String url, Map<String, dynamic> map);

  Future<dynamic> filePostApiResponseWithImage(String url, dynamic data,
      Map<String, dynamic> formData, List<http.MultipartFile> file);

}
