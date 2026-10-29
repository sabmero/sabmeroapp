import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sabmeroapp/features/home/presentation/screens/forgot_password.dart';
import 'package:sabmeroapp/features/home/presentation/screens/reset_password_screen.dart';
import 'package:sabmeroapp/features/home/presentation/screens/role_activity_screen.dart';
import 'package:sabmeroapp/features/home/presentation/screens/role_home_screen.dart';
import 'package:sabmeroapp/features/rider/presentation/screens/rider_delivery_detail_screen.dart';
import 'package:sabmeroapp/features/technician/presentation/screens/technician_job_detail_screen.dart';
import 'route_names.dart';
import '../widgets/coming_soon_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/activity_hub_screen.dart';
import '../../features/shop/presentation/screens/category_list_screen.dart';
import '../../features/shop/presentation/screens/product_list_screen.dart';
import '../../features/shop/presentation/screens/product_detail_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/cart/presentation/screens/checkout_screen.dart';
import '../../features/orders/presentation/screens/order_detail_screen.dart';
import '../../features/orders/presentation/screens/order_tracking_screen.dart';
import '../../features/repair_service/presentation/screens/repair_category_screen.dart';
import '../../features/repair_service/presentation/screens/repair_booking_screen.dart';
import '../../features/repair_service/presentation/screens/repair_tracking_screen.dart';
import '../../features/repair_service/presentation/screens/repair_bookings_list_screen.dart';
import '../../features/vendor/presentation/screens/vendor_registration_screen.dart';
import '../../features/vendor/presentation/screens/vendor_dashboard_screen.dart';
import '../../features/vendor/presentation/screens/vendor_product_form_screen.dart';
import '../../features/vendor/presentation/screens/vendor_orders_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/address_list_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/profile/presentation/screens/help_support_screen.dart';
import '../../features/profile/presentation/screens/privacy_policy_screen.dart';
import '../../features/profile/presentation/screens/terms_of_service_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/payment/presentation/screens/qr_scanner_screen.dart';
import '../../features/payment/presentation/screens/payment_method_screen.dart';
import 'providers/pending_route_provider.dart';
import 'providers/pending_task_count_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  final router = GoRouter(
    refreshListenable: notifier,
    initialLocation: RouteNames.splash,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.otpVerification,
        builder: (context, state) {
          final phone = state.extra as String? ?? '';
          return OtpVerificationScreen(phone: phone);
        },
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return ResetPasswordScreen(email: email);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.home,
                builder: (context, state) => const RoleHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.orderList,
                builder: (context, state) => const RoleActivityScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.notifications,
                builder: (context, state) => const NotificationsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.cart,
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: RouteNames.checkout,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: RouteNames.categoryList,
        builder: (context, state) => const CategoryListScreen(),
      ),
      GoRoute(
        path: RouteNames.productList,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return ProductListScreen(
            categoryId: args['categoryId'] as String? ?? '',
            categoryName: args['categoryName'] as String? ?? 'Products',
          );
        },
      ),
      GoRoute(
        path: RouteNames.productDetail,
        builder: (context, state) {
          final productId = state.pathParameters['id'] ?? '';
          return ProductDetailScreen(productId: productId);
        },
      ),
      GoRoute(
        path: RouteNames.orderDetail,
        builder: (context, state) {
          final orderId = state.pathParameters['id'] ?? '';
          return OrderDetailScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: RouteNames.orderTracking,
        builder: (context, state) {
          final orderId = state.pathParameters['id'] ?? '';
          return OrderTrackingScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: RouteNames.repairCategories,
        builder: (context, state) => const RepairCategoryScreen(),
      ),
      GoRoute(
        path: RouteNames.myRepairs,
        builder: (context, state) => const RepairBookingsListScreen(),
      ),
      GoRoute(
        path: RouteNames.repairBooking,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return RepairBookingScreen(
            categoryId: args['categoryId'] as String? ?? '',
            categoryName: args['categoryName'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: RouteNames.repairTracking,
        builder: (context, state) {
          final bookingId = state.pathParameters['id'] ?? '';
          return RepairTrackingScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: RouteNames.vendorRegistration,
        builder: (context, state) => const VendorRegistrationScreen(),
      ),
      GoRoute(
        path: RouteNames.vendorDashboard,
        builder: (context, state) => const VendorDashboardScreen(),
      ),
      GoRoute(
        path: RouteNames.vendorProductForm,
        builder: (context, state) {
          final productId = state.extra as String?;
          return VendorProductFormScreen(productId: productId);
        },
      ),
      GoRoute(
        path: RouteNames.vendorOrders,
        builder: (context, state) => const VendorOrdersScreen(),
      ),
      GoRoute(
        path: RouteNames.technicianJobDetail,
        builder: (context, state) {
          final jobId = state.pathParameters['id']!;
          return TechnicianJobDetailScreen(jobId: jobId);
        },
      ),
      GoRoute(
        path: RouteNames.riderJobDetail,
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;
          return RiderDeliveryDetailScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: RouteNames.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.addressList,
        builder: (context, state) => const AddressListScreen(),
      ),
      GoRoute(
        path: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RouteNames.helpSupport,
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: RouteNames.privacyPolicy,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: RouteNames.termsOfService,
        builder: (context, state) => const TermsOfServiceScreen(),
      ),
      GoRoute(
        path: RouteNames.qrScanner,
        builder: (context, state) => const QrScannerScreen(),
      ),
      GoRoute(
        path: RouteNames.paymentMethod,
        builder: (context, state) => const PaymentMethodScreen(),
      ),
      GoRoute(
        path: RouteNames.comingSoon,
        builder: (context, state) {
          final title = state.extra as String?;
          return ComingSoonScreen(title: title ?? 'Coming Soon');
        },
      ),
    ],
  );
  notifier.router = router;
  return router;
});

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen(authNotifierProvider, (_, _) => notifyListeners());
  }

  final Ref _ref;

  /// Set right after the GoRouter is created; used to continue to the page a
  /// guest was heading to once they have logged in.
  GoRouter? router;

  /// Screens that need an account. Everything else (browsing the shop, product
  /// pages, the cart, repair categories, help/policy pages) is open to guests.
  static bool _requiresLogin(String location) {
    const exact = <String>{
      RouteNames.checkout,
      RouteNames.orderList,
      RouteNames.notifications,
      RouteNames.profile,
      RouteNames.editProfile,
      RouteNames.addressList,
      RouteNames.repairBooking,
      RouteNames.myRepairs,
      RouteNames.paymentMethod,
      RouteNames.qrScanner,
    };
    if (exact.contains(location)) return true;
    const prefixes = <String>['/orders/', '/vendor/', '/technician/', '/rider/'];
    if (prefixes.any(location.startsWith)) return true;
    return location.startsWith('/repair/') && location.endsWith('/tracking');
  }

  /// Bottom-tab roots: after login we `go` straight to them.
  static bool _isTabRoot(String location) =>
      location == RouteNames.home ||
      location == RouteNames.orderList ||
      location == RouteNames.notifications ||
      location == RouteNames.profile;

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authNotifierProvider);
    final location = state.matchedLocation;

    final isAtSplash = location == RouteNames.splash;
    final isAtAuth =
        location == RouteNames.login ||
        location == RouteNames.register ||
        location == RouteNames.otpVerification ||
        location == RouteNames.forgotPassword ||
        location == RouteNames.resetPassword ||
        location == RouteNames.onboarding;

    // While the initial /me check is still running we do NOT yank the user
    // back to splash. SplashScreen routes optimistically off the saved token,
    // so a returning user is already on home before /me resolves. Holding them
    // on splash here is exactly what made first-load feel stuck. We simply let
    // the current screen stand until auth settles; the branch below corrects
    // things if /me ultimately reports no valid user.
    if (authState.isLoading) {
      return null;
    }

    final user = authState.asData?.value;

    // Auth has settled. If a logged-in user lands on splash, send them home.
    // The unauthenticated case (onboarding vs home) is decided by
    // SplashScreen, which needs the async onboarding flag, so we don't force
    // it here.
    if (isAtSplash) {
      return user != null ? RouteNames.home : null;
    }

    // Guests can browse freely. Only account screens (checkout, booking,
    // orders, profile ...) ask for a login, and remember where to come back to.
    if (user == null && !isAtAuth && _requiresLogin(location)) {
      _ref
          .read(pendingRouteProvider)
          .set(state.uri.toString(), extra: state.extra);
      return RouteNames.login;
    }

    if (user != null && isAtAuth) {
      final pending = _ref.read(pendingRouteProvider).take();
      if (pending == null) return RouteNames.home;
      if (_isTabRoot(pending.location)) return pending.location;
      // Land on Home first so Back works, then open the screen the guest was
      // heading to (checkout, repair booking ...).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        router?.push(pending.location, extra: pending.extra);
      });
      return RouteNames.home;
    }

    return null;
  }
}

// class MainShell extends StatefulWidget {
//   const MainShell({super.key, required this.navigationShell});

//   final StatefulNavigationShell navigationShell;

//   @override
//   State<MainShell> createState() => _MainShellState();
// }

// class _MainShellState extends State<MainShell> {
//   DateTime? _lastBackPress;

//   void _handleBack() {
//     final now = DateTime.now();
//     final shouldExit =
//         _lastBackPress != null &&
//         now.difference(_lastBackPress!) <= const Duration(seconds: 2);

//     if (shouldExit) {
//       SystemNavigator.pop();
//       return;
//     }

//     _lastBackPress = now;
//     final messenger = ScaffoldMessenger.of(context);
//     messenger.clearSnackBars();
//     messenger.showSnackBar(
//       const SnackBar(
//         content: Text('Press back again to exit'),
//         duration: Duration(seconds: 2),
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final shell = widget.navigationShell;
//     // On a non-home tab, the first back press returns to Home. Only on the
//     // Home tab does the double-press-to-exit guard apply.
//     final isHomeTab = shell.currentIndex == 0;

//     return PopScope(
//       canPop: false,
//       onPopInvokedWithResult: (didPop, result) {
//         if (didPop) return;
//         if (!isHomeTab) {
//           shell.goBranch(0);
//           return;
//         }
//         _handleBack();
//       },
//       child: Scaffold(
//         body: shell,
//         bottomNavigationBar: NavigationBar(
//           selectedIndex: shell.currentIndex,
//           onDestinationSelected: (index) {
//             shell.goBranch(index, initialLocation: index == shell.currentIndex);
//           },
//           destinations: const [
//             NavigationDestination(
//               icon: Icon(Icons.home_outlined),
//               selectedIcon: Icon(Icons.home),
//               label: 'Home',
//             ),
//             NavigationDestination(
//               icon: Icon(Icons.receipt_long_outlined),
//               selectedIcon: Icon(Icons.receipt_long),
//               label: 'Activity',
//             ),
//             NavigationDestination(
//               icon: Icon(Icons.notifications_outlined),
//               selectedIcon: Icon(Icons.notifications),
//               label: 'Alerts',
//             ),
//             NavigationDestination(
//               icon: Icon(Icons.person_outline),
//               selectedIcon: Icon(Icons.person),
//               label: 'Profile',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  DateTime? _lastBackPress;

  void _handleBack() {
    final now = DateTime.now();
    final shouldExit =
        _lastBackPress != null &&
        now.difference(_lastBackPress!) <= const Duration(seconds: 2);

    if (shouldExit) {
      SystemNavigator.pop();
      return;
    }

    _lastBackPress = now;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Press back again to exit'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shell = widget.navigationShell;
    // On a non-home tab, the first back press returns to Home. Only on the
    // Home tab does the double-press-to-exit guard apply.
    final isHomeTab = shell.currentIndex == 0;
    final pendingCount = ref.watch(pendingTaskCountProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (!isHomeTab) {
          shell.goBranch(0);
          return;
        }
        _handleBack();
      },
      child: Scaffold(
        body: shell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (index) {
            final authState = ref.read(authNotifierProvider);
            final isGuest =
                !authState.isLoading && authState.asData?.value == null;
            if (isGuest && index != 0) {
              const tabPaths = <String>[
                RouteNames.home,
                RouteNames.orderList,
                RouteNames.notifications,
                RouteNames.profile,
              ];
              ref.read(pendingRouteProvider).set(tabPaths[index]);
              context.push(RouteNames.login);
              return;
            }
            shell.goBranch(index, initialLocation: index == shell.currentIndex);
          },
          destinations: [
            NavigationDestination(
              icon: Badge(
                isLabelVisible: pendingCount > 0,
                label: Text('$pendingCount'),
                child: const Icon(Icons.home_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: pendingCount > 0,
                label: Text('$pendingCount'),
                child: const Icon(Icons.home),
              ),
              label: 'Home',
            ),
            const NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Activity',
            ),
            const NavigationDestination(
              icon: Icon(Icons.notifications_outlined),
              selectedIcon: Icon(Icons.notifications),
              label: 'Alerts',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
