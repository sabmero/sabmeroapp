class RouteNames {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String otpVerification = '/otp';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  static const String home = '/home';
  static const String cart = '/cart';
  static const String checkout = '/checkout';

  static const String categoryList = '/shop/categories';
  static const String productList = '/shop/products';
  static const String productDetail = '/shop/product/:id';

  static const String orderList = '/orders';
  static const String orderDetail = '/orders/:id';
  static const String orderTracking = '/orders/:id/tracking';

  static const String repairCategories = '/repair';
  static const String repairBooking = '/repair/booking';
  static const String myRepairs = '/repair/my-bookings';
  static const String repairTracking = '/repair/:id/tracking';
  static const String serviceCategory = '/repair/category/:id';
  static const String serviceDetail = '/repair/service-detail';
  static String serviceCategoryPath(int id) => '/repair/category/$id';

  static const String vendorRegistration = '/vendor/register';
  static const String vendorDashboard = '/vendor/dashboard';
  static const String vendorProductForm = '/vendor/product-form';
  static const String vendorOrders = '/vendor/orders';

  // Technician (assigned repair jobs)
  static const String technicianJobs = '/technician/jobs';
  static const String technicianJobDetail = '/technician/jobs/:id';

  // Delivery Rider (assigned deliveries)
  static const String riderJobs = '/rider/jobs';
  static const String riderJobDetail = '/rider/jobs/:id';

  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String addressList = '/profile/addresses';
  static const String settings = '/profile/settings';
  static const String helpSupport = '/profile/help';
  static const String privacyPolicy = '/profile/privacy';
  static const String termsOfService = '/profile/terms';

  static const String notifications = '/notifications';

  static const String qrScanner = '/payment/qr-scanner';
  static const String paymentMethod = '/payment/method';

  static const String comingSoon = '/comingSoon';
}
