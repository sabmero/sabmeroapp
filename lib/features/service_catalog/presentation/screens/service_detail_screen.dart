import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/service_catalog_models.dart';
import '../widgets/service_image.dart';
import '../widgets/service_price_text.dart';

/// Details of one service or package with a prominent Book Now button.
class ServiceDetailScreen extends StatelessWidget {
  const ServiceDetailScreen({super.key, required this.offer});

  final ServiceOffer? offer;

  @override
  Widget build(BuildContext context) {
    final o = offer;
    if (o == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Service')),
        body: const Center(child: Text('Service not found.')),
      );
    }

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Service Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ServiceImage(
            imageUrl: o.imageUrl,
            width: double.infinity,
            height: 200,
            radius: 16,
          ),
          const SizedBox(height: 16),
          Text(
            o.name,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          ServicePriceText(offer: o, large: true),
          if (o.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(o.description, style: theme.textTheme.bodyMedium),
          ],
          if (o.includes.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              "What's included",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            for (final item in o.includes)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item)),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 16),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.onAccent,
              minimumSize: const Size.fromHeight(52),
            ),
            onPressed: () =>
                context.push(RouteNames.repairBooking, extra: o.bookingArgs),
            child: const Text(
              'Book Now',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
    );
  }
}
