class AppUrl {
  static var baseUrl = 'https://app.astromukti.com';
  static var generateOtpUrl = '$baseUrl/api/auth/generate-otp';
  static var verifyOtpUrl = '$baseUrl/api/auth/verify-otp';
  static var forgetUrl = '$baseUrl/api/auth/verify-forget-password';
  static var vendorEndPoint = '$baseUrl/api/vendor/';
  static var userEndPoint = '$baseUrl/api/user/';
  static var chatEndPoint = '$baseUrl/api/chat/';
  static var messageEndPoint = '$baseUrl/api/message/';
  static var trainingVideoUrl = '$baseUrl/api/video/';
  static var profileUpdateUrl = '$baseUrl/api/vendor/';
  static var vendorCallDetailUrl = '$baseUrl/api/transaction';
  static var createBlogUrl = '$baseUrl/api/blog/';
  static var updateBlogUrl = '$baseUrl/api/blog/';
  static var deleteBlogUrl = '$baseUrl/api/blog/';
  static var loginHistoriesUrl = '$baseUrl/api/vendor/login-histories';
  static var transactionUrl = '$baseUrl/api/transaction';
  static var remedyUrl = '$baseUrl/api/transaction/remedy';
  static var transactionEarningUrl = '$baseUrl/api/transaction/total-earning/';
  static var bannerUrl = '$baseUrl/api/banner/';
  static var generateAgoraRtcToken = '$baseUrl/generate-rtc-token/';
  static var generateAgoraChatToken = '$baseUrl/generate-chat-token/';
  static var callBaseUrl = '$baseUrl/api/call';
  static var loginEmail = '$baseUrl/api/auth/vlogin-email-password/';
  static var vendorRating = '$baseUrl/api/vendor/ratings';
  static var followerUser = '$baseUrl/api/vendor/followers';
  static var bookingUser = '$baseUrl/api/vendor/waiting';
  static var reportEndPoint = '$baseUrl/api/transaction';
  static var getLoginHoursEndPoint = '$baseUrl/api/vendor/my-activity';
  static var getDailyPerformanceEndPoint =
      '$baseUrl/api/transaction/my-earnings/';
  static var getEarningEndPoint = '$baseUrl/api/transaction';
  static var getGiftEndPoint = '$baseUrl/api/transaction/gift';
  static var blockUserEndPoint = '$baseUrl/api/vendor/block';
  static var unBlockUserEndPoint = '$baseUrl/api/vendor/unblock';
  static var withdrawAmountEndPoint = '$baseUrl/api/transaction/withdraw';
  static var vendorStatsEndPoint = '$baseUrl/api/vendor/stats';

  // key for AstrologyApi
  static String apiKey = '649782';
  // static String apiSecret = '39cf24a491d2b2642583b0e8103bb42ab9dc7a97';
  static String apiSecret = 'ak-8e80c99b1d328d594ff6581200eb24ad87244219';

  /// constant variable data

  static String regId = "";
  static String mobile = "";
  static String token = "";
  static String notificationId = "";
  static bool userSession = false;

  /// Shared Preference Keys ///

  static String regIdKey = "regIdKey";
  static String mobileNoKey = "mobileNoKey";
  static String tokenKey = "tokenKey";
  static String userSessionKey = "userSessionKey";
  static String notificationIdKey = "notificationIdKey";
}
