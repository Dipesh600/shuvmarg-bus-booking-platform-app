import 'package:sumarg/utils/dev_target.dart';

class ApiEndpoints {
  // ─── Environment selector ─────────────────────────────────────────────────
  // Switch this enum value to match where you are running the app:
  //   DevTarget.macDesktop   → 127.0.0.1:7012  (flutter run -d macos)
  //   DevTarget.androidEmu   → 10.0.2.2:7012   (Android Studio emulator)
  //   DevTarget.physicalDevice → LAN IP        (real phone on same Wi-Fi)
  //   DevTarget.production   → api.shuvmarg.com (live server)
  static const _env = DevTarget.physicalDevice;

  static String get baseUrl {
    switch (_env) {
      case DevTarget.macDesktop:
        return 'http://127.0.0.1:7012';
      case DevTarget.androidEmu:
        return 'http://10.0.2.2:7012';
      case DevTarget.physicalDevice:
        return 'http://10.53.238.245:7012'; // Your Mac's LAN IP over hotspot
      case DevTarget.production:
        return 'https://api.shuvmarg.com';
    }
  }

  static const String api = "/api";
  static const String ticket = "$api/ticket";
  static const String pushnoti = "$api/pushnoti";

  // Auth Endpoints
  static String get login => "$baseUrl$api/login";
  static String get registerNextStape => "$baseUrl$api/completeRegistration";
  static String get register => "$baseUrl$api/sendPhoneOTP";
  static String get verifyOtp => "$baseUrl$api/verifyPhoneOTP";
  static String get resendOtp => "$baseUrl$api/resendOtp";
  static String get passwordReset => "$baseUrl$api/requestPasswordReset";
  static String get verifyOtpForPass => "$baseUrl$api/verifyOtpForReset";
  static String get resetPassword => "$baseUrl$api/resetPassword";
  static String get changeProfilePicture => "$baseUrl$api/changeProfilePicture";
  static String get getUserDetails => "$baseUrl$api/getUserDetail";
  static String get updateProfileDetail => "$baseUrl$api/updateProfile";
  static String get updatepassword => "$baseUrl$api/updatepassword";
  static String get refreshToken => "$baseUrl$api/refresh";
  static String get logout => "$baseUrl$api/logout";

  // Ticket Endpoints
  static String get searchTicket => "$baseUrl$api/public/searchTrips";
  static String get getseats => "$baseUrl$ticket/getSeats";
  static String get prepareBooking => "$baseUrl$ticket/prepareBooking";
  static String get confirmBooking => "$baseUrl$ticket/confirmBooking";
  static String get bookTicket => "$baseUrl$ticket/bookTicket";
  static String get bookingHistory => "$baseUrl$ticket/getMyTicketHistory";
  static String get validateYatraPoints => "$baseUrl$ticket/validateYatraPoints";
  static String get cancelticket => "$baseUrl$ticket/cancelTicket";
  static String get cancelEstimate => "$baseUrl$ticket/cancelEstimate";

  // Push Notification
  static String get storedeviceinfo => "$baseUrl$pushnoti/getDeviceInfo";
  static String get mylocalnotifications => "$baseUrl$pushnoti/my-local-notifications";
  static String get markNotificationAsRead => "$baseUrl$pushnoti/markNotificationAsRead";
  static String get deleteNotification => "$baseUrl$pushnoti/delete";

  // Validate Coupon
  static String get validateCoupon => "$baseUrl$api/coupons/validate";

  // Get Coupons (active only — home carousel)
  static String get getCoupons => "$baseUrl$api/coupons/all";

  // Get ALL Coupons including expired (See All page)
  static String get getAllCouponsWithExpired => "$baseUrl$api/coupons/all-with-expired";

  // Get Reward History
  static String get getRewardHistory => "$baseUrl$api/ticket/getMyYatraHistory";

  // Feed back
  static String get feedback => "$baseUrl$api/reviews/createReview";
  static String getFleetReviews(String fleetId) => "$baseUrl$api/reviews/fleet/$fleetId";

  // Referal
  static String get refralDashboard => "$baseUrl$api/referral/dashboard";
  static String get referalHistory => "$baseUrl$api/referral/history";

  // Stop Autocomplete
  static String get stopSearch => "$baseUrl$api/public/stops/search";
}
