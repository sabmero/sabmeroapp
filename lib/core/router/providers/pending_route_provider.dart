import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../route_names.dart';

/// Where a guest was heading when the app asked them to log in (for example
/// Checkout after tapping "Order Now"). After a successful login the router
/// sends them there instead of dropping them on Home.
class PendingRoute {
  const PendingRoute(this.location, {this.extra});

  final String location;
  final Object? extra;
}

/// A plain mutable holder (not reactive state), so the router can read and
/// clear it safely while redirecting.
class PendingRouteHolder {
  PendingRoute? _pending;

  void set(String location, {Object? extra}) {
    _pending = PendingRoute(location, extra: extra);
  }

  /// Returns the pending route and clears it.
  PendingRoute? take() {
    final p = _pending;
    _pending = null;
    return p;
  }

  void clear() => _pending = null;
}

final pendingRouteProvider = Provider<PendingRouteHolder>(
  (ref) => PendingRouteHolder(),
);

bool _isTabRoot(String location) =>
    location == RouteNames.home ||
    location == RouteNames.orderList ||
    location == RouteNames.notifications ||
    location == RouteNames.profile;

/// Call right after a successful sign-in (password, OTP or registration).
/// Takes the user to the screen they were heading to before being asked to
/// log in (e.g. Checkout), or Home when there is none. Done here explicitly
/// because the login screen is opened on top of the current page, so the
/// router's automatic redirect cannot be relied on to leave it.
void continueAfterLogin(BuildContext context, WidgetRef ref) {
  final router = GoRouter.of(context);
  final pending = ref.read(pendingRouteProvider).take();

  if (pending == null) {
    router.go(RouteNames.home);
    return;
  }
  if (_isTabRoot(pending.location)) {
    router.go(pending.location);
    return;
  }
  // Home first (so Back works), then open the page the guest was heading to.
  router.go(RouteNames.home);
  WidgetsBinding.instance.addPostFrameCallback((_) {
    router.push(pending.location, extra: pending.extra);
  });
}
