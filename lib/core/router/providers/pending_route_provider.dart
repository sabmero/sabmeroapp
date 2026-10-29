import 'package:flutter_riverpod/flutter_riverpod.dart';

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
