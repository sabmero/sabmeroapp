import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../orders/presentation/screens/order_list_screen.dart';
import '../../../repair_service/presentation/screens/repair_bookings_list_screen.dart';

/// A single hub the user reaches from the bottom navigation "Activity" tab.
/// It groups product Orders and repair-service Bookings under two tabs so the
/// user always knows where to find either kind of purchase.
class ActivityHubScreen extends ConsumerStatefulWidget {
  const ActivityHubScreen({super.key});

  @override
  ConsumerState<ActivityHubScreen> createState() => _ActivityHubScreenState();
}

class _ActivityHubScreenState extends ConsumerState<ActivityHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Rebuild when the tab changes so the FAB label/icon stays in sync.
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Activity'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          tabs: const [
            Tab(icon: Icon(Icons.shopping_bag_outlined), text: 'Orders'),
            Tab(icon: Icon(Icons.handyman_outlined), text: 'Repairs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          // Each child reuses the existing list screens. Their own Scaffolds'
          // app bars are hidden because they're embedded here; we wrap them in
          // a primary-scroll-aware view via the embedded flag.
          _EmbeddedOrders(),
          _EmbeddedRepairs(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            context.push(RouteNames.categoryList);
          } else {
            context.push(RouteNames.repairCategories);
          }
        },
        icon: Icon(
          _tabController.index == 0
              ? Icons.add_shopping_cart_rounded
              : Icons.add_rounded,
        ),
        label: Text(_tabController.index == 0 ? 'Shop' : 'Book Repair'),
      ),
    );
  }
}

/// The order list embedded without its own AppBar.
class _EmbeddedOrders extends StatelessWidget {
  const _EmbeddedOrders();

  @override
  Widget build(BuildContext context) {
    return const OrderListScreen(embedded: true);
  }
}

/// The repair bookings list embedded without its own AppBar.
class _EmbeddedRepairs extends StatelessWidget {
  const _EmbeddedRepairs();

  @override
  Widget build(BuildContext context) {
    return const RepairBookingsListScreen(embedded: true);
  }
}
