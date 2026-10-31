import '../../features/auth/domain/entities/user_entity.dart';
import 'route_names.dart';

/// Decides which screen a notification opens. Used by BOTH the Alerts list
/// (tap a row) and push taps (FcmService), so they always agree.
///
/// [type] is the backend notification type (order, order_new, order_status,
/// order_assigned, booking, booking_assigned, payment, payment_booking,
/// vendorPayment, vendor_request, vendor_request_new, promo).
/// [referenceId] is the order / booking / request id (or promo code).
///
/// Returns null when there is nothing to open (the notification is only marked
/// as read). Pass [role] when known, because the same event opens a different
/// screen for a vendor, a rider or a customer.
String? notificationLocation({
  required String type,
  String? referenceId,
  UserRole? role,
}) {
  final t = type.trim().toLowerCase();
  final id = (referenceId ?? '').trim();
  final hasId = id.isNotEmpty;
  String withId(String route) => route.replaceFirst(':id', id);

  switch (t) {
    // Customer: status of my order. Vendor/Admin: an order of theirs changed.
    case 'order':
    case 'order_status':
    case 'order_new':
      if (role == UserRole.vendor) return RouteNames.vendorOrders;
      return hasId ? withId(RouteNames.orderDetail) : RouteNames.orderList;

    // Rider: a delivery was assigned to me.
    case 'order_assigned':
      return hasId ? withId(RouteNames.riderJobDetail) : RouteNames.riderJobs;

    // Customer: repair / installation booking status.
    case 'booking':
    case 'repair':
    case 'payment_booking':
      return hasId ? withId(RouteNames.repairTracking) : RouteNames.myRepairs;

    // Technician: a job was assigned to me.
    case 'booking_assigned':
      return hasId
          ? withId(RouteNames.technicianJobDetail)
          : RouteNames.technicianJobs;

    // Payment on an order verified / rejected.
    case 'payment':
      return hasId ? withId(RouteNames.orderDetail) : RouteNames.orderList;

    // Vendor: the admin sent me a payment.
    case 'vendorpayment':
      return RouteNames.vendorDashboard;

    // Applicant: my vendor request was approved / rejected.
    case 'vendor_request':
      return role == UserRole.vendor
          ? RouteNames.vendorDashboard
          : RouteNames.vendorRegistration;

    // New offer.
    case 'promo':
      return RouteNames.home;

    // vendor_request_new (admin) and anything unknown: nothing to open.
    default:
      return null;
  }
}
