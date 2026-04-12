class ApiEndpoints {
  // static const String baseUrl = "http://34.229.93.103";
  // static const String baseUrl = "https://api.shuvmarg.com";
  static const String baseUrl = "http://192.168.1.35:7012";

  static const String api = "/api";
  // Auth Endpoints
  static const String login = "$baseUrl$api/login";
  static const String registerNextStape = "$baseUrl$api/completeRegistration";
  static const String register = "$baseUrl$api/sendPhoneOTP";
  static const String verifyOtp = "$baseUrl$api/verifyPhoneOTP";
  static const String resendOtp = "$baseUrl$api/resendOtp";
  static const String passwordReset = "$baseUrl$api/requestPasswordReset";
  static const String verifyOtpForPass = "$baseUrl$api/verifyOtpForReset";
  static const String resetPassword = "$baseUrl$api/resetPassword";
  static const String changeProfilePicture =
      "$baseUrl$api/changeProfilePicture";
  static const String getUserDetails = "$baseUrl$api/getUserDetail";
  static const String updateProfileDetail = "$baseUrl$api/updateProfile";
  static const String updatepassword = "$baseUrl$api/updatepassword";

// Ticket Endpoints
  static const String ticket = "$api/ticket";
  static const String searchTicket = "$baseUrl$api/public/searchTrips";
  static const String getseats = "$baseUrl$ticket/getSeats";
  static const String bookTicket = "$baseUrl$ticket/bookTicket";
  static const String bookingHistory = "$baseUrl$ticket/getMyTicketHistory";
  static const String validateYatraPoints =
      "$baseUrl$ticket/validateYatraPoints";
  static const String cancelticket = "$baseUrl$ticket/cancelTicket";

// Push Notification
  static const String pushnoti = "$api/pushnoti";
  static const String storedeviceinfo = "$baseUrl$pushnoti/getDeviceInfo";
  static const String mylocalnotifications =
      "$baseUrl$pushnoti/my-local-notifications";

  static const String markNotificationAsRead =
      "$baseUrl$pushnoti/markNotificationAsRead";
  static const String deleteNotification = "$baseUrl$pushnoti/delete";

// Validate Coupon
  static const String validateCoupon = "$baseUrl$api/coupons/validate";

// Get Coupons
  static const String getCoupons = "$baseUrl$api/coupons/all";

// Get Reward History
  static const String getRewardHistory =
      "$baseUrl$api/ticket/getMyYatraHistory";
// Feed back
  static const String feedback = "$baseUrl$api/reviews/createReview";
  static const String getfeedback = "$baseUrl$api/reviews/bus";

  // Referal
  static const String refralDashboard = "$baseUrl$api/referral/dashboard";
  static const String referalHistory = "$baseUrl$api/referral/history";
}
