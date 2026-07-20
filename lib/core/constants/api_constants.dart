class ApiConstants {
  static const String serverOrigin = 'http://165.22.247.79:8080';
  static const String baseUrl = '$serverOrigin/api';

  // Auth
  static const String login = '/Auth/login';
  static const String register = '/Auth/register';
  static const String sendOtp = '/Auth/send-otp';
  static const String verifyOtp = '/Auth/verify-otp';
  static const String me = '/Auth/me';
  static const String forgotPassword = '/Auth/forgot-password';
  static const String resetPassword = '/Auth/reset-password';
  static const String updateProfile = '/Auth/profile';
  static const String fcmToken = '/Auth/fcm-token';

  // KYC (current user)
  static const String kycSubmit = '/Auth/kyc';
  static const String kycStatus = '/Auth/kyc-status';

  // Catalogue
  static const String categories = '/Categories';
  static const String products = '/Products';
  static const String myProducts = '/Products/mine';

  // Orders
  static const String orders = '/Orders';
  static const String myOrders = '/Orders/mine';
  static const String vendorOrders = '/Orders/vendor';
  static const String riderOrders = '/Orders/rider';

  // Service bookings
  static const String bookings = '/Bookings';
  static const String myBookings = '/Bookings/mine';
  static const String technicianBookings = '/Bookings/technician';

  // Vendors
  static const String vendorApply = '/Vendors/apply';
  static const String vendorMe = '/Vendors/me';
  static const String vendorRequestStatus = '/Vendors/request-status';
  static const String vendors = '/Vendors';

  // Reviews
  static const String reviews = '/Reviews';
  static const String reviewsForProduct = '/Reviews/product/';
  static const String reviewsForBooking = '/Reviews/booking/';

  // Payments (QR-screenshot flow)
  static const String paymentQr = '/Payments/qr';
  static const String paymentSubmit = '/Payments/submit';
  static const String paymentVerify = '/Payments/verify';
  static const String paymentPending = '/Payments/pending';

  // Promos
  static const String validatePromo = '/Promos/validate';
  static const String promos = '/Promos';

  // Returns
  static const String returns = '/Returns';
  static const String myReturns = '/Returns/mine';

  // Uploads
  static const String uploadProduct = '/Uploads/product';
  static const String uploadDamage = '/Uploads/damage';
  static const String uploadPayment = '/Uploads/payment';
  static const String uploadKyc = '/Uploads/kyc';

  static const int connectTimeout = 10000;
  static const int receiveTimeout = 15000;
}
