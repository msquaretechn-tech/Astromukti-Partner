import 'dart:convert';
import 'dart:developer';

import 'package:astro_mukti/model/payout_model.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:astro_mukti/model/stats_model.dart';

import 'package:http/http.dart';
import 'package:http/http.dart' as http;

import '../data/local/pref_service.dart';
import '../data/network/base_api_service.dart';
import '../data/network/network_api_services.dart';
import '../model/blocked_model.dart';
import '../model/booking_model.dart';
import '../model/call_waiting_model.dart';
import '../model/follow_model.dart';
import '../model/get_vendor.dart';
import '../model/login_history_model.dart';
import '../model/my_earning_model.dart';
import '../model/payment_detail_model.dart';
import '../model/rating_model.dart';
import '../model/report_model.dart';
import '../model/traning_video_model.dart';
import '../model/transaction_earning_model.dart';
import '../model/user_detail_model.dart';
import '../model/vender_detail_model.dart';
import '../model/vendor_blog_detail_model.dart';
import '../model/vendor_call_detail_model.dart';
import '../resources/app_url.dart';
import '../resources/string.dart';

class Repository {
  final BaseApiServices _apiServices = NetworkApiServices();
  final _prefService = PrefService();

  // Send SMS
  // Future<dynamic> sendSMS(String mobile, String otp) async {
  //   Fluttertoast.showToast(msg: "otp is $otp", toastLength: Toast.LENGTH_LONG);
  //   try {
  //     dynamic response = await _apiServices.postApiResponse(
  //       'https://bookmyastro.co.in/send-otp.php?phone=$mobile&otp=$otp',);
  //     log("response :$response");
  //     return response;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }
  Future<dynamic> sendSMS(String mobile, String otp) async {
    try {
      dynamic response = await _apiServices.postApiResponse(
        'https://www.astromukti.com/sms/send-otp.php',
        {'mobile': mobile, 'otp': otp},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  //generate Otp
  Future<dynamic> generateOtpApi(Map<String, dynamic> data) async {
    print('1111111111111111 $data');
    try {
      dynamic response = await _apiServices.postApiResponse(
        AppUrl.generateOtpUrl,
        data,
      );

      log("res generateOtp: $response");

      return response;
    } catch (e) {
      log("auth error generateOtp:$e}");
      rethrow;
    }
  }

  Future<dynamic> getTotalChats() async {
    try {
      dynamic response = await _apiServices.getApiResponse(AppUrl.chatEndPoint);

      log("response : $response");

      return response;
    } catch (e) {
      log("auth error :$e}");
      rethrow;
    }
  }

  Future<dynamic> getTotalMessages(String chatId) async {
    try {
      dynamic response = await _apiServices.getApiResponse(
        "${AppUrl.messageEndPoint}$chatId",
      );

      log("response : $response");

      return response;
    } catch (e) {
      log("auth error :$e}");
      rethrow;
    }
  }

  Future<dynamic> addNewMessage(
    String chatId,
    Map<String, dynamic> mData,
  ) async {
    try {
      dynamic response = await _apiServices.postApiResponse(
        "${AppUrl.messageEndPoint}$chatId",
        mData,
      );

      log("response : $response");

      return response;
    } catch (e) {
      log("auth error :$e}");
      rethrow;
    }
  }

  //verify otp
  Future<dynamic> verifyOtpApi(dynamic data) async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Device ID (Android ID): ${androidInfo.id}');

      dynamic response = await _apiServices.postApiResponse(
        AppUrl.verifyOtpUrl,
        {"deviceId": androidInfo.id, ...data},
      );

      if (response["data"] != null &&
          response["data"]["accessToken"] != null &&
          response["data"]["vendor"]["_id"] != null) {
        log("Verify Otp Response: $response ");
        _prefService.setToken(response["data"]["accessToken"]);
        _prefService.setRegId(response["data"]["vendor"]["_id"]);
      }

      return response;
    } catch (e) {
      log("Error : $e");
      rethrow;
    }
  }

  //forget_password
  Future<dynamic> forgetPassword(dynamic data) async {
    try {
      dynamic response = await _apiServices.postApiResponse(
        AppUrl.forgetUrl,
        data,
      );
      return response;
    } catch (e) {
      log("Error : $e");
      rethrow;
    }
  }

  //verify otp
  Future<dynamic> registrationApi(
    Map<String, dynamic> formData,
    List<MultipartFile> files,
  ) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    print('Device ID (Android ID): ${androidInfo.id}');
    dynamic response = await _apiServices.filePostApiResponseWithImage(
      AppUrl.vendorEndPoint,
      'POST',
      {"deviceId": androidInfo.id, ...formData},
      files,
    );
    try {
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // login with email and password
  Future<dynamic> loginEmail(Map<String, dynamic> formData) async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Device ID (Android ID): ${androidInfo.id}');
      dynamic response = await _apiServices.postApiResponse(AppUrl.loginEmail, {
        "deviceId": androidInfo.id,
        ...formData,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // update profile
  Future<dynamic> updateProfile(
    Map<String, dynamic> formData,
    List<MultipartFile> files,
  ) async {
    var id = _prefService.getRegId();

    if (id != null) {
      dynamic response = await _apiServices.filePostApiResponseWithImage(
        AppUrl.profileUpdateUrl + id,
        'PATCH',
        formData,
        files,
      );

      log("chat cut : $response");
      return response;
    }
    return null;
  }

  // user profile update

  Future<dynamic> profileUserUpdateApi(bool blocked, String id) async {
    try {
      final url = Uri.parse("${AppUrl.baseUrl}/api/user/$id");
      log("url : $url");
      var request = http.MultipartRequest("PATCH", url);

      var tokenId = PrefService().getToken();
      request.headers.addAll({
        'Authorization': 'Bearer $tokenId',
        'Content-Type': 'multipart/form-data',
      });
      request.fields['isBlocked'] = blocked.toString();

      var response = await request.send();
      log("response :${response.statusCode}");
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("Uploaded!");
        }
      } else {
        if (kDebugMode) {
          print("HTTP request failed with status code ${response.statusCode}");
        }
        throw Exception(
          "HTTP request failed with status code ${response.statusCode}",
        );
      }

      var data = await http.Response.fromStream(response);
      log("Response Body: ${data.body}");
      return data.body;
    } catch (e) {
      if (kDebugMode) {
        print("An error occurred: $e");
      }
      rethrow;
    }
  }

  // generate RTC Token
  Future<String> generateRTCToken(
    String channelName,
    String role,
    String uid,
  ) async {
    try {
      // channelName, uid, role,
      dynamic response = await _apiServices.getApiResponse(
        "${AppUrl.generateAgoraRtcToken}$channelName/$role/uid/$uid"
        "?appId=${AgoraConfig.appId}"
        "&appCertificate=${AgoraConfig.appCertificate}",
      );
      return response['rtcToken'];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> generateChatToken(String username) async {
    try {
      // channelName, username,
      Map<String, dynamic> response = await _apiServices.getApiResponse(
        "${AppUrl.generateAgoraChatToken}$username"
        "?appId=${AgoraConfig.appId}"
        "&appCertificate=${AgoraConfig.appCertificate}"
        "&orgName=${AgoraConfig.orgName}"
        "&appName=${AgoraConfig.appName}",
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // GET /api/call/:channelId/token - the astrologer side's own RTC token for
  // an incoming call. Unlike generateRTCToken above, the server issues this
  // one using its own credentials and the astrologer's pre-assigned agoraUid
  // for this specific call session (set when the customer called /start) -
  // the astrologer never calls /start, so this is its only way to get a token.
  Future<Map<String, dynamic>> getCallToken(String channelId) async {
    final response = await _apiServices.getApiResponse(
      "${AppUrl.callBaseUrl}/$channelId/token",
    );
    return Map<String, dynamic>.from(response["data"] as Map);
  }

  // POST /api/call/:channelId/joined - confirms to the server that both
  // sides are actually connected. Idempotent.
  Future<void> markCallJoined(String channelId) async {
    await _apiServices.postApiResponse("${AppUrl.callBaseUrl}/$channelId/joined", {});
  }

  // POST /api/call/:channelId/heartbeat - periodic "still connected" signal.
  // Returns {callEnded, reason?} - the server force-ends a call whose
  // customer has run out of wallet mid-call, rather than letting it run for
  // free once started. Callers must check callEnded and hang up when true.
  Future<Map<String, dynamic>> callHeartbeat(String channelId) async {
    final response = await _apiServices.postApiResponse("${AppUrl.callBaseUrl}/$channelId/heartbeat", {});
    return Map<String, dynamic>.from(response["data"] as Map);
  }

  // POST /api/call/:channelId/end - reports the call as over. Idempotent -
  // ending an already-ended session is a no-op on the server, not an error.
  Future<void> endCallSession(String channelId, {required String disconnectedBy, String? reason}) async {
    await _apiServices.postApiResponse("${AppUrl.callBaseUrl}/$channelId/end", {
      "disconnectedBy": disconnectedBy,
      if (reason != null) "reason": reason,
    });
  }

  //Add login hours
  Future<dynamic> addLoginHours(Map<String, dynamic> data) async {
    try {
      dynamic response = await _apiServices.postApiResponse(
        AppUrl.loginHistoriesUrl,
        data,
      );

      log("loginResponse: $response");

      return response;
    } catch (e) {
      log("LoginHours sent to Flutter error : $e");
      rethrow;
    }
  }

  // REMOVE FROM WAITLIST
  Future<dynamic> removeWaitingCall({
    required String userId,
    required String waitType,
    required String status,
  }) async {
    try {
      var regId = PrefService().getRegId();

      dynamic response = await _apiServices.deleteApiResponse(
        "${AppUrl.vendorEndPoint}/waiting/$regId",
        {"userId": userId, "waitType": waitType, "status": status},
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  //get training Video
  Future<List<TrainingVideoModel>> getTrainingVideo() async {
    try {
      List<TrainingVideoModel> list = [];

      dynamic response = await _apiServices.getApiResponse(
        AppUrl.trainingVideoUrl,
      );

      log("Response get: $response");

      List result = response["data"];

      for (int i = 0; i < result.length; i++) {
        TrainingVideoModel post = TrainingVideoModel.fromJson(
          result[i] as Map<String, dynamic>,
        );
        list.add(post);
      }

      return list;
    } catch (e) {
      rethrow;
    }
  }

  //get Vendor Detail
  Future<VendorDetailsModel> getVendorDetail() async {
    try {
      var id = _prefService.getRegId();
      dynamic response = await _apiServices.getApiResponse(
        AppUrl.profileUpdateUrl + id,
      );

      log("Response getVendorDetail: $response");

      VendorDetailsModel vendorDetailsModel = VendorDetailsModel.fromJson(
        response["data"],
      );

      return vendorDetailsModel;
    } catch (e) {
      rethrow;
    }
  }

  //get Vendor Call Detail
  //get Vendor Call Detail
  Future<List<VendorCallDetailModel>> getVendorCallDetail(String? type) async {
    try {
      List<VendorCallDetailModel> list = [];
      var id = _prefService.getRegId();

      String url = "${AppUrl.vendorCallDetailUrl}?vendorId=$id";

      // ✅ Only add type if not null
      if (type != null && type.isNotEmpty) {
        url += "&type=$type";
      }

      dynamic response = await _apiServices.getApiResponse(url);

      log("Response get Call detail: $response");

      List result = response["data"];

      for (int i = 0; i < result.length; i++) {
        list.add(
          VendorCallDetailModel.fromJson(result[i] as Map<String, dynamic>),
        );
      }

      return list;
    } catch (e) {
      rethrow;
    }
  }

  // create blog
  Future<dynamic> createBlogApi(
    Map<String, dynamic> formData,
    List<MultipartFile> files,
  ) async {
    dynamic response = await _apiServices.filePostApiResponseWithImage(
      AppUrl.createBlogUrl,
      'POST',
      formData,
      files,
    );
    try {
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // update blog
  Future<dynamic> updateBlogApi(
    Map<String, dynamic> formData,
    List<MultipartFile> files,
    String docId,
  ) async {
    dynamic response = await _apiServices.filePostApiResponseWithImage(
      AppUrl.updateBlogUrl + docId,
      'PATCH',
      formData,
      files,
    );
    try {
      return response;
    } catch (e) {
      rethrow;
    }
  }

  //get Vendor Call Detail
  Future<List<VendorBlogDetailModel>> getVendorBlogDetail() async {
    try {
      List<VendorBlogDetailModel> list = [];
      var vendorId = PrefService().getRegId();
      dynamic response = await _apiServices.getApiResponse(
        "${AppUrl.createBlogUrl}?vendorId=$vendorId",
      );

      log(" Blog Url: ${AppUrl.createBlogUrl}?vendorId=$vendorId");
      log(" Blog Url: $vendorId");
      log("Response get Blog detail: $response");

      List result = response["data"];

      for (int i = 0; i < result.length; i++) {
        VendorBlogDetailModel blogList = VendorBlogDetailModel.fromJson(
          result[i] as Map<String, dynamic>,
        );
        list.add(blogList);
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  //Delete Blog Details
  Future<dynamic> deleteVehicle(String id) async {
    var data = await _apiServices.deleteApiResponse(
      AppUrl.deleteBlogUrl + id,
      {},
    );
    return data;
  }

  //get Login History Details
  Future<List<LoginHistoryModel>> getLoginHistoryDetail() async {
    try {
      var id = _prefService.getRegId();
      List<LoginHistoryModel> list = [];

      dynamic response = await _apiServices.getApiResponse(
        "${AppUrl.loginHistoriesUrl}?vendorId=$id",
      );

      log("Response get Login History Details: $response");

      List result = response["data"];

      for (int i = 0; i < result.length; i++) {
        LoginHistoryModel post = LoginHistoryModel.fromJson(
          result[i] as Map<String, dynamic>,
        );
        list.add(post);
      }

      return list;
    } catch (e) {
      rethrow;
    }
  }

  // Get Payment Report
  Future<List<PaymentDetailModel>> getPaymentReport() async {
    try {
      var id = _prefService.getRegId();
      List<PaymentDetailModel> list = [];

      dynamic response = await _apiServices.getApiResponse(
        "${AppUrl.transactionUrl}?vendorId=$id",
      );

      log("Response get Payments Details: $response");

      List result = response["data"];

      for (int i = 0; i < result.length; i++) {
        PaymentDetailModel post = PaymentDetailModel.fromJson(
          result[i] as Map<String, dynamic>,
        );
        list.add(post);
      }

      return list;
    } catch (e) {
      rethrow;
    }
  }

  //get Transaction Details
  Future<TransactionEarningModel> getTransactionEarning() async {
    try {
      var id = _prefService.getRegId();

      dynamic response = await _apiServices.getApiResponse(
        "${AppUrl.transactionEarningUrl}$id",
      );

      log("Transaction Earning Response : $response");
      TransactionEarningModel transactionEarningModel =
          TransactionEarningModel.fromJson(response["data"]);

      return transactionEarningModel;
    } catch (e) {
      rethrow;
    }
  }

  //get Banner
  Future<List<dynamic>> getBanner() async {
    try {
      dynamic response = await _apiServices.getApiResponse(AppUrl.bannerUrl);
      log("banner Url : ${response["data"].runtimeType}");
      return response["data"];
    } catch (e) {
      rethrow;
    }
  }

  // Get VendorWaitingCall
  Future<List<CallWaitingModel>> getVendorWaitingCall() async {
    try {
      List<CallWaitingModel> list = [];
      var id = _prefService.getRegId();
      dynamic response = await _apiServices.getApiResponse(
        "${AppUrl.vendorEndPoint}waiting/$id",
      );

      // if (response["data"].isNotEmpty) {
      //   callWaitingModel = CallWaitingModel.fromJson(response["data"][0]);
      // }
      List result = response["data"];

      for (int i = 0; i < result.length; i++) {
        CallWaitingModel post = CallWaitingModel.fromJson(
          result[i] as Map<String, dynamic>,
        );
        list.add(post);
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> getUserProfile(String userId) async {
    try {
      dynamic response = await _apiServices.getApiResponse(
        "${AppUrl.userEndPoint}$userId",
      );
      log("user Details : $response");
      return UserModel.fromJson(response["data"]);
    } catch (e) {
      rethrow;
    }
  }

  // get vendor profile
  Future<VendorProfileModel?> getVendorProfile() async {
    var regId = PrefService().getRegId();

    if (regId == null) {
      return null;
    }
    try {
      dynamic response = await _apiServices.getApiResponse(
        "${AppUrl.vendorEndPoint}$regId",
      );
      log("user Details : $response");
      return VendorProfileModel.fromJson(response["data"]);
    } catch (e) {
      rethrow;
    }
  }

  // GET USERS FROM WAITLIST
  Future<Map<String, dynamic>> getWaitingCall() async {
    try {
      var regId = PrefService().getRegId();

      var response = await _apiServices.getApiResponse(
        "${AppUrl.vendorEndPoint}/waiting/$regId",
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // GET AGORA JOINED USERS
  Future<Map<String, dynamic>?> getAgoraUsers(
    String appId,
    String channelName,
  ) async {
    final url = 'https://api.agora.io/dev/v1/channel/user/$appId/$channelName';

    // Encode credentials to base64
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('${AgoraConfig.customerId}:${AgoraConfig.customerCertificate}'))}';
    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{'Authorization': basicAuth},
    );
    print('Response data agora : $response');
    if (response.statusCode == 200) {
      // Successfully fetched data
      print('Response data: ${response.body}');
      return json.decode(response.body);
    } else {
      // Error occurred
      print('Request failed with status: ${response.statusCode}');
    }
    return null;
  }

  //get Vendor rating
  Future<List<VendorRatingModel>> getVendorRating(String chat) async {
    try {
      List<VendorRatingModel> list = [];
      var id = _prefService.getRegId();

      dynamic response = await _apiServices.getApiResponse(
        "${AppUrl.vendorRating}?vendorId=$id&type=$chat",
      );

      log("Response get vendor rating: $response");

      List result = response["data"];

      for (int i = 0; i < result.length; i++) {
        VendorRatingModel ratingList = VendorRatingModel.fromJson(
          result[i] as Map<String, dynamic>,
        );
        list.add(ratingList);
      }

      return list;
    } catch (e) {
      rethrow;
    }
  }

  //get User Follow List
  Future<List<FollowModel>> getUserFollowList() async {
    try {
      List<FollowModel> list = [];
      var regId = _prefService.getRegId();

      dynamic response = await _apiServices.getApiResponse(
        "${AppUrl.followerUser}/$regId",
      );

      log("Response get user Follow list: $response");

      List result = response["data"];

      for (int i = 0; i < result.length; i++) {
        FollowModel followList = FollowModel.fromJson(
          result[i] as Map<String, dynamic>,
        );
        list.add(followList);
      }

      return list;
    } catch (e) {
      rethrow;
    }
  }

  //get User Follow List
  Future<List<BlockedModel>> getBlockedUserList() async {
    var regId = PrefService().getRegId();
    try {
      List<BlockedModel> list = [];
      dynamic response = await _apiServices.getApiResponse(
        "${AppUrl.blockUserEndPoint}/$regId",
      );
      log("Response get user block list: $response");
      List result = response["data"];
      for (int i = 0; i < result.length; i++) {
        BlockedModel blockedList = BlockedModel.fromJson(
          result[i] as Map<String, dynamic>,
        );
        list.add(blockedList);
      }

      return list;
    } catch (e) {
      rethrow;
    }
  }

  // get booking details
  Future<List<BookingModel>> getBooking(String status) async {
    try {
      List<BookingModel> list = [];
      var id = _prefService.getRegId();

      dynamic response = await _apiServices.getApiResponse(
        "${AppUrl.bookingUser}/$id?status=$status",
      );

      log("Response get vendor booking: $response");

      List result = response["data"];

      for (int i = 0; i < result.length; i++) {
        BookingModel bookingList = BookingModel.fromJson(
          result[i] as Map<String, dynamic>,
        );
        list.add(bookingList);
      }

      return list;
    } catch (e) {
      rethrow;
    }
  }

  // get report/
  Future<List<ReportModel>> getReport() async {
    try {
      List<ReportModel> list = [];
      var id = _prefService.getRegId();
      dynamic response = await _apiServices.getApiResponse(
        "${AppUrl.reportEndPoint}?vendorId=$id",
      );
      log("Response get Report: $response");
      List result = response["data"];
      for (int i = 0; i < result.length; i++) {
        ReportModel reportList = ReportModel.fromJson(
          result[i] as Map<String, dynamic>,
        );
        list.add(reportList);
      }

      return list;
    } catch (e) {
      rethrow;
    }
  }

  // Api for hours daily
  Future<dynamic> getLoginHour(String hour) async {
    var regId = PrefService().getRegId();
    dynamic response = await _apiServices.getApiResponse(
      "${AppUrl.getLoginHoursEndPoint}/$regId?period=$hour",
    );
    log("Response status code: $response");
    if (response["statusCode"] == 200) {
      return response["data"];
    } else {
      throw Exception('Failed to load post');
    }
  }

  // for earning performance
  Future<dynamic> earningTransaction(String type) async {
    var regId = PrefService().getRegId();
    dynamic response = await _apiServices.getApiResponse(
      "${AppUrl.getEarningEndPoint}?vendorId=$regId&type=$type",
    );
    if (response["statusCode"] == 200) {
      return response["data"];
    } else {
      throw Exception("Failed to load post");
    }
  }

  // for Gift
  Future<dynamic> getGift() async {
    var p = PrefService().getRegId();
    dynamic response = await _apiServices.getApiResponse(
      "${AppUrl.getGiftEndPoint}?vendorId=$p",
    );

    print("gift response : $response");
    if (response["statusCode"] == 200) {
      return response["data"];
    } else {
      throw Exception("Failed to load post");
    }
  }

  // GET AGORA JOINED USERS
  Future<dynamic> getTotalUserInStream(String channelId) async {
    var basicAuth =
        'Basic ${base64Encode(utf8.encode('${AgoraConfig.customerId}:${AgoraConfig.customerCertificate}'))}';

    print(basicAuth);

    var url =
        "https://api.agora.io/dev/v1/channel/user/${AgoraConfig.appId}/$channelId";
    print(url);
    Response r = await get(
      Uri.parse(url),
      headers: <String, String>{'authorization': basicAuth},
    );
    print(r.statusCode);
    print(r.body);

    return jsonDecode(r.body);
  }

  // blocked User
  Future<dynamic> userBlock(String userId) async {
    var regId = PrefService().getRegId();
    try {
      dynamic response = await _apiServices.postApiResponse(
        "${AppUrl.blockUserEndPoint}/$regId",
        {"userId": userId},
      );

      return response;
    } catch (e) {
      log("Error : $e");
      rethrow;
    }
  }

  // unBlocked User
  Future<dynamic> userUnBlock(String userId) async {
    var regId = PrefService().getRegId();
    try {
      dynamic response = await _apiServices.postApiResponse(
        "${AppUrl.unBlockUserEndPoint}/$regId",
        {"userId": userId},
      );

      return response;
    } catch (e) {
      log("Error : $e");
      rethrow;
    }
  }

  // withdraw Amount from the wallet
  Future<dynamic> withdrawAmount(String amount) async {
    var regId = PrefService().getRegId();
    try {
      dynamic response = await _apiServices.postApiResponse(
        "${AppUrl.withdrawAmountEndPoint}/$regId",
        {"amount": amount},
      );

      return response;
    } catch (e) {
      log("Error : $e");
      rethrow;
    }
  }

  // check availability
  Future<dynamic> getAvailability(String vendorId) async {
    try {
      dynamic response = await _apiServices.getApiResponse(
        "${AppUrl.vendorEndPoint}check-availability/$vendorId",
      );
      log("messageeee : $response");
      return response['data'];
    } catch (e) {
      rethrow;
    }
  }

  // update Assign remedy

  Future<dynamic> updateAssignRemedy(
    bool isRemedyAsigned,
    String transactionId,
  ) async {
    try {
      String? token = await PrefService().getToken();

      final url = Uri.parse("${AppUrl.vendorCallDetailUrl}/$transactionId");

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"isRemedyAsigned": isRemedyAsigned}),
      );

      log("PATCH response: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body)['data'];
      } else {
        throw Exception('Failed to patch data: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // transaction history
  Future<dynamic> createTransaction(Map<String, dynamic> mData) async {
    try {
      var regId = PrefService().getRegId();

      dynamic response = await _apiServices.postApiResponse(
        "${AppUrl.transactionUrl}?userId=$regId",
        mData,
      );
      print("response:$response");
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // remedy assign to user

  Future<dynamic> assignRemedy(Map<String, dynamic> mData) async {
    try {
      dynamic response = await _apiServices.postApiResponse(
        AppUrl.remedyUrl,
        mData,
      );
      print("remedy response:$response");
      return response;
    } catch (e) {
      print("Error in assignRemedy: $e");
      rethrow;
    }
  }

  // send voice message
  Future<dynamic> addNewMessageWithAttachment(
    String chatId,
    Map<String, dynamic> mData,
    List<MultipartFile> files,
  ) async {
    try {
      dynamic response = await _apiServices.filePostApiResponseWithImage(
        "${AppUrl.messageEndPoint}$chatId",
        "POST",
        mData,
        files,
      );

      print("response : $response");

      return response;
    } catch (e) {
      print("Error :$e}");
      rethrow;
    }
  }

  // get daily performance

  Future<dynamic> dailyPerformance() async {
    var regId = PrefService().getRegId();
    dynamic response = await _apiServices.getApiResponse(
      "${AppUrl.getDailyPerformanceEndPoint}/$regId",
    );
    if (response["statusCode"] == 200) {
      return response["data"];
    } else {
      throw Exception("Failed to load post");
    }
  }

  // for weekly performance
  Future<dynamic> weeklyPerformance(String type) async {
    var regId = PrefService().getRegId();
    dynamic response = await _apiServices.getApiResponse(
      "${AppUrl.getDailyPerformanceEndPoint}/$regId?period=$type",
    );
    if (response["statusCode"] == 200) {
      return response["data"];
    } else {
      throw Exception("Failed to load post");
    }
  }

  // for month performance
  // Future<dynamic> monthPerformance(String type) async {
  //   var regId = PrefService().getRegId();
  //   dynamic response = await _apiServices.getApiResponse(
  //       "${AppUrl.getDailyPerformanceEndPoint}/$regId?period=$type");
  //   if (response["statusCode"] == 200) {
  //     return response["data"];
  //   } else {
  //     throw Exception("Failed to load post");
  //   }
  // }

  Future<List<MyEarningModel>> monthPerformance(String type) async {
    final regId = PrefService().getRegId();

    final response = await _apiServices.getApiResponse(
      "${AppUrl.getDailyPerformanceEndPoint}/$regId?period=$type",
    );

    if (response["statusCode"] == 200) {
      final List data = response["data"];

      return data.map((e) => MyEarningModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load earnings");
    }
  }

  // delete group id
  Future<void> deleteGroupId(String mobileNumber) async {
    try {
      // 1. Get user ID and appToken
      final userId = await PrefService().getRegId();
      final tokenResponse = await Repository().generateChatToken(userId);
      final appToken = tokenResponse["appToken"];

      // 2. Get all groups
      final url = Uri.parse(
        "https://a61.chat.agora.io/${AgoraConfig.orgName}/${AgoraConfig.appName}/chatgroups?limit=10000",
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $appToken',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> data = decoded['data'];
        final groups = data.cast<Map<String, dynamic>>();

        // 3. Loop and delete each group
        for (var group in groups) {
          log("groupname${group['groupname']}");
          log("mobileNumber$mobileNumber");
          if (mobileNumber == "${group['groupname']}" ||
              "${group['groupname']}" == "") {
            await _deleteGroupById(group['groupid'], appToken);
          }
        }
      } else {
        throw Exception('Failed to fetch groups: ${response.body}');
      }
    } catch (e) {
      throw Exception('deleteGroupId() failed: $e');
    }
  }

  Future<void> _deleteGroupById(String groupId, String appToken) async {
    final deleteUrl = Uri.parse(
      "https://a61.chat.agora.io/${AgoraConfig.orgName}/${AgoraConfig.appName}/chatgroups/$groupId",
    );

    final deleteResponse = await http.delete(
      deleteUrl,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $appToken',
      },
    );

    if (deleteResponse.statusCode == 200) {
      log('Deleted group: $groupId');
    } else {
      log('Failed to delete group $groupId: ${deleteResponse.body}');
    }
  }

  // astrologer stats model

  Future<StatsModel> getStats() async {
    var vendorId = PrefService().getRegId();
    log("vendor vendorId : $vendorId");
    try {
      dynamic response = await _apiServices.getApiResponse(
        "${AppUrl.vendorStatsEndPoint}/$vendorId",
      );
      log("stats url : ${AppUrl.vendorStatsEndPoint}/$vendorId");
      log("Stats Details : $response");
      return StatsModel.fromJson(response["data"]);
    } catch (e) {
      rethrow;
    }
  }

  // get payout history
  Future<WithdrawalResponse> getPayOut() async {
    try {
      final vendorId = PrefService().getRegId();
      final url = "${AppUrl.withdrawAmountEndPoint}/$vendorId";
      final response = await _apiServices.getApiResponse(url);
      return WithdrawalResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> endChatSession(String chatId) async {
    try {
      final response = await _apiServices.postApiResponse(
        "${AppUrl.chatEndPoint}/end/$chatId",
        {},
      );

      if (response != null) {
        await Repository().updateProfile({
          "isChatAvailable": true,
          "isAudioCallAvailable": true,
          "isVideoCallAvailable": true,
          "isNowAvailable": true,
          "isOnline": true,
        }, []);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
